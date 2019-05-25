Shader "Custom/Shader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}
		SubShader
	{
		Tags { "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			//The compute buffer. Access is from script via Material.SetBuffer(<name>,...), 
			// where <name> is the name of the var here, i.e. 'buffer'
			//Figured out from https://forum.unity.com/threads/rwstructuredbuffer-in-vertex-shader.406592/
			//'register'
			// - seems optional, i.e. I can remove it and still compiles and runs.
			// - does using it mean the data is stored in a faster-access register on gpu?
			// - https://gamedev.stackexchange.com/questions/55319/what-are-registers-in-hlsl-for
			// - https://docs.microsoft.com/en-us/windows/desktop/direct3dhlsl/dx-graphics-hlsl-variable-register
			// - unity compilar says this requires a 't' register, which MS docs say is 'texture and texture buffer'. 
			//    Note that 'b' for 'Constant buffer', and it doesn't work, compiler complains.
			// - since we're reading from different addresses in the buffer from each thread, it seems
			//    the unstructured 't' buffer is the right one, compared with constant buffer:
			//    "Structured buffers on the other hand utilize the unified cache architecture, which means the first read is slow, but all subsequent reads are very fast (if the requested data is already in the cache)."
			//    https://www.gamedev.net/forums/topic/624529-structured-buffers-vs-constant-buffers/
			//
			uniform StructuredBuffer<float> buffer : register(t1);

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;

				//This can be used by the compute buffer to index its
				// values by vertex index, if your buffer is storing some
				// values for each vertex.
				uint id : SV_VertexID;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				UNITY_FOG_COORDS(1)
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			
			v2f vert (appdata v)
			{
				v2f o;
				
				////
				//Scale the object based on buffer values.
				//The rest of the code here and in frag is standard stuff.
				v.vertex *= float4(buffer[0], buffer[1], buffer[2], 1.0);
				
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				UNITY_TRANSFER_FOG(o,o.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv);
				return col;
			}
			ENDCG
		}
	}
}
