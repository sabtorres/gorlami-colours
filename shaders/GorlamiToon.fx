#include "GorlamiUtils.fxh"

/*
UNIFORMS
*/

static const float DEPTH_THRESHOLD = 0.005;
static const float NORMAL_THRESHOLD = 0.5;
static const float PI = 3.1415;

uniform float colorFlattenFactor <
    ui_category = "Colours";
    ui_type = "slider";
    ui_label = "Color Flatten Factor";
    ui_min = 0.01;
    ui_max = 0.3;
    ui_step = 0.01;
> = 0.05;

uniform float saturationMultiplier <
    ui_category = "Colours";
    ui_type = "slider";
    ui_label = "Saturation Multiplier";
    ui_min = 0.0;
    ui_max = 3.0;
    ui_step = 0.01;
> = 1.5;

uniform int surfaceBlur <
    ui_category = "Colours";
    ui_label = "Blur";
    ui_type = "slider";
    ui_min = 0;
    ui_max = 16;
    ui_step = 1;
> = 3;

uniform int shadingSteps <
    ui_category = "Colours";
    ui_label = "Shading steps";
    ui_type = "slider";
    ui_min = 1;
    ui_max = 255;
    ui_step = 1;
> = 16;

uniform bool dither <
    ui_category = "Colours";
    ui_label = "Dither";
> = false;

uniform int freestyleThickness <
    ui_category = "Freestyle";
    ui_type = "slider";
    ui_label = "Freestyle Thickness";
    ui_min = 0;
    ui_max = 16;
    ui_step = 1;
> = 3;

uniform float threshold <
    ui_category = "Freestyle";
    ui_type = "slider";
    ui_label = "Threshold";
    ui_min = 0.0;
    ui_max = 1.0;
    ui_step = 0.005;
> = 0.995;

/*
UTILITY
*/

texture normalTex {
    Width = BUFFER_WIDTH;
    Height = BUFFER_HEIGHT;
};

sampler normalSampler {
    Texture = normalTex;
};

texture blurTex {
    Width = BUFFER_WIDTH;
    Height = BUFFER_HEIGHT;
};

sampler blurSampler {
    Texture = blurTex;
};


float3 FlattenColours(float2 texcoord) {
    float3 colour = RGBtoHSL(Colours(texcoord).xyz);
    float incidence = dot(ScreenSpaceNormals(texcoord), float3(1.0, 0.0, 1.0));
    float invFactor = 1.0 / colorFlattenFactor; //* (exp2(-ScreenSpaceDepth(texcoord)) - 1.0 * 2.0);

    float colourOffsetY = (round(colour.y * invFactor) - (colour.y * invFactor)) / invFactor;
    float colourOffsetZ = (round(colour.z * invFactor) - (colour.z * invFactor)) / invFactor;

    float3 colourOffset = float3(0.0, colourOffsetY, colourOffsetZ);

    return HSLtoRGB(colour + colourOffset);
}

/*
SHADER PASSES
*/

void PrePassPS(float4 vpos : SV_Position, in float2 texcoord : TEXCOORD0, out float4 outNormal : SV_Target, out float4 outBlur : SV_Target1) {
    outNormal = ScreenSpaceNormals(texcoord);

    if (surfaceBlur == 0) {
        outBlur = FlattenColours(texcoord);
    }
    else {
        int count = 0;
        float depth = ScreenSpaceDepth(texcoord);
        int2 offset = int2(-surfaceBlur, -surfaceBlur);

        float4 average = float4(0.0, 0.0, 0.0, 0.0);
        int maxDistance = surfaceBlur * surfaceBlur;

        for (; offset.x <= surfaceBlur; offset.x++) {
            for (offset.y = -surfaceBlur; offset.y <= surfaceBlur; offset.y++) {
                float2 nCoords = texcoord + ReShade::PixelSize * offset;
                float pixelDepth = ScreenSpaceDepth(nCoords);
                if (dot(offset, offset) <= maxDistance && abs(depth - pixelDepth) <= DEPTH_THRESHOLD) {
                    average += FlattenColours(nCoords);
                    count++;
                }
            }
        }

        outBlur = average / count;
    }
}

float4 PostPS(float4 vpos : SV_Position, in float2 texcoord : TEXCOORD0) : SV_Target{
    if (freestyleThickness == 0) {
        return tex2D(blurSampler, texcoord);
    }
    else {
        int maxDistance = freestyleThickness * freestyleThickness;
        float depth = ScreenSpaceDepth(texcoord);
        float3 normal = ScreenSpaceNormals(texcoord);

        int2 offset;
        for (offset.x = -freestyleThickness; offset.x <= freestyleThickness; offset.x++) {
            for (offset.y = -freestyleThickness; offset.y <= freestyleThickness; offset.y++) {
                float2 nCoords = texcoord + ReShade::PixelSize * offset;
                float3 pixelNormal = ScreenSpaceNormals(nCoords);
                float pixelDepth = ScreenSpaceDepth(nCoords);
                if(dot(offset, offset) <= maxDistance
                && abs(depth / pixelDepth) <= threshold
                && dot(normal, pixelNormal) >= NORMAL_THRESHOLD) {
                    return float4(0.0, 0.0, 0.0, 1.0);
                }
            }
        }
    }

    return tex2D(blurSampler, texcoord);
}

float3 FlattenPS(float4 vpos : SV_Position, float2 texcoord : TexCoord) : SV_Target {
    return FlattenColours(texcoord);
}

// technique TEST_Flatten {
//     pass {
//         VertexShader = PostProcessVS;
//         PixelShader = FlattenPS;
//     }
// }

technique ToonShader {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = PrePassPS;
        RenderTarget = normalTex;
        RenderTarget1 = blurTex;
    }

    pass {
        VertexShader = PostProcessVS;
        PixelShader = PostPS;
    }
}