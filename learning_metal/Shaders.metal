//
//  Shaders.metal
//  learning_metal
//
//  Created by Krishna Addepalli on 08/01/19.
//  Copyright © 2019 Oracle. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

/*
 This vertex shader receives two parameters. The first parameter is the position
 of each vertex. The [[buffer(0)]] code specifies to the vertex shader to pull
 its data from the first vertex buffer sent to the shader. Because for now only
 one vertex buffer is created, it's easy to figure out which one comes first.
 The second parameter is the index of the vertex within the vertex array.
 */
vertex float4 basic_vertex( const device packed_float3* vertex_array [[ buffer(0) ]],
                            unsigned int vid [[ vertex_id ]])
{
    return float4(vertex_array[vid], 1.0);
}

fragment half4 basic_fragment()
{
    return half4(1.0);
}
