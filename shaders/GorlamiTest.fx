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

float3 FlattenPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return FlattenColours(texcoord);
}

technique TEST_InvertColours {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = InvertColoursPS;
    }
}

technique TEST_ShowNormals {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = ScreenSpaceNormalsPS;
    }
}

technique TEST_ShowDepth {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = ScreenSpaceDepthPS;
    }
}

technique TEST_Flatten {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = FlattenPS;
    }
}