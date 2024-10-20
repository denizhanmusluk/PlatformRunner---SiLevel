// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "AkilliMum/URP/CarPaint/Beam"
{
	Properties
	{
		//[Header(Blending)]
		// https://docs.unity3d.com/ScriptReference/Rendering.BlendMode.html
		[Enum(UnityEngine.Rendering.BlendMode)] _SrcBlendEx("_SrcBlendEx (default = SrcAlpha)", Float) = 5 // 5 = SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlendEx("_DstBlendEx (default = OneMinusSrcAlpha)", Float) = 10 // 10 = OneMinusSrcAlpha


	//[Header(ZTest)]
	// https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
	// default need to be Disable, because we need to make sure decal render correctly even if camera goes into decal cube volume, although disable ZTest by default will prevent EarlyZ (bad for GPU performance)
	[Enum(UnityEngine.Rendering.CompareFunction)]_ZTestEx("_ZTest (default = Disable) _____to improve GPU performance, Set to LessEqual if camera never goes into cube volume, else set to Disable", Float) = 0 //0 = disable

	//[Header(Cull)]
	// https://docs.unity3d.com/ScriptReference/Rendering.CullMode.html
	// default need to be Front, because we need to make sure decal render correctly even if camera goes into decal cube
	[Enum(UnityEngine.Rendering.CullMode)]_CullEx("_Cull (default = Front) _____to improve GPU performance, Set to Back if camera never goes into cube volume, else set to Front", Float) = 1 //1 = Front

		[Toggle(_ZWriteEx)] _ZWriteEx("_ZWriteEx (default = off)", Float) = 0

		[MainTexture] _BaseMap("Albedo", 2D) = "white" {}
		_Color("Color", Color) = (1,1,1,1)
		_FadeDist("Fade Distance", Float) = 12
		_LerpStart("Lerp start", Float) = -0.5
		_LerpEnd("Lerp end", Float) = 4.5
		_Power("Fade Power",Float) = 2
		_NormalPower("Normal Power", Float) = 1
	}

		SubShader
	{
		Tags { 
			"Queue" = "Transparent" 
			"IgnoreProjector" = "True" 
			"RenderType" = "Transparent" 
			"DisableBatching" = "True" 
			}
			LOD 3000


			Pass
			{
			/*Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			Cull Off*/

			 Cull[_CullEx]
			ZTest[_ZTestEx]

			//ZWrite off
			ZWrite[_ZWriteEx]
			Blend[_SrcBlendEx][_DstBlendEx]

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			CBUFFER_START(UnityPerMaterial)
			float4 _BaseMap_ST;
			fixed4 _Color;
			float _FadeDist;
			float _LerpStart;
			float _LerpEnd;
			float _Power;
			float _NormalPower;
			CBUFFER_END

			struct Input
			{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float2 texcoord     : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct v2f
			{
				float4 pos : SV_POSITION;
				float4 posWS : TEXCOORD0;
				float3 modelPos : TEXCOORD1;
				float3 normal : TEXCOORD2;
				float2 uv	   : TEXCOORD3;
				UNITY_VERTEX_OUTPUT_STEREO
			};

			#define COUNT 8 //you can edit to any number(e.g. 1~32), the lower the faster. Keeping this number a const can enable many compiler optimizations

			v2f vert(Input In)
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID(In);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
				o.pos = UnityObjectToClipPos(In.pos);

				float4 posWS = mul(unity_ObjectToWorld, In.pos);
				o.posWS = posWS;

				float3 f;
				f.x = unity_ObjectToWorld[0].w;
				f.y = unity_ObjectToWorld[1].w;
				f.z = unity_ObjectToWorld[2].w;
				o.modelPos = f;
				
				o.uv = TRANSFORM_TEX(In.texcoord, _BaseMap);
				//o.uv = In.texcoord;

				o.normal = mul((float3x3)unity_ObjectToWorld, In.normal);

				return o;
			}

			void frag(v2f In,float face : VFACE, out fixed4 OUT : SV_Target)
			{
				float fadeStart = 0;
				float fadeEnd = _FadeDist;


				//float d = length(In.posWS.xyz - In.modelPos);
				float d = length(In.posWS.xyz - In.modelPos);
				float fade = 1 - saturate((d - fadeStart) / (fadeEnd - fadeStart));

				fade = pow(fade, _Power);

				float3 dir2Cam = _WorldSpaceCameraPos.xyz - In.posWS.xyz;
				dir2Cam = normalize(dir2Cam);
				float3 normal = In.normal * sign(face);

				float dotVal = max(0.0, dot(normalize(normal), dir2Cam));
				float val = pow(dotVal, _NormalPower);
				fade *= max(0.0f, lerp(_LerpStart, _LerpEnd, val));

				//float uv = 1 - abs((In.uv - 0.5) * 2);
				float uv;
				if (In.uv.y > 0.5)
					uv = 1 - In.uv.y;
				else
					uv = In.uv.y;
				OUT = fixed4(_Color.rgb, _Color.a * fade * uv);
			}

			ENDCG
			}
	}
		Fallback "Transparent/VertexLit"
}
