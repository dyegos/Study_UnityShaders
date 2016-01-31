Shader "My Shaders/intermediate/transparent map"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_TransMap ("Transparency (A)", 2D) = "white" {}
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Blend srcAlpha OneMinusSrcAlpha
		Pass
		{
			CULL off
			zWrite off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform fixed4 _Color;
			uniform sampler2D _TransMap;
			uniform half4 _TransMap_ST;

			uniform half4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
				half4 texcoord : TEXCOORD0;
			};

			struct vertexOutput
			{
				half4 vertex : SV_POSITION;
				half4 tex : TEXCOORD0;
			};

			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;

				return o;
			}

			fixed4 frag (vertexOutput i) : COLOR
			{
				//textures
				fixed4 tex = tex2D(_TransMap, i.tex.xy * _TransMap_ST.xy + _TransMap_ST.zw);
				//calculate the alpha
				fixed alpha = tex.a * _Color.a;

				return fixed4(_Color.rgb, alpha);
			}
			ENDCG
		}
	}
}
