#include "ReShade.fxh"

float4 InvertPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return float4(1.0, 1.0, 1.0, 1.0) - tex2D(ReShade::BackBuffer, texcoord);
}

technique InvertColours {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = InvertPS;
    }
}