﻿Shader "My Shaders/intermediate/Flat Translucency"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_BackScatter ("Back Translucent Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Translucence ("Forward Translucent Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Float) = 10.0
		_Intencity ("Translucent Intensity", Float) = 10.0
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			//#pragma target 4.0

			uniform fixed4 _Color;
			uniform fixed4 _SpecColor;
			uniform fixed4 _BackScatter;
			uniform fixed4 _Translucence;
			uniform half _Shininess;
			uniform half _Intencity;

			uniform half4 _LightColor0;

			struct vertexInput
			{
				half4 vertex : POSITION;
				half3 normal : NORMAL;
			};

			struct vertexOutput
			{
				half4 pos : SV_POSITION;
				fixed3 normalDir : TEXCOORD0;
				fixed4 lightDir : TEXCOORD1;
				fixed3 viewDir : TEXCOORD2;
			};

			vertexOutput vert (vertexInput v)
			{
				vertexOutput o;

				//unity transform position
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				//normal direction
				o.normalDir = normalize( mul(half4(v.normal, 0.0), _World2Object).xyz );

				//world position
				half4 wordPos = mul(_Object2World, v.vertex);

				//view direction
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - wordPos);

				//light direction
				half3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - wordPos.xyz;

				o.lightDir = fixed4
				(
					normalize( lerp( _WorldSpaceLightPos0.xyz, fragmentToLightSource, _WorldSpaceLightPos0.w) ),
					lerp(1.0, 1.0 / length(fragmentToLightSource), _WorldSpaceLightPos0.w)
				);
				return o;
			}

			fixed4 frag (vertexOutput i) : COLOR
			{
				fixed nDotL = saturate( dot(i.normalDir, i.lightDir.xyz) );
				//diffuse
				fixed3 diffuseReflection =  i.lightDir.w * _LightColor0 * nDotL;
				//specular
				fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * pow( saturate( dot( reflect( -i.lightDir.xyz, i.normalDir), i.viewDir ) ), _Shininess );
				
				//translucence
				fixed3 backScatter = i.lightDir.w * _LightColor0.xyz * _BackScatter.xyz * saturate(dot(i.normalDir, -i.lightDir.xyz));
				fixed3 translucence = i.lightDir.w * _LightColor0.xyz * _Translucence.xyz * pow(saturate(dot(-i.lightDir.xyz, i.viewDir)), _Intencity);
				
				fixed3 lightFinal = backScatter + translucence + specularReflection + diffuseReflection + UNITY_LIGHTMODEL_AMBIENT.xyz;
				
				return fixed4(lightFinal * _Color.xyz, 1.0);
			}
			ENDCG
		}
	}
}
