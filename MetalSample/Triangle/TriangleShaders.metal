//
//  TriangleShaders.metal
//  MetalSample
//
//  Created by Ryo Izumi on 2018/07/22.
//  Copyright © 2018年 izm. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 triangle_vertex(const device packed_float3* vertex_array [[ buffer(0) ]], unsigned int vid [[ vertex_id ]]) {
    return float4(vertex_array[vid], 1.0);
}


fragment half4 triangle_fragment() {
    return half4(1.0,0.0,0.0,1.0);
}

