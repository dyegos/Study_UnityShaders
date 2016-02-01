Shader "My Shaders/intermediate/cubemap refraction"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Cube ("Cube Map Reflaction", Cube) = "" {}
	}

	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			uniform samplerCUBE _Cube;

			uniform half4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
			};

			struct vertexOutput
			{
				half4 vertex : SV_POSITION;
				fixed3 normalDir : TEXCOORD0;
				half3 viewDir : TEXCOORD1;
			};

			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.normalDir = normalize( mul(_World2Object, half4(v.normal, 0.0)).xyz );
				o.viewDir = half3 (mul(_Object2World, v.vertex) - _WorldSpaceCameraPos);
				return o;
			}

			fixed4 frag (vertexOutput i) : COLOR
			{
				//reflect the ray based on the normals to get the coordinates
				half3 refractDir = refract(i.viewDir, i.normalDir, 1/1.5);
				//texture maps
				half4 texC = texCUBE(_Cube, refractDir);

				return texC;
			}
			ENDCG
		}
	}
}
