#include "GorlamiUtils.fxh"

float4 InvertColoursPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return InvertColours(texcoord);
}

float3 ScreenSpaceNormalsPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return ScreenSpaceNormals(texcoord);
}

float3 ScreenSpaceDepthPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    float depth = ScreenSpaceDepth(texcoord);
    return float3(depth, depth, depth);
}

technique InvertColours {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = InvertColoursPS;
    }
}

technique ShowNormals {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = ScreenSpaceNormalsPS;
    }
}

technique ShowDepth {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = ScreenSpaceDepthPS;
    }
}