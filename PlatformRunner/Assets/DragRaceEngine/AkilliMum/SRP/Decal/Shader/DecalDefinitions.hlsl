#ifndef DECAL_DEFINITIONS_INCLUDED
#define DECAL_DEFINITIONS_INCLUDED

#include "../../Pipeline/ShaderLibrary/CommonOperations.hlsl"

//IMPORTANT: ıf depth mode is after transparents, a lagging appears, cause we draw the decal after opaques, so it may create 1 frame lag
//so in pipeline asset, depth creation mode should be after opaques!!!

float3 viewSpacePosAtPixelPosition(float2 vpos)
{
	float2 uv = vpos;
	//#ifdef _AKMU_DECAL
	//	float2 uv = vpos * _CameraDepthTexture_ST.xy;
	//#else
	//	float2 uv = vpos * _TempDepthTexture_ST.xy;
	//#endif

	float3 viewSpaceRay = mul(unity_CameraInvProjection, float4(uv * 2.0 - 1.0, 1.0, 1.0) * _ProjectionParams.z);

	float rawDepth;
#ifdef _AKMU_USE_MIRROR_DEPTH
	rawDepth = LOAD_TEXTURE2D_X(_LeftOrCenterDepthTexture, UnityStereoTransformScreenSpaceTex(uv)).r;
#elif defined (_AKMU_DECAL)
	rawDepth = LOAD_TEXTURE2D_X(_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(uv)).r;
#elif defined (_AKMU_DECALTEMP)
	rawDepth = LOAD_TEXTURE2D_X(_TempDepthTexture, UnityStereoTransformScreenSpaceTex(uv)).r;
#endif

	return viewSpaceRay * Linear01Depth(rawDepth);
}

//#if defined(_AKMU_USE_MIRROR_DEPTH) || defined(_AKMU_DECALTEMP) || defined(_AKMU_DECAL)
//	//revert for mirror?
//	input.normalOS = input.normalOS * -1.;
//#endif

void decalVertexProcess(float3 positionVS, inout float4 viewRayOS, inout float4 cameraPosOSAndFogFactor, half fogFactor)
{
	// get "camera to vertex" ray in View space
	float3 viewRay = positionVS;
	// [important note]
	//=========================================================
	// "viewRay z division" must do in the fragment shader, not vertex shader! (due to rasteriazation varying interpolation's perspective correction)
	// We skip the "viewRay z division" in vertex shader for now, and store the division value into varying o.viewRayOS.w first, 
	// we will do the division later when we enter fragment shader
	// viewRay /= viewRay.z; //skip the "viewRay z division" in vertex shader for now
	viewRayOS.w = viewRay.z;//store the division value to varying o.viewRayOS.w
	//=========================================================
	// unity's camera space is right hand coord(negativeZ pointing into screen), we want positive z ray in fragment shader, so negate it
	viewRay *= -1;
	// it is ok to write very expensive code in decal's vertex shader, 
	// it is just a unity cube(4*6 vertices) per decal only, won't affect GPU performance at all.
	float4x4 ViewToObjectMatrix = mul(UNITY_MATRIX_I_M, UNITY_MATRIX_I_V);
	// transform everything to object space(decal space) in vertex shader first, so we can skip all matrix mul() in fragment shader
	viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);

	cameraPosOSAndFogFactor.a = fogFactor;
	cameraPosOSAndFogFactor.xyz = mul(ViewToObjectMatrix, float4(0, 0, 0, 1)).xyz; // hard code 0 or 1 can enable many compiler optimization
}

half4 decalCalculateNormalPosShadow(float4 screenPos, inout float2 uv, inout float4 viewRayOS, float4 cameraPosOSAndFogFactor,
	inout float3 positionWS, out float4 shadowCoord, out half3 viewDirWS)
{
	// [important note]
	//========================================================================
	// now do "viewRay z division" that we skipped in vertex shader earlier.
	viewRayOS.xyz /= viewRayOS.w;
	//========================================================================


	float2 screenSpaceUV = screenPos.xy / screenPos.w;
	
	float sceneRawDepth;

#ifdef _AKMU_USE_MIRROR_DEPTH
	//screenSpaceUV.x = 1 - screenSpaceUV.x;
	sceneRawDepth = LOAD_TEXTURE2D_X(_LeftOrCenterDepthTexture, UnityStereoTransformScreenSpaceTex(screenSpaceUV)).r;

	//testtttttttttttttttttttttttt!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//find world pos from depth
	/*positionWS = DepthToWorld(screenSpaceUV, sceneRawDepth);
	shadowCoord = 0;
	return 0;*/
	/*half aaaa = Linear01Depth(sceneRawDepth);
	if (aaaa >= 0 && aaaa <= 1)
		return aaaa;*/
	
#elif defined (_AKMU_DECAL)
	sceneRawDepth = SAMPLE_TEXTURE2D_X(_CameraDepthTexture, sampler_CameraDepthTexture, UnityStereoTransformScreenSpaceTex(screenSpaceUV)).r;
#elif defined (_AKMU_DECALTEMP)
	sceneRawDepth = SAMPLE_TEXTURE2D_X(_TempDepthTexture, sampler_TempDepthTexture, UnityStereoTransformScreenSpaceTex(screenSpaceUV)).r;
#endif

	//half aaaa = Linear01Depth(sceneRawDepth) *3;
	////half aaaa = sceneRawDepth;
	//half4 dddd = half4(aaaa, aaaa, aaaa, 1);
	//shadowCoord = 0;
	//return dddd; //test!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//float sceneRawDepth = LOAD_TEXTURE2D_X(_LeftOrCenterDepthTexture, screenSpaceUV).r;

	float3 decalSpaceScenePos;

#if _SupportOrthographicCamera
	// we have to support both orthographic and perspective camera projection
	// static uniform branch depends on unity_OrthoParams.w
	// (should we use UNITY_BRANCH here?) decided NO because https://forum.unity.com/threads/correct-use-of-unity_branch.476804/
	if (unity_OrthoParams.w)
	{
		// if orthographic camera, depth store scene depth linearly within [0,1]
		// if platform use reverse depth, make sure to 1-depth also
		// https://docs.unity3d.com/Manual/SL-PlatformDifferences.html
#if defined(UNITY_REVERSED_Z)
		sceneRawDepth = 1 - sceneRawDepth;
#endif

		// simply lerp(near,far, [0,1] linear depth) to get view space depth                  
		float sceneDepthVS = lerp(_ProjectionParams.y, _ProjectionParams.z, sceneRawDepth);

		//***Used a few lines from Asset: Lux URP Essentials by forst***
		// Edit: The copied Lux URP stopped working at some point, and no one even knew why it worked in the first place 
		//----------------------------------------------------------------------------
		float2 viewRayEndPosVS_xy = float2(unity_OrthoParams.xy * (screenPos.xy - 0.5) * 2 /* to clip space */);  // Ortho near/far plane xy pos 
		float4 vposOrtho = float4(viewRayEndPosVS_xy, -sceneDepthVS, 1);                                            // Constructing a view space pos
		float3 wposOrtho = mul(UNITY_MATRIX_I_V, vposOrtho).xyz;                                                 // Trans. view space to world space
		//----------------------------------------------------------------------------

		// transform world to object space(decal space)
		decalSpaceScenePos = mul(GetWorldToObjectMatrix(), float4(wposOrtho, 1)).xyz;
	}
	else
	{
#endif
		// if perspective camera, LinearEyeDepth will handle everything for user
		// remember we can't use LinearEyeDepth for orthographic camera!
		float sceneDepthVS = LinearEyeDepth(sceneRawDepth, _ZBufferParams);

		// scene depth in any space = rayStartPos + rayDir * rayLength
		// here all data in ObjectSpace(OS) or DecalSpace
		// be careful, viewRayOS is not a unit vector, so don't normalize it, it is a direction vector which view space z's length is 1
		decalSpaceScenePos = cameraPosOSAndFogFactor.xyz + viewRayOS.xyz * sceneDepthVS;

#if _SupportOrthographicCamera
	}
#endif


	// convert unity cube's [-0.5,0.5] vertex pos range to [0,1] uv. Only works if you use a unity cube in mesh filter!
	float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;
	
	// discard logic
	//===================================================
	// discard "out of cube volume" pixels
	float shouldClip = 0;
#if _ProjectionAngleDiscardEnable
	// also discard "scene normal not facing decal projector direction" pixels
	float3 decalSpaceHardNormal = normalize(cross(ddx(decalSpaceScenePos), ddy(decalSpaceScenePos)));//reconstruct scene hard normal using scene pos ddx&ddy

	// compare scene hard normal with decal projector's dir, decalSpaceHardNormal.z equals dot(decalForwardDir,sceneHardNormalDir)
	shouldClip = decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold ? 0 : 1;
#endif
	// call discard
	// if ZWrite is Off, clip() is fast enough on mobile, because it won't write the DepthBuffer, so no GPU pipeline stall(confirmed by ARM staff).
	clip(0.5 - abs(decalSpaceScenePos) - shouldClip);
	//===================================================

	// sample the decal texture
	//float2 realUV = uv; //save the uv
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	uv = decalSpaceUV.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;//Texture tiling & offset
	
#if _FracUVEnable
	uv = frac(uv);// add frac to ignore texture wrap setting
#endif
	//half4 col = tex2D(_BaseMap, uv);

	float3 depthWorldPos = ComputeWorldSpacePosition(screenSpaceUV, sceneRawDepth, UNITY_MATRIX_I_VP);

	positionWS = depthWorldPos;  //!!!!!!!!! so it is like the surface

	//half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);



	//update input data according to above params!!! so pixel behave like it is on depth space (like the attached surface)
	//positionWS = depthWorldPos; //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	//MAIN LIGHT SHADOW
#if SHADOWS_SCREEN
	float4 clipPos = TransformWorldToHClip(depthWorldPos);
	shadowCoord = ComputeScreenPos(clipPos);
#else
	shadowCoord = TransformWorldToShadowCoord(depthWorldPos);
#endif
	
	//// get current pixel's view space position
	////float2 reConstructUV = screenSpaceUV;
	//float2 reConstructUV = uv;
	////float2 reConstructUV = depthWorldPos.xy;
	////float2 reConstructUV = decalSpaceScenePos;
	////float2 reConstructUV = shadowCoord.xy;
	//half3 viewSpacePos_c = viewSpacePosAtPixelPosition(reConstructUV + float2(0.0, 0.0));

	//// if depth is at the far plane, then assume skybox
	//// if (abs(viewSpacePos_c.z) >= _ProjectionParams.z)
	//	// return 0;

	//// get view space position at 1 pixel offsets in each major direction
	//half3 viewSpacePos_l = viewSpacePosAtPixelPosition(reConstructUV + float2(-1.0, 0.0));
	//half3 viewSpacePos_r = viewSpacePosAtPixelPosition(reConstructUV + float2(1.0, 0.0));
	//half3 viewSpacePos_d = viewSpacePosAtPixelPosition(reConstructUV + float2(0.0, -1.0));
	//half3 viewSpacePos_u = viewSpacePosAtPixelPosition(reConstructUV + float2(0.0, 1.0));

	//// get the difference between the current and each offset position
	//half3 l = viewSpacePos_c - viewSpacePos_l;
	//half3 r = viewSpacePos_r - viewSpacePos_c;
	//half3 d = viewSpacePos_c - viewSpacePos_d;
	//half3 u = viewSpacePos_u - viewSpacePos_c;

	//// pick horizontal and vertical diff with the smallest z difference
	//half3 h = abs(l.z) < abs(r.z) ? l : r;
	//half3 v = abs(d.z) < abs(u.z) ? d : u;

	//// get view space normal from the cross product of the two smallest offsets
	//half3 viewNormal = normalize(cross(h, v));

	//// transform normal from view space to world space
	//half3 WorldNormal = mul((float3x3)unity_MatrixInvV, viewNormal);
	//// visualize normal (assumes you're using linear space rendering)
	////return half4(WorldNormal.xyz * 0.5 + 0.5, 1.0);
	////WorldNormal = WorldNormal * 0.5 + 0.5;
	////input.normalWS = WorldNormal;
	////multiply the normal with normalMap?
	////half3 myNormal = SampleNormal(uv,
	////    TEXTURE2D_ARGS(_BumpMap, sampler_BumpMap), _BumpScale);
	////myNormal.z = 0; // Z set to 0 for better blending with other normal map.
	//// Blend
	////WorldNormal = normalize(WorldNormal + myNormal);
	////input.normalWS = WorldNormal;
	////surfaceData.normalTS = WorldNormal;
	////input.

	viewDirWS = 0;// GetWorldSpaceNormalizeViewDir(positionWS);

	//return half4(WorldNormal, 1);
	return half4(1,1,1,1);
}
#endif
