Shader "LearningShaders/5b - Point Lights"
{
	Properties
	{
		_Color ( "Color", Color ) = (1.0, 1.0, 1.0, 1.0)
		_SpecColor ( "Specular Color", Color ) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ( "Shininess", Float ) = 10
		_RimColor ( "Rim Color", Color ) = (1.0, 1.0, 1.0, 1.0)
		_RimPower ( "RimPower", Range(0.1, 10.0) ) = 3.0
	}
	
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "forwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float4 _RimColor;
			uniform float _RimPower;
			
			uniform float4 _LightColor0;
			
			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
			};
			
			
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				
				o.posWorld = mul( _Object2World, v.vertex );
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
				o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
				return o;
			}
			
			float4 frag(vertexOutput i) : COLOR
			{
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz );
				float3 lightDirection;
				float atten;
				
				if (_WorldSpaceLightPos0.w == 0.0) //directional lights
				{
					atten = 1.0;
					lightDirection = normalize( _WorldSpaceLightPos0.xyz );
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float dis = length(fragmentToLightSource);
					atten = 1 / dis;
					lightDirection = normalize( fragmentToLightSource );
				}
				
				//lighting
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate( dot ( lightDirection, normalDirection ) );
				float3 specularReflection = atten * _LightColor0.xyz * saturate( dot ( lightDirection, normalDirection ) ) * pow( saturate( dot( reflect(-normalDirection, lightDirection), viewDirection ) ), _Shininess );
				
				//rim light
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection) );
				float3 rimlighting = atten * _LightColor0.rgb * _RimColor * saturate( dot(normalDirection, lightDirection) ) * pow(rim, _RimPower);
				
				float3 lightFinal = rimlighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
				
				return float4(lightFinal * _Color.rgb, 1.0);
			}
			
			ENDCG
		}
		
		Pass
		{
			Tags { "LightMode" = "forwardAdd" }
			Blend One One
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag
			
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float _Shininess;
			uniform float4 _RimColor;
			uniform float _RimPower;
			
			uniform float4 _LightColor0;
			
			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};
			
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 posWorld : TEXCOORD0;
				float3 normalDir : TEXCOORD1;
			};
			
			
			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;
				
				o.posWorld = mul( _Object2World, v.vertex );
				o.normalDir = normalize( mul( float4(v.normal, 0.0), _World2Object).xyz );
				o.pos = mul( UNITY_MATRIX_MVP, v.vertex );
				return o;
			}
			
			float4 frag(vertexOutput i) : COLOR
			{
				float3 normalDirection = i.normalDir;
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld.xyz );
				float3 lightDirection;
				float atten;
				
				if (_WorldSpaceLightPos0.w == 0.0) //directional lights
				{
					atten = 1.0;
					lightDirection = normalize( _WorldSpaceLightPos0.xyz );
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float dis = length(fragmentToLightSource);
					atten = 1 / dis;
					lightDirection = normalize( fragmentToLightSource );
				}
				
				//lighting
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate( dot ( lightDirection, normalDirection ) );
				float3 specularReflection = atten * _LightColor0.xyz * saturate( dot ( lightDirection, normalDirection ) ) * pow( saturate( dot( reflect(-normalDirection, lightDirection), viewDirection ) ), _Shininess );
				
				//rim light
				float rim = 1 - saturate(dot(normalize(viewDirection), normalDirection) );
				float3 rimlighting = atten * _LightColor0.rgb * _RimColor * saturate( dot(normalDirection, lightDirection) ) * pow(rim, _RimPower);
				
				float3 lightFinal = rimlighting + diffuseReflection + specularReflection + UNITY_LIGHTMODEL_AMBIENT.rgb;
				
				return float4(lightFinal * _Color.rgb, 1.0);
			}
			
			ENDCG
		}
	}
	
	//Fallback "Diffuse"
}
