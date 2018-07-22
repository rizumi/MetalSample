//
//  UniformShaders.metal
//  MetalSample
//
//  Created by Ryo Izumi on 2018/07/22.
//  Copyright © 2018年 izm. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexInOut {
    float4 position [[position]];
    float4 color;
};

vertex VertexInOut uniform_vertex(const device packed_float3* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    // return float4(vertex_array[vid], 1.0);
    VertexInOut out;
    out.position = float4(vertex_array[vid],1.0);
    out.color = float4(0.0,0.0,1.0,1.0);
    
    return out;
}


fragment half4 uniform_fragment(VertexInOut vertexIn [[stage_in]],
                              constant float &time [[buffer(0)]]) {
    return half4(sin(time),0.0,0.0,1.0);
    // return half4(vertexIn.color);
}
