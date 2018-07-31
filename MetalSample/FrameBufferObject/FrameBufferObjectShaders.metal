//
//  FrameBufferObjectShaders.metal
//  MetalSample
//
//  Created by izumi on 2018/07/31.
//  Copyright © 2018 izm. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInOut {
    float4 position [[position]];
    float2 texCoords;
};

vertex VertexInOut framebufferobject_vertex(const device packed_float3* vertex_array [[buffer(0)]],
                                            const device float2* texcoord_array [[buffer(1)]],
                                            unsigned int vid [[ vertex_id ]]) {
    VertexInOut out;
    out.position = float4(vertex_array[vid], 1.0);
    out.texCoords = texcoord_array[vid];
    return out;
}

vertex float4 framebufferobject_vertex_fbo(const device packed_float3* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment float4 framebufferobject_fragment(VertexInOut in [[stage_in]],
                                          texture2d<float> texture [[texture(0)]]) {
    constexpr sampler colorSampler;
    return texture.sample(colorSampler, in.texCoords);
    
}

fragment half4 framebufferobject_fragment_fbo() {
    return half4(1.0,0.0,0.0,1.0);
}

