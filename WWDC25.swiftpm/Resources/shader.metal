#include <metal_stdlib>
using namespace metal;

// Definição do input do vértice (o que vem da cena, como posição e coordenadas de textura)
struct VertexIn {
    float4 position [[attribute(0)]];  // Posição do vértice
    float2 texCoord [[attribute(1)]];  // Coordenadas de textura
};

// Definição do output do vértice (o que será passado para o estágio de fragmento)
struct VertexOut {
    float4 position [[position]];  // Posição transformada para o estágio de fragmento
    float2 texCoord [[user(texcoord)]];  // Coordenadas de textura
};

// Definição da nova estrutura de posições dos dedos
struct FingerPositions {
    float3 indexTip;
    float3 middleTip;
    float3 ringTip;
};

// Função do estágio de vértice (transformação do vértice)
vertex VertexOut vertexShader(VertexIn in [[stage_in]], constant float4x4 &modelViewProjection [[buffer(0)]]) {
    VertexOut out;

    // Transforma a posição do vértice com a matriz de modelagem/view/projeção
    out.position = modelViewProjection * in.position;
    out.texCoord = in.texCoord;  // Passa as coordenadas de textura para o próximo estágio

    return out;
}

// Função do estágio de fragmento (calcula a cor do fragmento)
fragment float4 fragmentShader(VertexOut in [[stage_in]], texture2d<float> texture [[texture(0)]], constant FingerPositions& fingerPositions [[buffer(1)]]) {
    // Posição do fragmento no espaço 3D (assumindo que é 2D para este exemplo)
    float3 fragPos = float3(in.position.x, in.position.y, 0.0);

    // Define minDistance como -1000 diretamente no shader
    float minDistance = 0.1;

    // Calcula as distâncias dos 3 pontos em relação à posição do fragmento
    float distToIndex = length(fragPos - fingerPositions.indexTip);
    float distToMiddle = length(fragPos - fingerPositions.middleTip);
    float distToRing = length(fragPos - fingerPositions.ringTip);

    // Se alguma das distâncias for menor que minDistance, torna o fragmento transparente
    float transparency = 1.0;
    if (distToIndex < minDistance || distToMiddle < minDistance || distToRing < minDistance) {
        transparency = 0.0;
    }

    // Obtém a cor da textura
    float4 textureColor = texture.sample(sampler(filter::linear), in.texCoord);

    // Aplica a transparência à cor final do fragmento
    return float4(textureColor.rgb, textureColor.a * transparency);
}
