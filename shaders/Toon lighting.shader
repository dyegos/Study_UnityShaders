Shader "My Shaders/intermediate/Toon Lighting"
{
	Properties
	{
		_Color ("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)
		_UnlitColor ("Unlit Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_DiffuseThreShold ("Deffise ThreShold", Range(-1.1, 1)) = 0.1
		_Diffusion ("Diffusion", Range(0.0, 0.99)) = 0.0
		_SpecColor ("Specular Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Shininess ("Shininess", Range(0.5, 1)) = 0.5
		_SpecDiffusion ("Specular Diffusion", Range(0.0, 0.99)) = 0.0
	}

	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardBase" }
			
			CGPROGRAM
			
			#pragma vertex vert
			#pragma fragment frag

			uniform fixed4 _Color;
			uniform fixed4 _UnlitColor;
			uniform fixed _DiffuseThreShold;
			uniform fixed _Diffusion;
			uniform fixed4 _SpecColor;
			uniform fixed _Shininess;
			uniform half _SpecDiffusion;
			

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

				//normal direction
				o.normalDir = normalize( mul(half4(v.normal, 0.0), _World2Object).xyz );

				//unity transform position
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				
				//world position
				half4 wordPos = mul(_Object2World, v.vertex);

				//view direction
				o.viewDir = normalize(_WorldSpaceCameraPos.xyz - wordPos.xyz);

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
				
				fixed diffuseCutoff = saturate( (max(_DiffuseThreShold, nDotL) - _DiffuseThreShold) * pow( (2 - _Diffusion), 10 ) );
				fixed specularCutoff = saturate( (max(_Shininess, dot( reflect( -i.lightDir.xyz, i.normalDir), i.viewDir )) - _Shininess) * pow( (2 - _SpecDiffusion), 10 ) );
				
				fixed3 ambientLight = (1 - diffuseCutoff) * _UnlitColor.xyz;
				fixed3 diffuseReflection = (1 - specularCutoff) * _Color.xyz * diffuseCutoff;
				fixed3 specularReflection = _SpecColor.xyz * specularCutoff;
				
				//diffuse
				//fixed3 diffuseReflection =  i.lightDir.w * _LightColor0 * nDotL;
				//specular
				//fixed3 specularReflection = diffuseReflection * _SpecColor.xyz * pow( saturate( dot( reflect( -i.lightDir.xyz, i.normalDir), i.viewDir ) ), _Shininess );
				
				fixed3 lightFinal = ambientLight + diffuseReflection + specularReflection;
				
				return fixed4(lightFinal, 1.0);
			}
			ENDCG
		}
	}
}
