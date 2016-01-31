Shader "My Shaders/intermediate/Depth of Field"
{
	Properties
	{
		_MainTex ("Diffuse Texture" , 2D) = "white" {}
		_BlurTex ("Blur Texture", 2D) = "white" {}
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_FogColor ("Fog Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RangeStart ("Fog Close Distance", Float) = 25
		_RangeEnd ("Fog Far Distance", Float) = 25
		_BlurSize ("Blur Size", Range(0.0, 1.0)) = 1
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_ST;
			uniform sampler2D _BlurTex;
			uniform half4 _BlurTex_ST;
			uniform fixed4 _Color;
			uniform fixed4 _FogColor;
			uniform half _RangeStart;
			uniform half _RangeEnd;
			uniform fixed _BlurSize;

			uniform half4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
				half4 texcoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				fixed depth : TEXCOORD0;
				half4 tex : TEXCOORD1;
			};

			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;

				//unity transform position
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				//world position
				fixed3 posWorld = mul(_Object2World, v.vertex);
				
				//calculate z-depth
				half dist = distance(posWorld, _WorldSpaceCameraPos.xyz);
				//clamp z-depth to range
				o.depth = saturate((dist - _RangeStart) / _RangeEnd);

				o.tex = v.texcoord;

				return o;
			}

			fixed4 frag (vertexOutput i) : COLOR
			{
				//textures
				fixed4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				fixed4 blurTex = tex2D(_BlurTex, i.tex.xy * _BlurTex_ST.xy + _BlurTex_ST.zw);

				//lerp based on distance
				fixed4 colorBlur = lerp(tex, blurTex, i.depth * _BlurSize);
				
				//return color
				return fixed4(colorBlur * _Color.rgb + i.depth * _FogColor.rgb, 1.0);
			}
			ENDCG
		}
	}
}
