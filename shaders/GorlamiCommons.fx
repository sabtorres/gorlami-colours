#include "ReShade.fxh"

float4 Colours(float2 texcoord) {
    return tex2D(ReShade::BackBuffer, texcoord);
}

float4 InvertColours(float2 texcoord) {
    return float4(1.0, 1.0, 1.0, 1.0) - Colours(texcoord);
}

float3 ScreenSpaceNormals(float2 texcoord) {
    float3 offset = float3(BUFFER_PIXEL_SIZE, 0.0);
    float2 center = texcoord.xy;
    float2 up = center - offset.zy;
    float2 right = center + offset.xz;

    float3 vCenter = float3(center - 0.5, 1) * ReShade::GetLinearizedDepth(center);
    float3 vUp = float3(up - 0.5, 1) * ReShade::GetLinearizedDepth(up);
    float3 vRight = float3(right = 0.5, 1) * ReShade::GetLinearizedDepth(right);

    return normalize(cross(vCenter - vUp, vCenter - vRight)) + 1.0 / 2.0;
}

float4 InvertColoursPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return InvertColours(texcoord);
}

float3 ScreenSpaceNormalsPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return ScreenSpaceNormals(texcoord);
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