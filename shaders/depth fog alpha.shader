Shader "My Shaders/intermediate/depth fog alpha"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RangeStart ("Fog Close Distance", Float) = 25
		_RangeEnd ("Fog Far Distance", Float) = 25
	}

	SubShader
	{
		Tags { "Queue" = "Transparent" }
		Blend OneMinusSrcAlpha srcAlpha
		Pass
		{
			CULL off
			zWrite off
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform fixed4 _Color;
			uniform half _RangeStart;
			uniform half _RangeEnd;

			uniform half4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
			};

			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				fixed depth : TEXCOORD0;
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

				return o;
			}

			fixed4 frag (vertexOutput i) : COLOR
			{
				fixed alpha = _Color.a * i.depth;
				//return color
				return fixed4(_Color.rgb, alpha);
			}
			ENDCG
		}
	}
}
