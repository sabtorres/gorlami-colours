#include "GorlamiUtils.fxh"

/*
UNIFORMS AND DEFINITIONS
*/

static const float DEPTH_THRESHOLD = 0.005;
static const float NORMAL_THRESHOLD = 0.8;
static const float PI = 3.1415;
static const float FLOAT_MAX = 255.0;

uniform int kuwaharaFilter <
    ui_category = "Colours";
    ui_label = "Kuwahara Filter";
    ui_type = "slider";
    ui_min = 0;
    ui_max = 16;
    ui_step = 1;
> = 3;

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

texture blurTex {
    Width = BUFFER_WIDTH;
    Height = BUFFER_HEIGHT;
};

sampler blurSampler {
    Texture = blurTex;
};

float3 LeastVarianceColour(float4 quadrants[4]) {
    int index = 0;
    float minv = FLOAT_MAX;
    for (int i = 0; i < 4; i++) {
        index = quadrants[i].a < minv ? i : index;
        minv = quadrants[i].a < minv ? quadrants[i].a : minv;
    }
    return quadrants[index].rgb;
}

float4 GetQuadrant(int index, float2 texcoord, int2 is, int2 js) {
    float3 sum = 0.0;
    float maxPoint = 0.0;
    float minPoint = FLOAT_MAX;
    for (int i = is.x; i <= is.y; i++) {
        for (int j = js.x; j <= js.y; j++) {
            float2 nCoords = texcoord + ReShade::PixelSize * float2(i, j);
            float3 offsetColour = Colours(nCoords).xyz;
            sum += offsetColour;
            float value = max(offsetColour.x, max(offsetColour.y, offsetColour.z));
            minPoint = min(minPoint, value);
            maxPoint = max(maxPoint, value);
        }
    }
    return float4(sum, maxPoint - minPoint);
}

float4 KuwaharaOperator(float2 texcoord) {
    float ratio = float(kuwaharaFilter + 1) * float(kuwaharaFilter + 1);
    float4 quadrants[4];

    quadrants[0] = GetQuadrant(0, texcoord, int2(-kuwaharaFilter, 0), int2(-kuwaharaFilter, 0));
    quadrants[1] = GetQuadrant(1, texcoord, int2(-kuwaharaFilter, 0), int2(0, kuwaharaFilter));
    quadrants[2] = GetQuadrant(2, texcoord, int2(0, kuwaharaFilter), int2(-kuwaharaFilter, 0));
    quadrants[3] = GetQuadrant(3, texcoord, int2(0, kuwaharaFilter), int2(0, kuwaharaFilter));

    float3 leastVarianceColour = LeastVarianceColour(quadrants) / ratio;
    return float4(leastVarianceColour, 1.0);
}

/*
SHADER PASSES
*/

void PrePS(float4 vpos : SV_Position, in float2 texcoord : TEXCOORD0, out float4 blurTex : SV_Target) {
    if (kuwaharaFilter == 0) {
        blurTex = Colours(texcoord);
    }
    else {
        blurTex = KuwaharaOperator(texcoord);
    }
}

void PostPS(float4 vpos : SV_Position, in float2 texcoord : TEXCOORD0, out float4 pixel : SV_Target) {
    float4 colour = tex2D(blurSampler, texcoord);

    if (freestyleThickness == 0) {
        pixel = colour;
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
                    pixel = float4(0.0, 0.0, 0.0, 1.0);
                    return;
                }
            }
        }
    }

    pixel = colour;
}

technique ToonShader {
    pass {
        VertexShader = PostProcessVS;
        PixelShader = PrePS;
        RenderTarget = blurTex;
    }

    pass {
        VertexShader = PostProcessVS;
        PixelShader = PostPS;
    }
}