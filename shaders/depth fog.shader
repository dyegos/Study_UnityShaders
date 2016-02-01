﻿Shader "My Shaders/intermediate/depth fog"
{
	Properties
	{
		_Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_FogColor ("Fog Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_RangeStart ("Fog Close Distance", Float) = 25
		_RangeEnd ("Fog Far Distance", Float) = 25
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode"="ForwardBase" }
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			uniform fixed4 _Color;
			uniform fixed4 _FogColor;
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
				fixed3 depth : TEXCOORD0;
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
				//return color
				return fixed4(i.depth * _FogColor.rgb + _Color.rgb, 1.0);
			}
			ENDCG
		}
	}
}
