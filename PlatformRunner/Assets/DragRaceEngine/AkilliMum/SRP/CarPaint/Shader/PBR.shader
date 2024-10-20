Shader "AkilliMum/URP/CarPaint/PBR"
{
    Properties
    {
        // Specular vs Metallic workflow
        _WorkflowMode("WorkflowMode", Float) = 1.0

        [MainTexture] _BaseMap("Albedo", 2D) = "white" {}
        [MainColor] _BaseColor("Color", Color) = (1,1,1,1)
			 
        _Cutoff("Alpha Cutoff", Range(0.0, 1.0)) = 0.5

        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _SmoothnessTextureChannel("Smoothness texture channel", Float) = 0

        _Metallic("Metallic", Range(0.0, 1.0)) = 0.0
        _MetallicGlossMap("Metallic", 2D) = "white" {}

        _SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
        _SpecGlossMap("Specular", 2D) = "white" {}

        [ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
        [ToggleOff] _EnvironmentReflections("Environment Reflections", Float) = 1.0

        _BumpScale("Scale", Float) = 1.0
        _BumpMap("Normal Map", 2D) = "bump" {}

        _Parallax("Scale", Range(0.005, 0.08)) = 0.005
        _ParallaxMap("Height Map", 2D) = "black" {}

        _OcclusionStrength("Strength", Range(0.0, 1.0)) = 1.0
        _OcclusionMap("Occlusion", 2D) = "white" {}

        [HDR] _EmissionColor("Color", Color) = (0,0,0)
        _EmissionMap("Emission", 2D) = "white" {}

        //_DetailMask("Detail Mask", 2D) = "white" {}
        //_DetailAlbedoMapScale("Scale", Range(0.0, 2.0)) = 1.0
        //_DetailAlbedoMap("Detail Albedo x2", 2D) = "linearGrey" {}
        //_DetailNormalMapScale("Scale", Range(0.0, 2.0)) = 1.0
        //[Normal] _DetailNormalMap("Normal Map", 2D) = "bump" {}

        [ToggleUI] _ClearCoat("Clear Coat", Float) = 0.0
        _ClearCoatMap("Clear Coat Map", 2D) = "white" {}
        _ClearCoatMask("Clear Coat Mask", Range(0.0, 1.0)) = 0.0
        _ClearCoatSmoothness("Clear Coat Smoothness", Range(0.0, 1.0)) = 1.0

        // Blending state
        _Surface("__surface", Float) = 0.0
        _Blend("__blend", Float) = 0.0
        _Cull("__cull", Float) = 2.0
        [ToggleUI] _AlphaClip("__clip", Float) = 0.0
        [HideInInspector] _SrcBlend("__src", Float) = 1.0
        [HideInInspector] _DstBlend("__dst", Float) = 0.0
        [HideInInspector] _SrcBlendAlpha("__srcA", Float) = 1.0
        [HideInInspector] _DstBlendAlpha("__dstA", Float) = 0.0
        [HideInInspector] _ZWrite("__zw", Float) = 1.0
        [HideInInspector] _BlendModePreserveSpecular("_BlendModePreserveSpecular", Float) = 1.0
        [HideInInspector] _AlphaToMask("__alphaToMask", Float) = 0.0

        [ToggleUI] _ReceiveShadows("Receive Shadows", Float) = 1.0
        // Editmode props
        _QueueOffset("Queue offset", Float) = 0.0

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _GlossMapScale("Smoothness", Float) = 0.0
        [HideInInspector] _Glossiness("Smoothness", Float) = 0.0
        [HideInInspector] _GlossyReflections("EnvironmentReflections", Float) = 0.0

        [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
        [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}



        //new values
        [HideInInspector]_UV0TileOffset("UV0 Tile and Offset", Vector) = (1,1,0,0)
		[HideInInspector]_UV1TileOffset("UV1 Tile and Offset", Vector) = (1,1,0,0)
		[HideInInspector]_UV2TileOffset("UV2 Tile and Offset", Vector) = (1,1,0,0)
		[HideInInspector]_UV3TileOffset("UV3 Tile and Offset", Vector) = (1,1,0,0)

		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _BaseMapUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _SpecularUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _MetallicUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _NormalUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _ParallaxUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _OcclusionUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _ClearCoatUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _EmissionUV("", Float) = 0.0
             
		[Toggle(O_REFLECTION_PROBE_BLENDING)] O_REFLECTION_PROBE_BLENDING("REFLECTION_PROBE_BLENDING", Float) = 0
		[Toggle(O_REFLECTION_PROBE_BOX_PROJECTION)] O_REFLECTION_PROBE_BOX_PROJECTION("_REFLECTION_PROBE_BOX_PROJECTION", Float) = 0
		[Toggle(O_LIGHT_COOKIES)] O_LIGHT_COOKIES("_LIGHT_COOKIES", Float) = 0
		//[Toggle(O_WRITE_RENDERING_LAYERS)] O_WRITE_RENDERING_LAYERS("_WRITE_RENDERING_LAYERS", Float) = 1
		[Toggle(O_LOD_FADE_CROSSFADE)] O_LOD_FADE_CROSSFADE("LOD_FADE_CROSSFADE", Float) = 0
		[Toggle(O_DEBUG_DISPLAY)] O_DEBUG_DISPLAY("DEBUG_DISPLAY", Float) = 0
		////[Toggle(O_LIGHTMAP_ON)] O_LIGHTMAP_ON("LIGHTMAP_ON", Float) = 1
		//[Toggle(O_DYNAMICLIGHTMAP_ON)] O_DYNAMICLIGHTMAP_ON("DYNAMICLIGHTMAP_ON", Float) = 0
		////[Toggle(O_LIGHT_LAYERS)] O_LIGHT_LAYERS("LIGHT_LAYERS", Float) = 1
		//[Toggle(O_LIGHTMAP_SHADOW_MIXING)] O_LIGHTMAP_SHADOW_MIXING("LIGHTMAP_SHADOW_MIXING", Float) = 1
		//[Toggle(O_SHADOWS_SHADOWMASK)] O_SHADOWS_SHADOWMASK("SHADOWS_SHADOWMASK", Float) = 1
		//[Toggle(O_DIRLIGHTMAP_COMBINED)] O_DIRLIGHTMAP_COMBINED("DIRLIGHTMAP_COMBINED", Float) = 0
		////[Toggle(O_DOTS_INSTANCING_ON)] O_DOTS_INSTANCING_ON("DOTS_INSTANCING_ON", Float) = 1
		////[Toggle(O_ADDITIONAL_LIGHT_SHADOWS)] O_ADDITIONAL_LIGHT_SHADOWS("ADDITIONAL_LIGHT_SHADOWS", Float) = 1
		//[Toggle(O_SHADOWS_SOFT)] O_SHADOWS_SOFT("SHADOWS_SOFT", Float) = 1
		////[Toggle(O_EMISSION)] O_EMISSION("EMISSION", Float) = 0

        [HideInInspector]_Brightness("Brightness", Range(0.0, 10.0)) = 1.
        [HideInInspector]_FresnelIntensity("Fresnel Intensity", Range(0.0, 10.0)) = 1.

        //[ToggleUI] _EnableDecal("Enable Decal", Float) = 0.0
        [HideInInspector]_DecalMap("Decal Map", 2D) = "white" {}
        [HideInInspector]_DecalColor("Decal Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_DecalMetalic("Decal Metalic", Range(0., 1.)) = 0.0
        [HideInInspector]_DecalSmoothness("Decal Smoothness", Range(0., 1.)) = 0.0
        [Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _DecalUV("Decal UV", Float) = 0.0
        //[HideInInspector]_DecalTileOffset("Decal Tile and Offset", Vector) = (1,1,0,0)
                
        //[ToggleUI] _EnableLivery("Enable Livery", Float) = 0.0
        [HideInInspector]_LiveryMap("Livery Map", 2D) = "white" {}
        [HDR][HideInInspector]_LiveryColor("Livery Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_LiveryMetalic("Livery Metalic", Range(0., 1.)) = 0.0
        [HideInInspector]_LiverySmoothness("Livery Smoothness", Range(0., 1.)) = 0.0
        [Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _LiveryUV("Livery UV", Float) = 0.0
        //[HideInInspector]_LiveryTileOffset("Livery Tile and Offset", Vector) = (1,1,0,0)

        [Enum(None, 0, Rain, 1, Snow, 2)] _WeatherType("Weather Type", float) = 0

        //[ToggleUI] _EnableRain("Enable Rain", Float) = 0.0
		//_Wetness("Wetness", Range(0, 1)) = 1
        [HideInInspector]_AKMU_CARPAINT_RAINY("Enable Rain", Float) = 0.0
        _DropletMask("Droplet Mask", 2D) = "white" {}
        _Distortion("Distortion", Float) = 1
        _TilingDroplet("Tiling Droplet", Vector) = (1, 1, 0, 0)
        _TilingRivulet("Tiling Rivulet", Vector) = (1, 1, 0, 0)
        _Droplets_Strength("Droplets_Strength", Range(0, 1)) = 1
        _RivuletMask("Rivulet Mask", 2D) = "white" {}
        //_RivuletBump("Rivulet Bump (normal)", 2D) = "bump" {}
        //_GlobalRotation("Global Rotation", Range(-180, 180)) = 0
        _RivuletRotation("Rivulet Rotation", Range(-180, 180)) = 0
		[Enum(X, 0, Y, 1, Z, 2)] _RivuletLockDirection("Rivulet Locking Direction", Float) = 0.0
        _RivuletSpeed("Rivulet Speed", Range(0, 2)) = 0.2
        _RivuletsStrength("Rivulets Strength", Range(0, 100)) = 1
        _DropletsGravity("Droplets Gravity", Range(0, 1)) = 0
        _DropletsStrikeSpeed("Droplets Strike Speed", Range(0, 2)) = 0.5
        _WaveSize("Rain Wave Size", Range(0, 10)) = 1
        _WaveSpeed("Rain Wave Speed", Range(0, 1)) = 0.01
        _WaveDistortion("Rain Wave Distortion", Range(0, 10)) = 1

        //[Header(Snow info)]
        //[ToggleUI] _EnableSnow("Enable Snow", Float) = 0.0
        //_SnowTexture("Snow texture", 2D) = "white" {}
        //_SnowCutoff("Snow Cutoff", Range(0.,1.)) = 1.0
        //_SnowNormal("Snow normal", 2D) = "bump" {}
        [HideInInspector]_AKMU_CARPAINT_SNOWY("Enable Snow", Float) = 0.0
        _SnowColor("Snow color", color) = (1,1,1,1)
        _SnowDirection("Snow direction", Vector) = (0, 1, 0)
        _SnowLevel("Snow level", Range(0, 1)) = 0
        _SnowGlossiness("Snow glossiness", Range(0, 1)) = 0.5
        _SnowMetallic("Snow Metallic", Range(0,1)) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _SnowUV("", Float) = 0.0
		[Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _SnowNormalUV("", Float) = 0.0

        //[ToggleUI] _EnableDirt ("Enable Dirt", Float) = 0.0
        [HideInInspector]_DirtMap("Dirt Map", 2D) = "white" {}
        [HideInInspector]_DirtColor("Dirt Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_DirtBumpMap("Dirt Bump (normal)", 2D) = "bump" {}
        [HideInInspector]_DirtMapCutoff("Dirt Map Cutoff", Range(0.,1.)) = 1.0
        [HideInInspector]_DirtMetalic("Dirt Metalic", Range(0., 1.)) = 0.0
        [HideInInspector]_DirtSmoothness("Dirt Smoothness", Range(0., 1.)) = 0.0
        [Enum(UV0, 0, UV1, 1, UV2, 2, UV3, 3)] _DirtUV("Dirt UV", Float) = 0.0
        //[HideInInspector]_DirtTileOffset("Dirt Tile and Offset", Vector) = (1,1,0,0)

      /* [HideInInspector]_TriPlanarUpMap("TriPlanar Up Map", 2D) = "white" {}
        [HideInInspector]_TriPlanarSideMap("TriPlanar Side Map", 2D) = "white" {}
        [HideInInspector]_TriPlanarFaceMap("TriPlanar Face Map", 2D) = "white" {}
        [HideInInspector]_TriPlanarTileOffset("TriPlanar Tile and Offset", Vector) = (1, 1, 0, 0)*/

        [HideInInspector] _FresnelPower("Fresnel Power", Range(0., 10.)) = 1
        [HideInInspector] _FresnelGap("Fresnel Gap", Range(0., 1.)) = 0.5
        [HideInInspector] _FresnelColor("Fresnel Color", Color) = (1, 1, 1, 1)
        [HideInInspector] _FresnelColor2("Fresnel Color2", Color) = (1, 1, 1, 1)
        
        //[ToggleUI] _EnableFlake("Enables flakes and uses the main normal map for the flakes (you must attach the flake normal there!)", Float) = 0.0
        //[HideInInspector]_FlakesUsage("Flakes Usage", Float) = 0.
        [HideInInspector]_FlakesBumpMap("Base Bump Flakes (normal)", 2D) = "bump" {}
        [HideInInspector]_FlakesBumpMapScale("Base Bump Flakes Scale", Float) = 1.0
        [HideInInspector]_FlakesBumpStrength("Base Bump Flakes Strength", Range(0.001, 8)) = 1.0

        [Enum(None, 0, Mixed, 1)] _Marker("_Marker", int) = 1
        [Enum(None, 0, RealTime, 1, CubeMap, 2, TriPlanar, 3, BoxProjected, 4)] _EnableRealTimeReflection("RealTime Reflection", int) = 0

      /*  [HideInInspector][Toggle]_FadeEffectUsage("Fade Effect Usage", Float) = 0.
        [HideInInspector]_FadeEffectPosition("Fade Effect Position", Vector) = (0, 0, 0, 0)
        [HideInInspector]_FadeEffectPower("Fade Effect Power", Float) = 10.0
        [HideInInspector]_FadeEffectDistance("Fade Effect Distance", Float) = 5.0*/


        [HideInInspector]_BBoxMin("BBox Min", Vector) = (0,0,0,0)
        [HideInInspector]_BBoxMax("BBox Max", Vector) = (0,0,0,0)
        [HideInInspector]_EnviCubeMapPos("CubeMap Position", Vector) = (0, 0, 0, 0)
        [HideInInspector]_EnviCubeMapLength("CubeMap Length", Vector) = (0, 0, 0, 0)
        [HideInInspector]_EnviRotation("Environment Rotation", Vector) = (0,0,0,0)
        /*[HideInInspector]_EnviPosition("Environment Position", Vector) = (0, 0, 0, 0)*/
       /* [HideInInspector]_EnableRotation("Enable Rotation", Float) = 0
        */
        //[HideInInspector]_EnviCubeSmoothness("Cube Smoothness", Range(0., 8.)) = 0.
        //[HideInInspector]_EnviCubeIntensity("Cube Intensity", Range(0., 1.)) = 0.5
        [HideInInspector]_EnviCubeBox("Cube Map Box", Cube) = "black" {}
        [HideInInspector]_EnviCubeMapMain ("Cube Map", Cube) = "black" {}
        [HideInInspector]_EnviCubeMapSecondary("Cube Map Secondary", Cube) = "black" {}
        /*[HideInInspector]_EnviCubeMapLeftSide("Cube Map Left Side", Cube) = "black" {}*/
        /*[HideInInspector]_EnviCubeMapToMix1 ("Cube Map to Mix 1", Cube) = "black" {}*/
        [HideInInspector]_MixMultiplier("Cube Map Mix Multiplier", Range(0., 5.)) = 1

		//[Header(Stencil Masking)]
		// https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
		_StencilRef("_StencilRef", Float) = 0
		//[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("_StencilComp (default = Disable) _____Set to NotEqual if you want to mask by specific _StencilRef value, else set to Disable", Float) = 0 //0 = disable
        //[Header(Blending)]
        // https://docs.unity3d.com/ScriptReference/Rendering.BlendMode.html
        [Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendEx("_SrcBlendEx (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
        [Enum(UnityEngine.Rendering.BlendMode)]_DstBlendEx("_DstBlendEx (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha
        //[Header(ZTest)]
        // https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
        // default need to be Disable, because we need to make sure decal render correctly even if camera goes into decal cube volume, although disable ZTest by default will prevent EarlyZ (bad for GPU performance)
        [Enum(UnityEngine.Rendering.CompareFunction)]_ZTestEx("_ZTest (default = Disable or LessEqual", Float) = 0 //0 = disable
        //[Header(Cull)]
        // https://docs.unity3d.com/ScriptReference/Rendering.CullMode.html
        // default need to be Front, because we need to make sure decal render correctly even if camera goes into decal cube
        [Enum(UnityEngine.Rendering.CullMode)]_CullEx("_Cull (default = Back)", Float) = 2 //1 = Front, 2 Back
        [Toggle(_ZWriteEx)] _ZWriteEx("_ZWriteEx (default = On)", Float) = 1
    }

    SubShader
    {
        // Universal Pipeline tag is required. If Universal render pipeline is not set in the graphics settings
        // this Subshader will fail. One can add a subshader below or fallback to Standard built-in to make this
        // material work with both Universal Render Pipeline and Builtin Unity Pipeline
        // ComplexLit does not run with deferred
        Tags
        {
            "RenderType" = "Opaque"
            "RenderPipeline" = "UniversalPipeline"
            "UniversalMaterialType" = "Lit"
            "IgnoreProjector" = "True"
        }
        LOD 300

        Stencil
		{
			Ref[_StencilRef]  //so our shader will use this stencil, we can adjust it for decal like effects
			Comp Always
			Pass Replace
		}

        // ------------------------------------------------------------------
        //  Forward pass. Shades all light in a single pass. GI + emission + Fog
        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlendEx][_DstBlendEx]//, [_SrcBlendAlpha][_DstBlendAlpha]
            ZWrite[_ZWriteEx]
            Cull[_CullEx]
            AlphaToMask[_AlphaToMask]

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            //todo: a bug?
            //spot etc lights does not work on deferred if we do not put it here!!!!
            #define _ADDITIONAL_LIGHT_SHADOWS
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _PARALLAXMAP
            //#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED
            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            #pragma multi_compile_fragment _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile_fragment _ _SHADOWS_SOFT
            #pragma multi_compile_fragment _ _SCREEN_SPACE_OCCLUSION
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fog

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY
            
            #pragma multi_compile _ _AKMU_CARPAINT_WEATHER
            #pragma multi_compile _ _AKMU_CARPAINT_DIRTBUMP
			#pragma shader_feature _AKMU_CARPAINT_DECAL
			//#pragma_AKMU_CARPAINT_TRIPLANAR
			#pragma multi_compile _ _AKMU_CARPAINT_LIVERY
			#pragma shader_feature _AKMU_CARPAINT_FLAKESBUMP
			//#pragma multi_compile _ _AKMU_CARPAINT_RAINY
			//#pragma multi_compile _ _AKMU_CARPAINT_SNOWY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/LitForwardPass.hlsl"
            ENDHLSL
        } 

        Pass
        {
            Name "ShadowCaster"
            Tags
            {
                "LightMode" = "ShadowCaster"
            }

            ZWrite On
            ZTest LEqual
            ColorMask 0
            Cull[_CullEx]

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            // -------------------------------------
            // Universal Pipeline keywords

            // This is used during shadow map generation to differentiate between directional and punctual light shadows, as they use different formulas to apply Normal Bias
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/ShadowCasterPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            // Lightmode matches the ShaderPassName set in UniversalRenderPipeline.cs. SRPDefaultUnlit and passes with
            // no LightMode tag are also rendered by Universal Render Pipeline
            Name "GBuffer"
            Tags
            {
                "LightMode" = "UniversalGBuffer"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite[_ZWriteEx]
            ZTest LEqual
            Cull[_CullEx]

            HLSLPROGRAM
            #pragma target 4.5

            // Deferred Rendering Path does not support the OpenGL-based graphics API:
            // Desktop OpenGL, OpenGL ES 3.0, WebGL 2.0.
            #pragma exclude_renderers gles3 glcore

            // -------------------------------------
            // Shader Stages
            #pragma vertex LitGBufferPassVertex
            #pragma fragment LitGBufferPassFragment

            //todo: a bug?
            //spot etc lights does not work on deferred if we do not put it here!!!!
            //#define _ADDITIONAL_LIGHT_SHADOWS //commented below on gbuffer, hmm
            
            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            //#pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            #pragma shader_feature_local_fragment _OCCLUSIONMAP
            #pragma shader_feature_local _PARALLAXMAP
            //#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED

            #pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
            #pragma shader_feature_local_fragment _ENVIRONMENTREFLECTIONS_OFF
            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local _RECEIVE_SHADOWS_OFF

            // -------------------------------------
            // Universal Pipeline keywords
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE _MAIN_LIGHT_SHADOWS_SCREEN
            //#pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX _ADDITIONAL_LIGHTS
            //#pragma multi_compile _ _ADDITIONAL_LIGHT_SHADOWS
            #pragma multi_compile _ _SHADOWS_SOFT
            #pragma multi_compile _ LIGHTMAP_SHADOW_MIXING
            #pragma multi_compile _ SHADOWS_SHADOWMASK

            // -------------------------------------
            // Unity defined keywords
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fragment _ _GBUFFER_NORMALS_OCT

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY

            #pragma multi_compile _ _AKMU_CARPAINT_WEATHER
            #pragma multi_compile _ _AKMU_CARPAINT_DIRTBUMP
			#pragma shader_feature _AKMU_CARPAINT_DECAL
			//#pragma_AKMU_CARPAINT_TRIPLANAR
			#pragma multi_compile _ _AKMU_CARPAINT_LIVERY
			#pragma shader_feature _AKMU_CARPAINT_FLAKESBUMP
			//#pragma multi_compile _ _AKMU_CARPAINT_RAINY
			//#pragma multi_compile _ _AKMU_CARPAINT_SNOWY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/LitGBufferPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "DepthOnly"
            Tags
            {
                "LightMode" = "DepthOnly"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            ColorMask R
            Cull[_CullEx]

            HLSLPROGRAM

            #pragma vertex DepthOnlyVertex
            #pragma fragment DepthOnlyFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/DepthOnlyPass.hlsl"
            ENDHLSL
        }

        // This pass is used when drawing to a _CameraNormalsTexture texture
        Pass
        {
            Name "DepthNormals"
            Tags
            {
                "LightMode" = "DepthNormals"
            }

            // -------------------------------------
            // Render State Commands
            ZWrite On
            Cull[_CullEx]

            HLSLPROGRAM

            #pragma vertex DepthNormalsVertex
            #pragma fragment DepthNormalsFragment

            // -------------------------------------
            // Material Keywords
            #pragma shader_feature_local _NORMALMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A

            //--------------------------------------
            // GPU Instancing
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/LitDepthNormalsPass.hlsl"
            ENDHLSL
        }

        // This pass it not used during regular rendering, only for lightmap baking.
        Pass
        {
            Name "Meta"
            Tags
            {
                "LightMode" = "Meta"
            }

            // -------------------------------------
            // Render State Commands
            Cull Off

            HLSLPROGRAM

            // -------------------------------------
            // Shader Stages
            #pragma vertex UniversalVertexMeta
            #pragma fragment UniversalFragmentMetaLit

            #pragma shader_feature_local_fragment _SPECULAR_SETUP
            #pragma shader_feature_local_fragment _EMISSION
            #pragma shader_feature_local_fragment _METALLICSPECGLOSSMAP
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ _SMOOTHNESS_TEXTURE_ALBEDO_CHANNEL_A
            //#pragma shader_feature_local _ _DETAIL_MULX2 _DETAIL_SCALED

            #pragma shader_feature_local_fragment _SPECGLOSSMAP

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/LitMetaPass.hlsl"
            ENDHLSL
        }

        Pass
        {
            Name "Universal2D"
            Tags
            {
                "LightMode" = "Universal2D"
            }

            // -------------------------------------
            // Render State Commands
            Blend[_SrcBlendEx][_DstBlendEx]
            ZWrite[_ZWriteEx]
            Cull[_CullEx]

            HLSLPROGRAM
        

            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local_fragment _ALPHATEST_ON
            #pragma shader_feature_local_fragment _ALPHAPREMULTIPLY_ON

            #define _AKMU_CARPAINT
            #undef _AKMU_CARPAINT_GEOMETRY

            // -------------------------------------
            // Includes
            #include "../../Pipeline/Shaders/LitInput.hlsl"
            #include "../../Pipeline/Shaders/Utils/Universal2D.hlsl"
            ENDHLSL
        }
    }

    //FallBack "Hidden/Universal Render Pipeline/Lit"
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    //CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
    CustomEditor "AkilliMum.SRP.CarPaint.PBREditor"
}
