#include "GorlamiHeader.fxh"

float4 Colours(float2 texcoord) {
    return tex2D(ReShade::BackBuffer, texcoord);
}

float4 InvertColours(float2 texcoord) {
    return float4(1.0, 1.0, 1.0, 1.0) - Colours(texcoord);
}

float ScreenSpaceDepth(float2 texcoord) {
    if (iUIUpsideDown) {
        texcoord.y = 1.0 - texcoord.y;
    }

    float depth = tex2Dlod(ReShade::DepthBuffer, float4(texcoord, 0.0, 0.0)).x * depthMultiplier;

    const float c = 0.01;
    if (iUILogarithmic) {
        depth = (exp(depth * log(1.0 + c)) - 1.0) / c;
    }

    if (iUIReversed) {
        depth = 1.0 - depth;
    }

    depth /= farPlane - depth * (farPlane - 1.0);
    return depth;
}

float3 ScreenSpaceNormals(float2 texcoord) {
    float3 offset = float3(BUFFER_PIXEL_SIZE, 0.0);
    float2 center = texcoord.xy;
    float2 up = center - offset.zy;
    float2 right = center + offset.xz;

    float3 vCenter = float3(center - 0.5, 1) * ScreenSpaceDepth(center);
    float3 vUp = float3(up - 0.5, 1) * ScreenSpaceDepth(up);
    float3 vRight = float3(right = 0.5, 1) * ScreenSpaceDepth(right);

    return normalize(cross(vCenter - vUp, vCenter - vRight)) + 1.0 / 2.0;
}