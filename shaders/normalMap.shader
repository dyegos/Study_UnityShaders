Shader "My Shaders/beguiner/normal map"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1.0,1.0,1.0,1.0)
		_MainTex ("Main Texture", 2D) = "white" {}
		_BumpMap ("Normal Texture", 2D) = "bump" {}
		_BumpDepth ( "Bump Depth", Range(-2.0, 2.0) ) = 1.0
		_SpecColor ( "Specular Color", Color ) = (1.0,1.0,1.0,1.0)
		_Shininess ( "Shininess", Float ) = 10
		_RimColor ( "Rim Color", Color ) = (1.0,1.0,1.0,1.0)
		_RimPower ( "Rim Power", Range(0.1, 10.0) ) = 3.0
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _BumpMap;
			uniform float4 _BumpMap_ST;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _RimPower;
			uniform float _Shininess;
			uniform float _BumpDepth;

			uniform float4 _LightColor0;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;	
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 biNormalWorld : TEXCOORD4;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				o.normalWorld = normalize( mul( float4(v.normal, 0.0), _World2Object ).xyz );
				o.tangentWorld = normalize( mul( _Object2World, v.tangent ).xyz );
				o.biNormalWorld = normalize( cross( o.normalWorld, o.tangentWorld ) * v.tangent.w );

				o.posWorld = mul(_Object2World, v.vertex);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;
				return o;
			}

			float4 frag(vertexOutput i) : COLOR
			{
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld);
				float3 lightDirection;
				float atten;

				if(_WorldSpaceLightPos0.w == 0.0) //direction Lights
				{
					lightDirection = normalize( _WorldSpaceLightPos0.xyz );
					atten = 1.0;
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float dis = length(fragmentToLightSource);
					atten = 1 / dis;
					lightDirection = normalize(fragmentToLightSource);
				}

				//textures
				float4 tex = tex2D(_MainTex, i.tex.xy * _MainTex_ST.xy + _MainTex_ST.zw);
				float4 normalTex = tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

				//unpack normal
				float3 localCoords = float3(2.0 * normalTex.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _BumpDepth;

				//normal tranpos matrix
				float3x3 local2WorldTranpose = float3x3
				(
					i.tangentWorld,
					i.biNormalWorld,
					i.normalWorld
				);

				//calculate normal direction
				float3 normalDirection = normalize( mul( localCoords, local2WorldTranpose ) );

				//Lighting
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.xyz * pow( saturate( dot( reflect( -lightDirection, normalDirection), viewDirection ) ), _Shininess );
				//rim lighting
				float rim = 1 - saturate( dot( viewDirection, normalDirection ) );
				float3 rimLighting = saturate( dot( viewDirection, normalDirection ) * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower) );

				float3 lightFinal = UNITY_LIGHTMODEL_AMBIENT.xyz + diffuseReflection + specularReflection + rimLighting;

				return float4(tex.xyz * lightFinal * _Color.rgb, 1.0);
			}

			ENDCG
		}

		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }
			Blend One One
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			uniform sampler2D _BumpMap;
			uniform float4 _BumpMap_ST;
			uniform sampler2D _MainTex;
			uniform float4 _MainTex_ST;
			uniform float4 _Color;
			uniform float4 _SpecColor;
			uniform float4 _RimColor;
			uniform float _RimPower;
			uniform float _Shininess;
			uniform float _BumpDepth;

			uniform float4 _LightColor0;

			struct vertexInput
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 texcoord : TEXCOORD0;
				float4 tangent : TANGENT;	
			};
			struct vertexOutput
			{
				float4 pos : SV_POSITION;
				float4 tex : TEXCOORD0;
				float4 posWorld : TEXCOORD1;
				float3 normalWorld : TEXCOORD2;
				float3 tangentWorld : TEXCOORD3;
				float3 biNormalWorld : TEXCOORD4;
			};

			vertexOutput vert(vertexInput v)
			{
				vertexOutput o;

				o.normalWorld = normalize( mul( float4(v.normal, 0.0), _World2Object ).xyz );
				o.tangentWorld = normalize( mul( _Object2World, v.tangent ).xyz );
				o.biNormalWorld = normalize( cross( o.normalWorld, o.tangentWorld ) * v.tangent.w );

				o.posWorld = mul(_Object2World, v.vertex);
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.tex = v.texcoord;
				return o;
			}

			float4 frag(vertexOutput i) : COLOR
			{
				float3 viewDirection = normalize( _WorldSpaceCameraPos.xyz - i.posWorld);
				float3 lightDirection;
				float atten;

				if(_WorldSpaceLightPos0.w == 0.0) //direction Lights
				{
					lightDirection = normalize( _WorldSpaceLightPos0.xyz );
					atten = 1.0;
				}
				else
				{
					float3 fragmentToLightSource = _WorldSpaceLightPos0.xyz - i.posWorld.xyz;
					float dis = length(fragmentToLightSource);
					atten = 1 / dis;
					lightDirection = normalize(fragmentToLightSource);
				}

				//textures
				float4 normalTex = tex2D(_BumpMap, i.tex.xy * _BumpMap_ST.xy + _BumpMap_ST.zw);

				//unpack normal
				float3 localCoords = float3(2.0 * normalTex.ag - float2(1.0, 1.0), 0.0);
				localCoords.z = _BumpDepth;

				//normal tranpos matrix
				float3x3 local2WorldTranpose = float3x3
				(
					i.tangentWorld,
					i.biNormalWorld,
					i.normalWorld
				);

				//calculate normal direction
				float3 normalDirection = normalize( mul( localCoords, local2WorldTranpose ) );

				//Lighting
				float3 diffuseReflection = atten * _LightColor0.xyz * saturate(dot(normalDirection, lightDirection));
				float3 specularReflection = diffuseReflection * _SpecColor.xyz * pow( saturate( dot( reflect( -lightDirection, normalDirection), viewDirection ) ), _Shininess );
				//rim lighting
				float rim = 1 - saturate( dot( viewDirection, normalDirection ) );
				float3 rimLighting = saturate( dot( lightDirection, normalDirection ) * _RimColor.xyz * _LightColor0.xyz * pow(rim, _RimPower) );

				float3 lightFinal = diffuseReflection + specularReflection + rimLighting;

				return float4(lightFinal * _Color.rgb, 1.0);
			}

			ENDCG
		}
	}

	//FallBack "Diffuse"
}
