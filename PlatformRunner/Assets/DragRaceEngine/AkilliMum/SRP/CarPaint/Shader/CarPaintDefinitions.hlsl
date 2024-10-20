#ifndef CARPAINT_DEFINITIONS_INCLUDED
#define CARPAINT_DEFINITIONS_INCLUDED

#include "../../Pipeline/ShaderLibrary/CommonOperations.hlsl"
#include "../../Pipeline/ShaderLibrary/BRDF.hlsl"
#include "../../Pipeline/ShaderLibrary/RealtimeLights.hlsl"
#include "../../Pipeline/ShaderLibrary/GlobalIllumination.hlsl"
#include "../../Pipeline/ShaderLibrary/Lighting.hlsl"
#include "../../Pipeline/Core/ShaderLibrary/ImageBasedLighting.hlsl"
#include "../../Pipeline/Core/ShaderLibrary/EntityLighting.hlsl"
//#include "../../Pipeline/Core/ShaderLibrary/GlobalSamplers.hlsl"

void carPaintVertexPosition(inout float4 positionOS, float3 normalOS)
{
#ifdef _AKMU_CARPAINT_WEATHER
	if (_AKMU_CARPAINT_SNOWY > 0.5)
	{
		//Snow direction calculation
		half snowDot = abs(0 - dot(normalOS, _SnowDirection))
			* step(0, dot(normalOS, _SnowDirection));

		positionOS.y += snowDot * _SnowLevel;
	}
#endif
}

float carPaintEffects(float2 uv, float2 uv_1, float2 uv_2, float2 uv_3, float3 positionWS, 
	inout float3 normalWS, float3 normalOS, inout SurfaceData surfaceData, inout half3 flakeNormal)
{
	half3 viewDirWS = GetWorldSpaceNormalizeViewDir(positionWS);
	float fresnel = pow((1.0 - saturate(dot(normalWS, viewDirWS))), _FresnelPower);
	/*half NoV = saturate(dot(normalWS, viewDirectionWS));
	half fresnelTerm = Pow4(1.0 - NoV);*/

	flakeNormal = half3(0, 0, 0);

#ifdef _AKMU_CARPAINT_FLAKESBUMP
	// Apply scaled flake normal map
	/*flakeNormal = SampleNormal(uv * _FlakesBumpMapScale,
		TEXTURE2D_ARGS(_FlakesBumpMap, sampler_LinearRepeat), 1.);*/
	flakeNormal = SampleNormal(FindUV(_NormalUV, uv, uv_1, uv_2, uv_3) * _FlakesBumpMapScale,
		TEXTURE2D_ARGS(_FlakesBumpMap, sampler_LinearRepeat), 1.);

	half3 scaledFlakeNormal = flakeNormal;
	scaledFlakeNormal.xy *= _FlakesBumpStrength;
	scaledFlakeNormal.z = 0; // Z set to 0 for better blending with other normal map.

	// Blend regular normal map with flakes normal map
	//half roughness = (1 - surfaceData.smoothness);
	surfaceData.normalTS = normalize(surfaceData.normalTS + scaledFlakeNormal);
	//outputNormal = normalize(outputNormal + scaledFlakeNormal);
#endif
	
	//cal emission here with new UV
	//surfaceData.emission = SampleEmission(uv3, _EmissionColor.rgb, TEXTURE2D_ARGS(_EmissionMap, sampler_LinearRepeat),
	//	surfaceData.alpha, surfaceData.alpha);

	//half3 outputNormal = surfaceData.normalTS;

#ifdef _AKMU_CARPAINT_DIRTBUMP
	float4 dirty = SAMPLE_TEXTURE2D(_DirtMap, sampler_LinearRepeat, FindUV(_DirtUV, uv, uv_1, uv_2, uv_3));
	half dirtyAlpha = saturate(dirty.a * _DirtMapCutoff);
		
	half3 dirtyNormal = SampleNormal(FindUV(_DirtUV, uv, uv_1, uv_2, uv_3),
		TEXTURE2D_ARGS(_DirtBumpMap, sampler_LinearRepeat), 1.);// _BumpScale);
	//new normal will be directly dirt's normal, because it is another layer on top of everything
	surfaceData.normalTS = normalize(lerp(surfaceData.normalTS, dirtyNormal, dirtyAlpha));
#endif

	float4 colorRainy = 0;

#ifdef _AKMU_CARPAINT_WEATHER
	if (_AKMU_CARPAINT_RAINY > 0.5)
	{
		//triplanar UV !!
		// get scale from matrix
		float3 scale = float3(
			length(unity_WorldToObject._m00_m01_m02),
			length(unity_WorldToObject._m10_m11_m12),
			length(unity_WorldToObject._m20_m21_m22)
			);

		// get translation from matrix
		float3 pos = unity_WorldToObject._m03_m13_m23 / scale;

		// get unscaled rotation from matrix
		float3x3 rot = float3x3(
			normalize(unity_WorldToObject._m00_m01_m02),
			normalize(unity_WorldToObject._m10_m11_m12),
			normalize(unity_WorldToObject._m20_m21_m22)
			);
		// make box mapping with rotation preserved
		float3 map = mul(rot, positionWS) + pos;
		float3 norm = mul(rot, normalWS);

		float3 blend = abs(norm) / dot(abs(norm), float3(1, 1, 1));
		float2 triplanarUV;
		/*original*/
		/*if (blend.x > max(blend.y, blend.z)) {
			triplanarUV = map.yz;
		}
		else if (blend.z > blend.y) {
			triplanarUV = map.xy;
		}
		else {
			triplanarUV = map.xz;
		}*/
		/*modified, I always want up to down uv :)*/
		if (blend.x > max(blend.y, blend.z)) {
			triplanarUV = map.zy;
		}
		else if (blend.z > blend.y) {
			triplanarUV = map.xy;
		}
		else {
			triplanarUV = map.xy;
		}


		float4 ase_grabScreenPosNorm = float4(0, 0, 0, 1); // ase_grabScreenPos / ase_grabScreenPos.w;
		/*if(all(outputNormal.xyz == float3(0,0,0)))
			ase_grabScreenPosNorm = float4(normalWS.xyz, 1);*/
		float2 appendResult145 = (float2(0.0, _DropletsGravity));
		float2 uv_TexCoord3 = uv * _TilingDroplet.xy; //use uv for drops, we can tile it anyway :)

		float2 panner143 = (1.0 * _Time.y * appendResult145 + uv_TexCoord3);

		float4 tex2DNode2 = SAMPLE_TEXTURE2D(_DropletMask, sampler_LinearRepeat, panner143);
		//return tex2DNode2;

		float3 ase_worldNormal = normalWS; // i.worldNormal;
		float dotResult191 = dot(ase_worldNormal, float3(0, 1, 0));

		//no droplet on sides
		//dotResult191 = lerp(0, dotResult191, normalize(normalWS.y));


		float4 temp_cast_1 = (1.0).xxxx;
		float4 break171 = ((tex2DNode2 * 2.0) - temp_cast_1);
		float4 appendResult172 = (float4(break171.r, break171.g, 0.0, 0.0));
		float mulTime4 = _Time.y * _DropletsStrikeSpeed;
		float4 break201 = (appendResult172 * saturate(ceil((0.0 + ((tex2DNode2.a - frac(((-1.0 + (tex2DNode2.b - 0.0) * (1.0 - -1.0) / (1.0 - 0.0)) + mulTime4))) - (1.0 - _Droplets_Strength)) * (1.0 - 0.0) / (1.0 - (1.0 - _Droplets_Strength))))));

		float4 appendResult200 = (float4(break201.x, break201.y, break201.z, break201.w));

		//no droplet on sides
		appendResult200 = lerp(0, appendResult200, saturate(normalWS.y));


		float4 temp_output_41_0_Drop =
			(ase_grabScreenPosNorm + ((appendResult200)*_Distortion)); //?????todo:

		temp_output_41_0_Drop.z = 0; //for better blend
		//surfaceData.normalTS = surfaceData.normalTS - temp_output_41_0_Drop.xyz;
		//it seems very bad on high fresnels, so block it on fresnel!!!
		normalWS = normalWS - temp_output_41_0_Drop.xyz * (1 - fresnel);





		//float3 objectPos = mul((float3x3)unity_ObjectToWorld, float3(0, 0, 0));
		////Unity_RotateAboutAxis_Degrees_float(objectPos, float3 (1, 1, 1), rotatedVertexFromCentre, objectPos);
		//float3 rivuletWS = positionWS;
		//Unity_RotateAboutAxis_Degrees_float(rivuletWS, float3 (1, 1, 1), rotatedVertexFromCentre, rivuletWS);
		////outColor.rgb = normalize( rotatedVertexFromCentre);
		////return;
		////float3 objectRotation = mul(unity_ObjectToWorld, rivuletWS);

		//float3 verticalUv = float3(objectPos.x - rivuletWS.x, objectPos.y - rivuletWS.y, 0) * _TilingRivulet;
		////verticalUv = ProcessRainUv(normalWS, verticalUv);
		//verticalUv -= 0.5 * _TilingRivulet.xyz;
		//Unity_RotateAboutAxis_Degrees_float(verticalUv, float3 (0, 0, 1), _RivuletRotation, verticalUv);
		//verticalUv += 0.5 * _TilingRivulet.xyz;

		//float3 verticalUv2 = float3(objectPos.z - rivuletWS.z, objectPos.y - rivuletWS.y, 0) * _TilingRivulet;
		////verticalUv2 = ProcessRainUv(normalWS, verticalUv2);
		//verticalUv2 -= 0.5 * _TilingRivulet.xyz;
		//Unity_RotateAboutAxis_Degrees_float(verticalUv2, float3 (0, 0, 1), _RivuletRotation, verticalUv2);
		//verticalUv2 += 0.5 * _TilingRivulet.xyz;

		//float Texture_var = SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, TRANSFORM_TEX(verticalUv.xy, _RivuletMask)).a;
		//float Texture_var2 = SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, TRANSFORM_TEX(verticalUv2.xy, _RivuletMask)).a;

		//float3 verticalUvMove = float3(objectPos.z - rivuletWS.z, objectPos.y - rivuletWS.y, 0) * _TilingRivulet;
		////verticalUvMove = ProcessRainUv(normalWS, verticalUvMove);
		//verticalUvMove -= 0.5 * _TilingRivulet.xyz;
		//Unity_RotateAboutAxis_Degrees_float(verticalUvMove, float3 (0, 0, 1), _RivuletRotation, verticalUvMove);
		//verticalUvMove += 0.5 * _TilingRivulet.xyz;
		//verticalUvMove.y -= _Time.y * _RivuletSpeed;

		//float3 verticalUvMove2 = float3(objectPos.z - rivuletWS.z, objectPos.y - rivuletWS.y, 0) * _TilingRivulet;
		////verticalUvMove2 = ProcessRainUv(normalWS, verticalUvMove2);
		//verticalUvMove2 -= 0.5 * _TilingRivulet.xyz;
		//Unity_RotateAboutAxis_Degrees_float(verticalUvMove2, float3 (0, 0, 1), _RivuletRotation, verticalUvMove2);
		//verticalUvMove2 += 0.5 * _TilingRivulet.xyz;
		//verticalUvMove2.y -= _Time.y * _RivuletSpeed;

		//float filter = saturate(SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, TRANSFORM_TEX(verticalUvMove.xy, _RivuletMask)).r - 0.7);
		//float filter2 = saturate(SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, TRANSFORM_TEX(verticalUvMove2.xy, _RivuletMask)).r - 0.7);

		//float a1 = (Texture_var * filter);
		//a1 = lerp(a1, 0, abs(normalWS.y));
		//float a2 = (Texture_var2 * filter2);
		//a2 = lerp(a2, 0, abs(normalWS.y));

		////float4 Texture_var2 = tex2D(_Texture, TRANSFORM_TEX(verticalUv2, _Texture));
		//colorRainy = lerp(float4(a1, a1, a1, 1), float4(a2, a2, a2, 1), abs(normalWS.x))
		//	* _RivuletsStrength;
		//colorRainy.z = 0; //for better blen
		////return float4(finalColor);
		////surfaceData.albedo += finalColor;
		//surfaceData.normalTS = surfaceData.normalTS - colorRainy;
		////normalWS = normalize(normalWS + colorRainy);



		//float _GlobalRotation = 0;// _RivuletRotation;
		//float cos76 = cos(_GlobalRotation * Deg2Rad);
		//float sin76 = sin(_GlobalRotation * Deg2Rad);
		//float2 rotator76 = mul(panner143 - float2(0, 0), float2x2(cos76, -sin76, sin76, cos76)) + float2(0, 0);
		//float2 rotator76 = panner143;
		//float3 rotatedPositionWS = positionWS.xyz;
		//float3 objectPos = mul((float3x3)unity_ObjectToWorld, float3(0, 0, 0));
		//////move to zero point
		//rotatedPositionWS -= _RendererCenter;
		//////rotate (locak on x)
		//Unity_RotateAboutAxis_Degrees_float(rotatedPositionWS, float3 (0, 1, 0), _RendererRotation, rotatedPositionWS);
		//////than move to original pos again
		//rotatedPositionWS += _RendererCenter;

		//float2 rotator76 = (1.0 * _Time.y * appendResult145 + positionWS.yz);
		float2 rotator76 = triplanarUV;
		/*outColor = half4(0, positionOS.y, positionOS.z, 1);
		outColor = half4(positionOS.x, positionOS.y, positionOS.z, 1);
		return;*/

		float cos85 = cos(_RivuletRotation * Deg2Rad);
		float sin85 = sin(_RivuletRotation * Deg2Rad);
		float2 rotator85 = mul(rotator76 - float2(0, 0), float2x2(cos85, -sin85, sin85, cos85)) + float2(0, 0);
		//rotate
		//do not rotate rivulets on front and back
		/*outColor = half4(normalOS.x, normalOS.y, normalOS.z,1); //test
		return; //test*/
		float frontOrBack = abs(_RivuletLockDirection == 0 ? normalOS.x : (_RivuletLockDirection == 1 ? normalOS.y : normalOS.z));
		float3 toRotate = float3(rotator85.x, rotator85.y, 0);
		Unity_RotateAboutAxis_Degrees_float(toRotate, float3 (0, 0, 1), _RivuletRotation * frontOrBack, toRotate);
		//Unity_RotateAboutAxis_Degrees_float(toRotate, float3 (0, 0, 1), _RivuletRotation, toRotate);
		rotator85 = toRotate.xy;

		float4 break90 = SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, rotator85 * _TilingRivulet);

		float2 appendResult91 = (float2(break90.b, break90.a));
		float2 temp_output_126_0 = (float2(-0.1, 0) + (appendResult91 - float2(0, 0)) * (float2(0.1, 3) - float2(-0.1, 0)) / (float2(1, 1) - float2(0, 0)));
		float mulTime92 = _Time.y * 0.23;
		float temp_output_1_0_g15 = mulTime92;
		float rest1_ratio102 = (0.0 + (((temp_output_1_0_g15 - floor((temp_output_1_0_g15 + 0.5))) * 2) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
		
		//do notdraw for ceilings, and also change the speed according to normal :)
		_RivuletsStrength = lerp(_RivuletsStrength, 0, abs(normalWS.y));
		
		float mulTime132 = _Time.y * _RivuletSpeed;
		float2 appendResult133 = (float2(0.0, mulTime132));
		float temp_output_1_0_g14 = (mulTime92 * 1.0 + 0.5);
		float rest2_ratio106 = (0.0 + (((temp_output_1_0_g14 - floor((temp_output_1_0_g14 + 0.5))) * 2) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0));
		float temp_output_1_0_g16 = mulTime92;
		float bias114 = pow((0.0 + ((((abs(((temp_output_1_0_g16 - floor((temp_output_1_0_g16 + 0.5))) * 2)) * 2) - 1.0) + 0.0) - -1.0) * (1.0 - 0.0) / (1.0 - -1.0)), 2.0);
		
		float4 lerpResult130 = lerp(
			SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, ((temp_output_126_0 * rest1_ratio102) + rotator85 + appendResult133) * _TilingRivulet),
			SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, ((temp_output_126_0 * rest2_ratio106) + rotator85 + appendResult133) * _TilingRivulet), bias114);
		
		float3 rivuletDistortion = (lerpResult130.xxx) * _RivuletsStrength;
		//for better blending remove z
		//rivuletDistortion.z = 0;
		//merge with normals
		//surfaceData.normalTS = surfaceData.normalTS - rivuletDistortion.xyz * (1. - (lerpResult130.r + 0.5)); //red channel returns 0.5 for X value
		rivuletDistortion = lerp(rivuletDistortion, 0, abs(normalWS.y));
		normalWS = normalWS + rivuletDistortion.xyz * lerpResult130.a; // *(1. - (lerpResult130.r + 0.5)); //red channel returns 0.5 for X value




		//add waves
		//half3 col_orig1 = SampleNormal(uv / _WaveSize + _WaveSpeed * _Time.y, TEXTURE2D_ARGS(_RivuletBump, sampler_RivuletBump), _BumpScale);
		half3 col_orig1 = SampleNormal(FindUV(_NormalUV, uv, uv_1, uv_2, uv_3) / _WaveSize + _WaveSpeed * _Time.y, TEXTURE2D_ARGS(_DropletMask, sampler_LinearRepeat), _BumpScale);
		//SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv / _WaveSize + _WaveSpeed * _Time.y);
	//half3 col_orig2 = SampleNormal(uv / _WaveSize - _WaveSpeed * _Time.y, TEXTURE2D_ARGS(_RivuletBump, sampler_RivuletBump), _BumpScale);
		half3 col_orig2 = SampleNormal(FindUV(_NormalUV, uv, uv_1, uv_2, uv_3) / _WaveSize - _WaveSpeed * _Time.y, TEXTURE2D_ARGS(_DropletMask, sampler_LinearRepeat), _BumpScale);
		//SAMPLE_TEXTURE2D(_BumpMap, sampler_BumpMap, uv / _WaveSize - _WaveSpeed * _Time.y);

		half3 wave1 = (col_orig1 * _WaveDistortion);
		half3 wave2 = (col_orig2 * _WaveDistortion);

		//surfaceData.normalTS = surfaceData.normalTS + (wave1 * wave2);
		normalWS = normalWS + (wave1 * wave2);
	}
#endif

#ifdef _AKMU_CARPAINT_WEATHER
	//change snow color after car paint fresnel!!!!
	if (_AKMU_CARPAINT_SNOWY > 0.5)
	{
		// //Color and normals of the main textures
		//fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
		//float3 normals = UnpackNormal(tex2D(_MainNormal, IN.uv_MainNormal));
		//Color and normals of the snow textures
		half4 snowColor = SAMPLE_TEXTURE2D(_RivuletMask, sampler_LinearRepeat, FindUV(_SnowUV, uv, uv_1, uv_2, uv_3)) * _SnowColor;
		half3 snowNormals = SampleNormal(FindUV(_SnowNormalUV, uv, uv_1, uv_2, uv_3), TEXTURE2D_ARGS(_DropletMask, sampler_LinearRepeat), _BumpScale);
		//Snow direction calculation
		//half snowDot = step(_SnowLevel, dot(normalWS, normalize(_SnowDirection)));
		half snowDot = abs(0 - dot(normalWS, _SnowDirection))
			* step(0, dot(normalWS, _SnowDirection));

		normalWS = lerp(normalWS, snowNormals, snowDot);
		//outputNormal = lerp(outputNormal, snowNormals, snowDot);
		surfaceData.metallic = lerp(surfaceData.metallic, _SnowMetallic, snowDot); ;
		surfaceData.smoothness = lerp(surfaceData.smoothness, _SnowGlossiness, snowDot); ;

		_BaseColor.rgb = lerp(_BaseColor.rgb, snowColor.xyz * 10, snowDot * snowColor.a);
		_FresnelColor.rgb = lerp(_FresnelColor.rgb, snowColor.xyz * 10, snowDot * snowColor.a);
		_FresnelColor2.rgb = lerp(_FresnelColor2.rgb, snowColor.xyz * 10, snowDot * snowColor.a);
	}
#endif

	return fresnel;
}

void carPaintApplyColors(inout SurfaceData surfaceData, float fresnel, half3 flakeNormal, float3 positionWS, half wireframe)
{

	half3 fColor = half(1);
#ifdef _AKMU_GEOM_EXTRUDE
	if (_Extrude > 0.5 && _ExtrudePos < positionWS.z)
	{
		//todo: color pass an	imation
		/*_BaseColor = _BaseColorNext;
		_FresnelColor2 = _FresnelColor2Next;
		_FresnelColor = _FresnelColorNext;*/
	}
#endif
	//surfaceData.albedo = _BaseColor.rgb;
	/*surfaceData.albedo *= lerp(lerp(_BaseColor.rgb, _FresnelColor2.xyz, saturate(fresnel)),
		lerp(_FresnelColor2.xyz, _FresnelColor.xyz, saturate(fresnel * fresnel)), saturate(fresnel));*/
	fColor =
		(
			//  0.7      0.7    === 1 olmali
			//  0.35     0.7    === 0.5 olmali
			//  0        0.7    === 0 olmali
			(fresnel < _FresnelGap ? lerp(_BaseColor.rgb, _FresnelColor2.xyz, ((1 / (_FresnelGap + 0.00001)) * fresnel)) : 0) //convert 0-x fresnel to 0-1 gap
			+
			//  0.7      0.7    === 0 olmali
			//  0.85     0.7    === 0.5 olmali
			//  1.0      0.7    === 1 olmali
			(fresnel >= _FresnelGap ? lerp(_FresnelColor2.xyz, _FresnelColor.xyz, (fresnel - _FresnelGap) * (1. / (1. - _FresnelGap + 0.00001))) : 0) //convert x-1 fresnel to 0-1 gap
			);

#ifdef _AKMU_CARPAINT_FLAKESBUMP	
		half normalColorRatio = (1 - flakeNormal.z) * _FlakesBumpStrength;
		fColor = lerp(fColor, flakeNormal, saturate(normalColorRatio));
#endif

#if defined (_AKMU_CARPAINT) && defined (_AKMU_CARPAINT_GEOMETRY) && defined (_AKMU_GEOM_WIREFRAME)
	if (wireframe == 0)
		surfaceData.albedo *= fColor;
	else
		surfaceData.albedo = _WireframeBaseColor.rgb;
#else
	surfaceData.albedo *= fColor;
#endif
	
	//!!!add brightness before PBR color calculation
	surfaceData.albedo *= _Brightness; //add use selected brightness
}

void carPaintApplyTextures(inout half4 color, inout InputData inputData, inout SurfaceData surfaceData, 
	float2 uv, float2 uv_1, float2 uv_2, float2 uv_3)
{

#ifdef _AKMU_CARPAINT_LIVERY
	//float4 liveryTex = SAMPLE_TEXTURE2D(_LiveryMap, sampler_LinearRepeat, FindUV(_LiveryUV, uv, uv_1, uv_2, uv_3));
	float4 liveryTex = SAMPLE_TEXTURE2D(_LiveryMap, sampler_LinearRepeat, FindUV(_LiveryUV, uv, uv_1, uv_2, uv_3));
	surfaceData.albedo = liveryTex.xyz * _LiveryColor;
	surfaceData.metallic = _LiveryMetalic;
	surfaceData.smoothness = _LiverySmoothness;

	//!!!add brightness before PBR color calculation
	surfaceData.albedo *= _Brightness; //add use selected brightness
	half4 livery = UniversalFragmentPBR(inputData, surfaceData);
	/*half4 livery = UniversalFragmentPBREx(inputData, surfaceData,
		input.objectPosWSRotated, _BBoxMin.xyz, _BBoxMax.xyz, _EnviCubeMapPos.xyz, input.normalWS);*/

	color = lerp(color, livery, liveryTex.a);
#endif

#ifdef _AKMU_CARPAINT_DECAL
	//float4 decalTex = SAMPLE_TEXTURE2D(_DecalMap, sampler_LinearRepeat, FindUV(_DecalUV, uv, uv_1, uv_2, uv_3));
	float4 decalTex = SAMPLE_TEXTURE2D(_DecalMap, sampler_LinearRepeat, FindUV(_DecalUV, uv, uv_1, uv_2, uv_3));
	surfaceData.albedo = decalTex.xyz * _DecalColor;
	surfaceData.metallic = _DecalMetalic;
	surfaceData.smoothness = _DecalSmoothness;

	//!!!add brightness before PBR color calculation
	surfaceData.albedo *= _Brightness; //add use selected brightness
	half4 decal = UniversalFragmentPBR(inputData, surfaceData);
	/*half4 decal = UniversalFragmentPBREx(inputData, surfaceData,
		input.objectPosWSRotated, _BBoxMin.xyz, _BBoxMax.xyz, _EnviCubeMapPos.xyz, input.normalWS);*/

	color = lerp(color, decal, decalTex.a);
#endif

	//because dirt is not attached to color it self (it is like another layer on object)
	//we will change this final color (after metalic color etc.)
#ifdef _AKMU_CARPAINT_DIRTBUMP
	float4 dirt = SAMPLE_TEXTURE2D(_DirtMap, sampler_LinearRepeat, FindUV(_DirtUV, uv, uv_1, uv_2, uv_3));
	half dirtAlpha = saturate(dirt.a * _DirtMapCutoff);

	surfaceData.albedo = dirt.xyz * _DirtColor;
	surfaceData.metallic = _DirtMetalic;
	surfaceData.smoothness = _DirtSmoothness;

	//!!!add brightness before PBR color calculation
	surfaceData.albedo *= _Brightness; //add use selected brightness
	half4 dirtColor = UniversalFragmentPBR(inputData, surfaceData);

	color.rgb = lerp(color.rgb, dirtColor.xyz, dirtAlpha);
#endif
}


//float fbm(vec2 p)
//{
//	float f = 0.0;
//	f += .5 * noise(p); p = m * p * 2.;
//	f += .25 * noise(p); p = m * p * 2.;
//	f += .125 * noise(p); p = m * p * 2.;
//	f += .0625 * noise(p); p = m * p * 2.;
//	f += .03125 * noise(p);
//	return f / 0.984375;
//}

//// upper layer
////const float nl = 1.;
//// lower layer
//const float nr = 2.;
//
//float Raverage_approx(float n)
//{
//	float n2 = n * n;
//	float n3 = n2 * n;
//	float n4 = n3 * n;
//	float n5 = n4 * n;
//	float n6 = n5 * n;
//
//	return -0.0095 * n6 + 0.1134 * n5 - 0.5639 * n4 + 1.4968 * n3 - 2.2538 * n2 + 1.9795 * n - 0.7566;
//}
//void WetShading(inout float3 albedo, inout float3 normal)
//{
//
//	float nl = 1 + _Wetness;
//	// https://www.victoria.ac.nz/scps/about/staff/pdf/darkerwhenwet.pdf
//	// total inner refraction with solid-liquid interface
//	float p = 1.0 - 1.0 / (nl * nl) * (1.0 - Raverage_approx(nl));
//
//	float3 aD = 1.0 - albedo;
//	float3 aW0 = aD * (1.0 - Raverage_approx(nr / nl)) / (1.0 - Raverage_approx(nr));
//	float3 aW1 = aD;
//
//	float3 aW = (1.0 - aD) * aW0 + aD * aW1;
//
//	float3 A = (1.0 - Raverage_approx(nl)) * aW / (1.0 - p * (1.0 - aW));
//
//
//	float3 wetAlbedo = 1.0 - A;
//	albedo = wetAlbedo;
//
//	//normal = lerp(normal, normalize(float3(0., 1., 0) * .98 + normal * 0.02), 1. - smoothstep(0.5, 0.8, p));
//}

/*#ifdef _AKMU_CARPAINT_TRIPLANAR

	float3 Node_UV = input.positionWS * _TriPlanarTileOffset.x;
	Node_UV.x += _TriPlanarTileOffset.y;
	Node_UV.z += _TriPlanarTileOffset.z;
	float3 Node_Blend = pow(abs(inputData.normalWS), _TriPlanarTileOffset.w); // Blend);
	Node_Blend /= dot(Node_Blend, 1.0);

	Node_UV.z /= 4;

	float4 Node_Y = SAMPLE_TEXTURE2D(_TriPlanarUpMap, sampler_TriPlanarUpMap, Node_UV.xz);
	float4 Node_X = SAMPLE_TEXTURE2D(_TriPlanarSideMap, sampler_TriPlanarSideMap, Node_UV.zy);
	float4 Node_Z = SAMPLE_TEXTURE2D(_TriPlanarFaceMap, sampler_TriPlanarFaceMap, Node_UV.xy);
	//color.rgb = lerp(color.rgb, (Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z).rgb, _Smoothness);
	half NoV = saturate(dot(input.normalWS, inputData.viewDirectionWS));
	half fresnelTerm = Pow4(1.0 - NoV);
	fresnelTerm = max(0, min(1, fresnelTerm + _FresnelIntensity));

	color.rgb = lerp(color.rgb, (Node_X * Node_Blend.x + Node_Y * Node_Blend.y + Node_Z * Node_Blend.z).rgb, fresnelTerm);
#endif*/

//#ifdef _AKMU_CARPAINT
//	#ifdef _AKMU_CARPAINT_FLAKESBUMP
//		if (_EnableFlake > 0.5)
//		{
//			float2 screenSpaceUVEx = input.screenPos.xy / input.screenPos.w;
//			//screenSpaceUVEx.y = 1 - screenSpaceUVEx.y;
//			float sceneRawDepthEx = LOAD_TEXTURE2D_X(_LeftOrCenterDepthTexture, screenSpaceUVEx).r;
//			if (sceneRawDepthEx > 0)
//				color.rgb = sceneRawDepthEx;
//			else
//				color.rgb = 0;
//		}
//	#endif 
//#endif


	//if (_FadeEffectUsage > 0.5)
		//{
		//    float dst = distance(input.positionWS, _FadeEffectPosition);
		//    /*if (dst > _FadeEffectDistance)
		//        color.rgb = 0;
		//    else*/
		//        color.rgb *= min(1, pow(_FadeEffectDistance /dst, _FadeEffectPower));
		//}

		//color.rgb *= calculateRain(input.uv);


//#ifdef _AKMU_CARPAINT
//	WetShading(surfaceData.albedo, surfaceData.normalTS);
//#endif


//half3 Dryer(half3 color) {
//    half3 hslColor = RGBtoHSL(color);
//    hslColor.g -= _Saturation;
//    hslColor.b = sqrt(hslColor.b) * _Lightness;
//    half3 dryColor = HSLtoRGB(hslColor);
//    return dryColor;
//}

//float4 reflectPS(vertexOutput IN, uniform samplerCUBE EnvMap, uniform sampler2D NormalMap, uniform float4 SurfColor, 
//    uniform float Kr, // intensity of reflection     
//    uniform float KrMin, // typical: 0.05 * Kr     
//    uniform float FresExp, // typical: 5.0     
//    uniform float Bumpiness // amount of bump                  
//) : COLOR {   
//    float3 Nu = normalize(IN.LightingNormal);   // for bump mapping, we will alter "Nu" to get "Nb"     
//    float3 Tu = normalize(IN.LightingTangent);   
//    float3 Bu = normalize(IN.LightingBinorm);   
//    float3 bumps = Bumpiness * (tex2D(NormalMap, IN.TexCoord.xy).xyz - (0.5).xxx);   
//    float3 Nb = Nu + (bumps.x * Tu + bumps.y * Bu);   Nb = normalize(Nb); // expressed in user-coord space     
//    float3 Vu = normalize(IN.LightingEyeVec);   
//    float vdn = dot(Vu, Nb); // or "Nu" if unbumped - see text     
//                             // "fres" attenuates the strength of the reflection     
//                             // according to Fresnel's law     
//    float fres = KrMin + (Kr - KrMin) * pow((1.0 - abs(vdn)), FresExp);   
//    float3 reflVect = normalize(reflect(Vu, Nb)); // yes, normalize     
//                                                  // now we intersect "reflVect" with a sphere of radius 1.0     
//    float b = -2.0 * dot(reflVect, IN.LightingPos);   
//    float c = dot(IN.LightingPos, IN.LightingPos) - 1.0;   
//    float discrim = b * b - 4.0 * c;   
//    bool hasIntersects = false;   
//    float4 reflColor = float4(1, 0, 0, 0);   
//    if (discrim > 0) {     
//        // pick a small error value very close to zero as "epsilon"     
//        hasIntersects = ((abs(sqrt(discrim) - b) / 2.0) > 0.00001);   
//    }   
//    if (hasIntersects) {     
//        // determine where on the unit sphere reflVect intersects     
//        reflVect = nearT * reflVect - IN.LightingPos;     
//        // reflVect.y = -reflVect.y; 
//        // optional - see text     
//        // now use the new intersection location as the 3D direction     
//        reflColor = fres * texCUBE(EnvMap, reflVect);   
//    }   
//    float4 result = SurfColor * reflColor;   
//    return result; 
//}

//half3 GlossyEnvironmentReflectionExOld(half3 reflectVector, float3 positionWS, half perceptualRoughness, half occlusion, half3 normalWS,
//	half3 viewDirectionWS)
//{
//	float normalFaceIndex = -1;
//	float reflectFaceIndex = -1;
//	half3 tiledReflectVector = reflectVector;
//
//
//
//	float boxedNormalFaceIndex = -1;
//	float boxedReflectFaceIndex = -1;
//	half3 boxedTiledReflectVector = reflectVector;
//
//	if (_EnableRealTimeReflection == 1)
//	{
//		tiledReflectVector = LocalCorrect(tiledReflectVector, _BBoxMin.xyz, _BBoxMax.xyz, positionWS, _EnviCubeMapPos.xyz);
//	}
//
//	if ((_EnableRealTimeReflection == 2 || _EnableRealTimeReflection == 50)
//		&&
//		_Marker == 1.)
//	{
//
//		//reset rotation (only x will be active)
//		float4 rotation = _EnviRotation;
//
//		//get current faceIndex before x rotation
//		//tiledReflectVector = LocalCorrect(tiledReflectVector, _BBoxMin.xyz, _BBoxMax.xyz, positionWS, _EnviCubeMapPos.xyz);
//		//normalWS = LocalCorrect(normalWS, _BBoxMin.xyz, _BBoxMax.xyz, positionWS, _EnviCubeMapPos.xyz);
//		normalFaceIndex = getFaceIndex(normalWS);
//		reflectFaceIndex = getFaceIndex(tiledReflectVector);
//
//		/*if (0 == 1)
//		{*/
//		if (reflectFaceIndex == 0 //right
//			||
//			normalFaceIndex == 0
//			||
//			normalFaceIndex == 4 //front
//			||
//			normalFaceIndex == 5) //back
//		{
//			reflectFaceIndex = 0; //collect on same value to sample same map
//
//			rotation.y = -rotation.x; //rotate reverse x on y
//			rotation.x = 0;
//			rotation.z = 0;
//		}
//		if (reflectFaceIndex == 1)  //left
//		{
//			reflectFaceIndex = 1; //collect on same value to sample same map
//
//			rotation.z = 90;
//			rotation.y = 0;
//			//rotation.x = 0; //rotate on x as it is
//		}
//		if (reflectFaceIndex == 2) //top
//		{
//			reflectFaceIndex = 1; //collect on same value to sample same map
//
//			rotation.z = 90; //just rotate the cube to sample only top
//			rotation.y = 0;
//			rotation.x = 0;
//		}
//		if (reflectFaceIndex == 3) //bottom
//		{
//			reflectFaceIndex = 0; //collect on same value to sample same map
//
//			rotation.y = rotation.x;
//			rotation.x = 0;
//			rotation.z = 0;
//		}
//		if (reflectFaceIndex == 4 //front
//			||
//			reflectFaceIndex == 5) //back
//		{
//			reflectFaceIndex = 1; //collect on same value to sample same map
//
//			rotation.z = 90; //just rotate the cube to sample only top
//			rotation.y = 0;
//			//rotation.x = 0; same on x
//		}
//		//}
//
//		//rotate according to our movement
//		tiledReflectVector = CreateRotation(tiledReflectVector, rotation);
//
//		//test!!!!!!!!!!!!!!!!!!!
//
//		 //if (reflectFaceIndex == 0 //right
//		 //    ||
//		 //    normalFaceIndex == 0
//		 //    ||
//		 //    normalFaceIndex == 4 //front
//		 //    ||
//		 //    normalFaceIndex == 5) //back
//		 //{
//		 //    reflectFaceIndex = 0; //sample side
//
//		 //    rotation.y = 0;
//		 //    rotation.x = 0;
//		 //    rotation.z = 0;
//		 //}
//		 //if (reflectFaceIndex == 1)  //left
//		 //{
//		 //    reflectFaceIndex = 1; //sample side
//		 //    
//		 //    rotation.y = 0;
//		 //    rotation.x = 0;
//		 //    rotation.z = 0;
//		 //}
//		 //if (reflectFaceIndex == 2) //top
//		 //{
//		 //    reflectFaceIndex = 1; //sample side
//
//		 //    rotation.y = 0;
//		 //    rotation.x = 0;
//		 //    rotation.z = 0;
//		 //}
//		 //if (reflectFaceIndex == 3) //bottom
//		 //{
//		 //    reflectFaceIndex = 0; //collect on same value to sample same map
//
//		 //    rotation.y = 0;
//		 //    rotation.x = 0;
//		 //    rotation.z = 0;
//		 //}
//		 //if (reflectFaceIndex == 4 //front
//		 //    ||
//		 //    reflectFaceIndex == 5) //back
//		 //{
//		 //    reflectFaceIndex = 1; //sample side
//		 //}
//		 //else
//		 //{
//		 //    rotation.y = 0;
//		 //    rotation.x = 0;
//		 //    rotation.z = 0;
//		 //}
//
//		 //if (faceIndex == 0)
//		 //    return float4(255. / 255, 0, 0, 1);            //0 RED - right
//		 //if (faceIndex == 1)
//		 //    return float4(0, 0, 255. / 255, 1); //blue - left
//		 //if (faceIndex == 2)
//		 //    return  float4(0, 255. / 255, 0, 1); //green - top
//		 //if (faceIndex == 3)
//		 //    return float4(255. / 255, 125. / 255, 0, 1); //orange - bottom
//		 //if (faceIndex == 4)
//		 //    return  float4(0, 255. / 255, 255. / 255, 1); //cyan - front
//		 //if (faceIndex == 5)
//		 //    return float4(255. / 255, 255. / 255, 0, 1); //yellow - back
//	}
//
//	if (_Marker == 0.)
//	{
//		//switch to box
//		_EnableRealTimeReflection = 4;
//		////rotate around y
//		//float4 rotation = _EnviRotation;
//		//rotation.y = -rotation.x;
//		//rotation.x = 0;
//		//rotation.z = 0;
//		//boxedTiledReflectVector = CreateRotation(boxedTiledReflectVector, rotation);
//	}
//
//	if (_EnableRealTimeReflection == 4 || _EnableRealTimeReflection == 50)
//	{
//		////////just box projection
//		//////we are sending moving coordinates here, so move it to none moving
//		//float3 newCubePosition = _EnviCubeMapPos.xyz;
//		////_EnviCubeMapLength.z is the distance from start point, so if we move the cube pos according to the
//		////far distance (_EnviCubeMapLength.y); we always get the cobe center (for box projection)
//		////newCubePosition.z -= (_EnviCubeMapLength.z % _EnviCubeMapLength.y); //z param is distance from start point
//		//float3 newMin = newCubePosition - _EnviCubeMapLength.y / 2; //y param is the far distance of the lerp area
//		//float3 newMax = newCubePosition + _EnviCubeMapLength.y / 2;
//		//////reflectVector = LocalCorrect(reflectVector, newMin, newMax, positionWS, newCubePosition);
//		////
//		//boxedTiledReflectVector = LocalCorrect(boxedTiledReflectVector, newMin, newMax, positionWS, newCubePosition);
//
//		boxedTiledReflectVector = LocalCorrect(boxedTiledReflectVector, _BBoxMin.xyz, _BBoxMax.xyz, positionWS, _EnviCubeMapPos.xyz);
//
//		//float4 rotation = _EnviRotation;
//
//		//boxedNormalFaceIndex = getFaceIndex(normalWS);
//		//boxedReflectFaceIndex = getFaceIndex(boxedTiledReflectVector);
//
//		//if(1==0)
//		//{ 
//		//if (boxedReflectFaceIndex == 0 //right
//		//    ||
//		//    boxedNormalFaceIndex == 0
//		//    ||
//		//    boxedNormalFaceIndex == 4 //front
//		//    ||
//		//    boxedNormalFaceIndex == 5) //back
//		//{
//		//    boxedReflectFaceIndex = 0; //collect on same value to sample same map
//
//		//    rotation.y = -rotation.x; //rotate reverse x on y
//		//    rotation.x = 0;
//		//    rotation.z = 0;
//		//}
//		//if (boxedReflectFaceIndex == 1)  //left
//		//{
//		//    boxedReflectFaceIndex = 1; //collect on same value to sample same map
//
//		//    rotation.z = 0;
//		//    rotation.y = 0;
//		//    //rotation.x = 0; //rotate on x as it is
//		//}
//		//if (boxedReflectFaceIndex == 2) //top
//		//{
//		//    boxedReflectFaceIndex = 1; //collect on same value to sample same map
//
//		//    rotation.z = 0; //just rotate the cube to sample only top
//		//    rotation.y = 0;
//		//    rotation.x = 0;
//		//}
//		//if (boxedReflectFaceIndex == 3) //bottom
//		//{
//		//    boxedReflectFaceIndex = 0; //collect on same value to sample same map
//
//		//    rotation.y = -rotation.x; //rotate reverse x on y
//		//    rotation.x = 0;
//		//    rotation.z = 0;
//		//}
//		//if (boxedReflectFaceIndex == 4 //front
//		//    ||
//		//    boxedReflectFaceIndex == 5) //back
//		//{
//		//    boxedReflectFaceIndex = 1; //collect on same value to sample same map
//
//		//    rotation.z = 90; //just rotate the cube to sample only top
//		//    rotation.y = 0;
//		//    //rotation.x = 0; same on x
//		//}
//		//}
//
//		////test
//		//if (boxedReflectFaceIndex == 0 //right
//		//    ||
//		//    boxedNormalFaceIndex == 0
//		//    ||
//		//    boxedNormalFaceIndex == 4 //front
//		//    ||
//		//    boxedNormalFaceIndex == 5) //back
//		//{
//		//    boxedReflectFaceIndex = 0;
//
//		//    rotation.y = 0;
//		//    rotation.x = 0;
//		//    rotation.z = 0;
//		//}
//		//if (boxedReflectFaceIndex == 1) //left
//		//{
//		//   
//		//}
//		//else
//		//{
//		//    rotation.y = 0;
//		//    rotation.x = 0;
//		//    rotation.z = 0;
//		//}
//
//		//rotate according to our movement
//		//boxedTiledReflectVector = CreateRotation(boxedTiledReflectVector, rotation);
//	}
//
//	////float faceIndex = 1;
//	//float angleRight = 0;
//	//float angleBack = 0;
//	//float angleBackRight = 0;
//	//float angleFront = 0;
//	//float angleFrontRight = 0;
//	//
//	//half3 tiledReflectVector = reflectVector;
//
//	//if (_EnableRealTimeReflection == 2 || _EnableRealTimeReflection == 50)
//	//{
//	//    float4 rotation = _EnviRotation;
//	//    rotation.y = 0;
//	//    rotation.z = 0;
//
//	//    //calculate the reflection direction accordingto normal and the right side of the car
//	//    angleRight = radianV(normalWS, half3(1, 0, 0));
//	//    angleBack = radianV(normalWS, half3(0, 0, -1));
//	//    angleBackRight = radianV(normalWS, half3(1, 0, -1));
//	//    angleFront = radianV(normalWS, half3(0, 0, 1));
//	//    angleFrontRight = radianV(normalWS, half3(1, 0, 1));
//
//	//    //cos 0 and 45 is
//	//    //    1 and 0.70710678   <- using them may create good speed??? todo:
//
//	//    if (angleRight >= 0.70710678 && angleRight < 1)
//	//    {
//	//        rotation.y = rotation.x;
//	//        rotation.x = 0;
//	//    }
//	//    else if ((angleBack >= 0.70710678 && angleBack < 1)
//	//        ||
//	//        (angleBackRight >= 0.70710678 && angleBackRight < 1)
//	//        ||
//	//        (angleFront >= 0.70710678 && angleFront < 1)
//	//        ||
//	//        (angleFrontRight >= 0.70710678 && angleFrontRight < 1))
//	//    {
//	//        rotation.y = -rotation.x;
//	//        rotation.x = 0;
//
//	//    }
//	//    else {
//	//        //so for the top etc. reflection will be a little flat but have nice visuals
//	//        //tiledReflectVector = normalWS;
//	//        tiledReflectVector = LocalCorrect(tiledReflectVector, _BBoxMin.xyz, _BBoxMax.xyz, positionWS, _EnviCubeMapPos.xyz);
//	//    }
//	//    tiledReflectVector = CreateRotation(tiledReflectVector, rotation);
//
//	//}
//
//#if !defined(_ENVIRONMENTREFLECTIONS_OFF)
//	half3 irradiance;
//	half3 irradianceCube = 0;
//	half3 irradianceBox = 0;
//
//	//!!!!!!!!!!!!!!!!!do not open ref blending for drag race, our custom cube shader does not work!!!!
////#ifdef _REFLECTION_PROBE_BLENDING //do not open ref blending for drag race, our custom cube shader does not work!!!!
////    irradiance = CalculateIrradianceFromReflectionProbes(reflectVector, positionWS, perceptualRoughness);
////#else
//#ifdef _REFLECTION_PROBE_BOX_PROJECTION
//	if (_EnableRealTimeReflection == 0)
//	{
//		reflectVector = BoxProjectedCubemapDirection(reflectVector, positionWS, unity_SpecCube0_ProbePosition, unity_SpecCube0_BoxMin, unity_SpecCube0_BoxMax);
//	}
//#endif // _REFLECTION_PROBE_BOX_PROJECTION
//	half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
//	half4 encodedIrradiance = 0;
//	half4 encodedIrradianceCube = 0;
//	half4 encodedIrradianceBox = 0;
//
//	if (_EnableRealTimeReflection == 0 || _EnableRealTimeReflection == 1)
//	{
//		encodedIrradiance = half4(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip));
//	}
//
//	if (_EnableRealTimeReflection == 1)
//	{
//		encodedIrradianceCube = half4(SAMPLE_TEXTURECUBE_LOD(_EnviCubeMapMain, sampler_EnviCubeMapMain, tiledReflectVector, mip));
//	}
//
//	//todo:
//	//if (_EnableRealTimeReflection == 2 || _EnableRealTimeReflection == 50)
//	//{
//	//	if (reflectFaceIndex == 0) //same value to sample side
//	//	{
//	//		encodedIrradianceCube = SAMPLE_TEXTURECUBE_LOD(_EnviCubeMapSecondary, sampler_EnviCubeMapSecondary,
//	//			tiledReflectVector, mip + _EnviCubeMapLength.w);
//	//	}
//	//	if (reflectFaceIndex == 1) //same value to sample top
//	//	{
//	//		encodedIrradianceCube = SAMPLE_TEXTURECUBE_LOD(_EnviCubeMapMain, sampler_EnviCubeMapMain, tiledReflectVector, mip);
//	//	}
//	//}
//
//	//todo:
//	/*if (_EnableRealTimeReflection == 4 || _EnableRealTimeReflection == 50)
//	{
//		encodedIrradianceBox = SAMPLE_TEXTURECUBE_LOD(_EnviCubeBox, sampler_EnviCubeBox, boxedTiledReflectVector, mip);
//	}*/
//
//	//calculate last encodedIrradiance
//	if (_EnableRealTimeReflection == 1)
//	{
//		if (all(encodedIrradianceCube.rgb != half3(0, 0, 0)))
//			encodedIrradiance = encodedIrradianceCube;
//		else
//			encodedIrradiance *= _MixMultiplier;
//	}
//
//	if (_EnableRealTimeReflection == 2)
//	{
//		encodedIrradiance = encodedIrradianceCube;
//	}
//
//	if (_EnableRealTimeReflection == 4)
//	{
//		encodedIrradiance = encodedIrradianceBox;
//	}
//
//	if (_EnableRealTimeReflection == 50)
//	{
//		encodedIrradiance = lerp(encodedIrradianceBox, encodedIrradianceCube,
//			(_EnviCubeMapLength.z - _EnviCubeMapLength.x) / (_EnviCubeMapLength.y - _EnviCubeMapLength.x));
//		/// (distanceDynamic  17  -           15         ) / (          30         -           15         )
//	}
//
//
//
//
//
//
//	if (_EnableRealTimeReflection == 0 || _EnableRealTimeReflection == 1)
//	{
//#if defined(UNITY_USE_NATIVE_HDR)
//		irradiance = encodedIrradiance.rgb;
//#else
//		irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
//#endif // UNITY_USE_NATIVE_HDR
//	}
//
//	if (_EnableRealTimeReflection == 1)
//	{
//		irradianceCube = DecodeHDREnvironment(encodedIrradiance, _EnviCubeMapMain_HDR);
//	}
//
//	//todo:
//	//if (_EnableRealTimeReflection == 2 || _EnableRealTimeReflection == 50)
//	//{
//	//	if (reflectFaceIndex == 0) //same value to sample side
//	//	{
//	//		irradianceCube = DecodeHDREnvironment(encodedIrradiance, _EnviCubeMapSecondary_HDR);
//	//	}
//	//	if (reflectFaceIndex == 1)  //same value to sample top
//	//	{
//	//		irradianceCube = DecodeHDREnvironment(encodedIrradiance, _EnviCubeMapMain_HDR);
//	//	}
//	//}
//
//	//todo:
//	/*if (_EnableRealTimeReflection == 4 || _EnableRealTimeReflection == 50)
//	{
//		irradianceBox = DecodeHDREnvironment(encodedIrradiance, _EnviCubeBox_HDR);
//	}*/
//
//	//calculate last encodedIrradiance
//	if (_EnableRealTimeReflection == 1)
//	{
//		if (all(irradianceBox.rgb != half3(0, 0, 0)))
//			irradiance = irradianceBox;
//		else
//			irradiance *= _MixMultiplier;
//	}
//
//	if (_EnableRealTimeReflection == 2)
//	{
//		irradiance = irradianceCube;
//	}
//
//	if (_EnableRealTimeReflection == 4)
//	{
//		irradiance = irradianceBox;
//	}
//
//	if (_EnableRealTimeReflection == 50)
//	{
//		irradiance = lerp(irradianceBox, irradianceCube,
//			(_EnviCubeMapLength.z - _EnviCubeMapLength.x) / (_EnviCubeMapLength.y - _EnviCubeMapLength.x));
//		/// (distanceDynamic  17  -           15         ) / (          30         -           15         )
//	}
//
//
//
//
//
//	//#endif // _REFLECTION_PROBE_BLENDING
//	half3 end = irradiance * occlusion;
//	return end; // half3(min(1, end.r), min(1, end.g), min(1, end.b));
//#else
//	return _GlossyEnvironmentColor.rgb * occlusion;
//#endif // _ENVIRONMENTREFLECTIONS_OFF
//}
//
//// Computes the specular term for EnvironmentBRDF
//half3 EnvironmentBRDFSpecularExOld(BRDFData brdfData, half fresnelTerm)
//{
//	//fresnelTerm = fresnelTerm * 500 * _FresnelIntensity;// 100000;
//	//float smaller = (log(fresnelTerm) / 15) ;
//	//fresnelTerm = max(0,min(1, smaller)); //todo: increase reflection?
//#ifndef _AKMU_CARPAINT_TRIPLANAR
//	fresnelTerm *= _FresnelIntensity;// 100000;
//	//float smaller = (log(fresnelTerm) / 15);
//	fresnelTerm = max(0, min(1, fresnelTerm)); //todo: increase reflection?
//#endif
//
//	float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
//	return half3(surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm));
//}
//
//half3 EnvironmentBRDFExOld(BRDFData brdfData, half3 indirectDiffuse, half3 indirectSpecular, half fresnelTerm)
//{
//	half3 c = indirectDiffuse * brdfData.diffuse;
//	c += indirectSpecular * EnvironmentBRDFSpecularExOld(brdfData, fresnelTerm);
//	return c;
//}
//
//half3 GlobalIlluminationExOld(BRDFData brdfData, BRDFData brdfDataClearCoat, float clearCoatMask,
//	half3 bakedGI, half occlusion, float3 positionWS,
//	half3 normalWS, half3 viewDirectionWS,
//	float3 bBoxMin, float3 bBoxMax, float3 enviCubeMapPos, half3 normalWSInput)
//{
//	//it will be recalculate in reflection!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//	half3 reflectVector = reflect(-viewDirectionWS, normalWS);
//
//	half NoV = saturate(dot(normalWS, viewDirectionWS));
//	half fresnelTerm = Pow4(1.0 - NoV);
//
//	half3 indirectDiffuse = bakedGI;
//	half3 indirectSpecular = GlossyEnvironmentReflectionExOld(reflectVector, positionWS, brdfData.perceptualRoughness, 1.0h,
//		normalWS, viewDirectionWS);
//
//	half3 color = EnvironmentBRDFExOld(brdfData, indirectDiffuse, indirectSpecular, fresnelTerm);
//
//	if (IsOnlyAOLightingFeatureEnabled())
//	{
//		color = half3(1, 1, 1); // "Base white" for AO debug lighting mode
//	}
//
//	//#if defined(_CLEARCOAT) || defined(_CLEARCOATMAP)
//	//	half3 coatIndirectSpecular = GlossyEnvironmentReflectionExOld(reflectVector, positionWS, brdfDataClearCoat.perceptualRoughness, 1.0h,
//	//		normalWS, viewDirectionWS);
//	//	// TODO: "grazing term" causes problems on full roughness
//	//	half3 coatColor = EnvironmentBRDFClearCoat(brdfDataClearCoat, clearCoatMask, coatIndirectSpecular, fresnelTerm);
//	//
//	//	// Blend with base layer using khronos glTF recommended way using NoV
//	//	// Smooth surface & "ambiguous" lighting
//	//	// NOTE: fresnelTerm (above) is pow4 instead of pow5, but should be ok as blend weight.
//	//	half coatFresnel = kDielectricSpec.x + kDielectricSpec.a * fresnelTerm;
//	//	return (color * (1.0 - coatFresnel * clearCoatMask) + coatColor) * occlusion;
//	//#else
//	return color * occlusion;
//	//#endif
//}

/////////////////////////////////////////////////////////////////////////////////
////                      Fragment Functions                                   //
////       Used by ShaderGraph and others builtin renderers                    //
/////////////////////////////////////////////////////////////////////////////////
//half4 UniversalFragmentPBRExOld(InputData inputData, SurfaceData surfaceData,
//	float3 objectPosWSRotated, float3 bBoxMin, float3 bBoxMax, float3 enviCubeMapPos, half3 normalWSInput)
//{
//#if defined(_SPECULARHIGHLIGHTS_OFF)
//	bool specularHighlightsOff = true;
//#else
//	bool specularHighlightsOff = false;
//#endif
//	BRDFData brdfData;
//
//	// NOTE: can modify "surfaceData"...
//	InitializeBRDFData(surfaceData, brdfData);
//
//#if defined(DEBUG_DISPLAY)
//	half4 debugColor;
//
//	if (CanDebugOverrideOutputColor(inputData, surfaceData, brdfData, debugColor))
//	{
//		return debugColor;
//	}
//#endif
//
//	// Clear-coat calculation...
//	BRDFData brdfDataClearCoat = CreateClearCoatBRDFData(surfaceData, brdfData);
//	half4 shadowMask = CalculateShadowMask(inputData);
//	AmbientOcclusionFactor aoFactor = CreateAmbientOcclusionFactor(inputData, surfaceData);
//
//	uint meshRenderingLayers = 0;
//	//#if UNITY_VERSION >= 202220
//	//#ifdef _WRITE_RENDERING_LAYERS
//	//	renderingLayers = GetMeshRenderingLayer();
//	//	outRenderingLayers = float4(EncodeMeshRenderingLayer(renderingLayers), 0, 0, 0);
//	//#endif
//	//#endif
//
//	Light mainLight = GetMainLight(inputData, shadowMask, aoFactor);
//
//	// NOTE: We don't apply AO to the GI here because it's done in the lighting calculation below...
//	MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI);
//
//	LightingData lightingData = CreateLightingData(inputData, surfaceData);
//
//	lightingData.giColor = GlobalIlluminationExOld(brdfData, brdfDataClearCoat, surfaceData.clearCoatMask,
//		inputData.bakedGI, aoFactor.indirectAmbientOcclusion, inputData.positionWS,
//		inputData.normalWS, inputData.viewDirectionWS,
//		bBoxMin, bBoxMax, enviCubeMapPos, normalWSInput);
//
//	if (IsMatchingLightLayer(mainLight.layerMask, meshRenderingLayers))
//	{
//		lightingData.mainLightColor = LightingPhysicallyBased(brdfData, brdfDataClearCoat,
//			mainLight,
//			inputData.normalWS, inputData.viewDirectionWS,
//			surfaceData.clearCoatMask, specularHighlightsOff);
//	}
//
//#if defined(_ADDITIONAL_LIGHTS)
//	uint pixelLightCount = GetAdditionalLightsCount();
//
//#if USE_CLUSTERED_LIGHTING
//	for (uint lightIndex = 0; lightIndex < min(_AdditionalLightsDirectionalCount, MAX_VISIBLE_LIGHTS); lightIndex++)
//	{
//		Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
//
//		if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
//		{
//			lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
//				inputData.normalWS, inputData.viewDirectionWS,
//				surfaceData.clearCoatMask, specularHighlightsOff);
//		}
//	}
//#endif
//
//	LIGHT_LOOP_BEGIN(pixelLightCount)
//		Light light = GetAdditionalLight(lightIndex, inputData, shadowMask, aoFactor);
//
//	if (IsMatchingLightLayer(light.layerMask, meshRenderingLayers))
//	{
//		lightingData.additionalLightsColor += LightingPhysicallyBased(brdfData, brdfDataClearCoat, light,
//			inputData.normalWS, inputData.viewDirectionWS,
//			surfaceData.clearCoatMask, specularHighlightsOff);
//	}
//	LIGHT_LOOP_END
//#endif
//
//#if defined(_ADDITIONAL_LIGHTS_VERTEX)
//		lightingData.vertexLightingColor += inputData.vertexLighting * brdfData.diffuse;
//#endif
//
//	return CalculateFinalColor(lightingData, surfaceData.alpha);
//}

//
//float3 LocalCorrect(float3 origVec, float3 bboxMin, float3 bboxMax, float3 positionWS, float3 cubemapPos)
//{
//	// Find the ray intersection with box plane
//	float3 invOrigVec = float3(1.0, 1.0, 1.0) / origVec;
//
//	float3 intersecAtMaxPlane = (bboxMax - positionWS) * invOrigVec;
//
//	float3 intersecAtMinPlane = (bboxMin - positionWS) * invOrigVec;
//
//	// Get the largest intersection values (we are not intersted in negative values)
//	float3 largestIntersec = max(intersecAtMaxPlane, intersecAtMinPlane);
//
//	// Get the closest of all solutions
//	float Distance = min(min(largestIntersec.x, largestIntersec.y), largestIntersec.z);
//
//	// Get the intersection position
//	float3 IntersectPositionWS = positionWS + origVec * Distance;
//
//	// Get corrected vector
//	float3 localCorrectedVec = IntersectPositionWS - cubemapPos;
//
//	return localCorrectedVec;
//}


	//output.rotatedVertexFromCentre = mul((float3x3)unity_ObjectToWorld, input.positionOS.xyz);

	//output.objectPosWSRotated = vertexInput.positionWS;

	//if (_EnableRealTimeReflection > 0)
	//{
	//    //find the 0 (zero) point
	//    float3 ObjectPosition = mul(unity_ObjectToWorld, float4(0.0, 0.0, 0.0, 1.0)).xyz;
	//    //output.objectPosWSRotated -= _EnviCubeMapPos;
	//    output.objectPosWSRotated -= ObjectPosition;
	//    output.objectPosWSRotated = CreateRotation(output.objectPosWSRotated, 0);
	//    output.objectPosWSRotated += ObjectPosition;
	//    //output.objectPosWSRotated += _EnviCubeMapPos;
	//}

#endif
