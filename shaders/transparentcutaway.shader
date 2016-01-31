Shader "My Shaders/intermediate/transparent cutaway"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Height ("Cutoff Height", Range(-1.0, 1.0)) = 1.0
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Pass
		{
			CULL off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;
			fixed _Height;

			uniform half4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
			};

			struct vertexOutput
			{
				half4 vertex : SV_POSITION;
				half4 vertPos : TEXCOORD0;
			};

			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;

				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.vertPos = v.vertex;

				return o;
			}

			fixed4 frag (vertexOutput i) : COLOR
			{
				if(i.vertPos.y > _Height)
				{
					discard;
				}
				return _Color;
			}
			ENDCG
		}
	}
}
