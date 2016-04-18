#line 1

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//======================================================================================
// Vertex shader attributes and uniforms
//======================================================================================
#ifdef WR_VERTEX_SHADER
    // Attribute inputs
#endif

//======================================================================================
// Fragment shader attributes and uniforms
//======================================================================================
#ifdef WR_FRAGMENT_SHADER
    //uniform sampler2D sTiling;
    //uniform vec4 uInitialColor;
#endif

//======================================================================================
// Shared uniforms
//======================================================================================
//uniform int uCommandCount;

//======================================================================================
// Interpolator definitions
//======================================================================================

varying vec2 vUv;
flat varying vec4 vColor;

varying vec4 vBlendingPos[6];
flat varying uvec4 vBlendingColor[2];
flat varying vec4 vBlendingRect[6];

//======================================================================================
// Shared types and constants
//======================================================================================
#define PRIM_KIND_RECT      uint(0)
#define PRIM_KIND_IMAGE     uint(1)
#define PRIM_KIND_GRADIENT  uint(2)
#define PRIM_KIND_TEXT      uint(3)
#define PRIM_KIND_INVALID   uint(4)

//======================================================================================
// Shared types and UBOs
//======================================================================================

//======================================================================================
// VS only types and UBOs
//======================================================================================
#ifdef WR_VERTEX_SHADER

struct Primitive {
    vec4 rect;
    vec4 st;
    vec4 color;
    uvec4 info;
};

struct Layer {
    mat4 transform;
    mat4 inv_transform;
    vec4 screen_vertices[4];
};

struct Command {
    uvec4 prim_indices[2];
    uvec4 layer_indices[2];
};

layout(std140) uniform Layers {
    Layer layers[16];
};

layout(std140) uniform Commands {
    Command commands[16];
};

layout(std140) uniform Primitives {
    Primitive primitives[16];
};

#endif

//======================================================================================
// Shared functions
//======================================================================================

//======================================================================================
// VS only functions
//======================================================================================
#ifdef WR_VERTEX_SHADER

#define INVALID_PRIM_INDEX      uint(0xffffffff)

vec2 write_simple_vertex(vec4 rect, mat4 transform) {
    vec4 pos = vec4(mix(rect.xy, rect.zw, aPosition.xy), 0, 1);
    gl_Position = uTransform * transform * pos;
    return pos.xy;
}

uint pack_color(vec4 color) {
    uint r = uint(color.r * 255.0) <<  0;
    uint g = uint(color.g * 255.0) <<  8;
    uint b = uint(color.b * 255.0) << 16;
    uint a = uint(color.a * 255.0) << 24;
    return r | g | b | a;
}

bool ray_plane(vec3 normal, vec3 point, vec3 ray_origin, vec3 ray_dir, out float t)
{
    float denom = dot(normal, ray_dir);
    if (denom > 1e-6) {
        vec3 d = point - ray_origin;
        t = dot(d, normal) / denom;
        return t >= 0.0;
    }

    return false;
}

vec4 untransform(vec2 ref, vec3 n, vec3 a, mat4 inv_transform) {
    vec3 p = vec3(ref, -100.0);
    vec3 d = vec3(0, 0, 1.0);

    float t;
    ray_plane(n, a, p, d, t);
    vec3 c = p + d * t;

    vec4 r = inv_transform * vec4(c, 1.0);
    return vec4(r.xyz / r.w, r.w);
}

vec3 get_layer_pos(vec2 pos, uint layer_index) {
    Layer layer = layers[layer_index];
    vec3 a = layer.screen_vertices[0].xyz / layer.screen_vertices[0].w;
    vec3 b = layer.screen_vertices[3].xyz / layer.screen_vertices[3].w;
    vec3 c = layer.screen_vertices[2].xyz / layer.screen_vertices[2].w;
    vec3 n = normalize(cross(b-a, c-a));
    vec4 local_pos = untransform(pos, n, a, layer.inv_transform);
    return local_pos.xyw;
}

void write_rect(int location, uint prim_index, uint layer_index, vec2 pos) {
    Primitive prim = primitives[prim_index];
    // TODO(gw): This can be simplified if VS time becomes a bottleneck!
    vec3 layer_pos = get_layer_pos(pos, layer_index);
    vBlendingPos[location].xyz = layer_pos;
    vBlendingColor[location].x = pack_color(prim.color);
    vBlendingRect[location] = prim.rect;
}

void write_generic(int location, uint prim_index, uint layer_index, vec2 pos, out uint out_color) {
    if (prim_index == INVALID_PRIM_INDEX) {
        vBlendingPos[location].w = float(PRIM_KIND_INVALID);
    } else {
        Primitive prim = primitives[prim_index];
        uint prim_kind = prim.info.x;

        // TODO(gw): This can be simplified if VS time becomes a bottleneck!
        vec3 layer_pos = get_layer_pos(pos, layer_index);

        vBlendingPos[location].w = float(prim_kind);

        switch (prim_kind) {
            case PRIM_KIND_RECT: {
                vBlendingPos[location].xyz = layer_pos;
                out_color = pack_color(prim.color);
                vBlendingRect[location] = prim.rect;
                break;
            }
            case PRIM_KIND_TEXT: {
                vec2 f = (layer_pos.xy - prim.rect.xy) / (prim.rect.zw - prim.rect.xy);
                vec2 interp_uv = mix(prim.st.xy, prim.st.zw, f * layer_pos.z);
                vBlendingPos[location].xyz = vec3(interp_uv, layer_pos.z);
                out_color = pack_color(prim.color);
                vBlendingRect[location] = prim.st;
                break;
            }
            case PRIM_KIND_IMAGE: {
                vec2 f = (layer_pos.xy - prim.rect.xy) / (prim.rect.zw - prim.rect.xy);
                vec2 interp_uv = mix(prim.st.xy, prim.st.zw, f * layer_pos.z);
                vBlendingPos[location].xyz = vec3(interp_uv, layer_pos.z);
                out_color = pack_color(prim.color);
                vBlendingRect[location] = prim.st;
                break;
            }
        }
    }
}

void vs(vec2 pos, Command cmd, Primitive main_prim);

void main() {
    Command cmd = commands[gl_InstanceID];

    uint main_prim_index = cmd.prim_indices[0].x;
    uint main_layer_index = cmd.layer_indices[0].x;

    Primitive main_prim = primitives[main_prim_index];
    Layer main_layer = layers[main_layer_index];

    vec2 pos = write_simple_vertex(main_prim.rect, main_layer.transform);

    vs(pos, cmd, main_prim);
}
#endif

//======================================================================================
// FS only functions
//======================================================================================
#ifdef WR_FRAGMENT_SHADER

vec4 fetch_initial_color() {
    return vec4(1,1,1,1);
    //return uInitialColor;
}

vec4 unpack_color(uint color) {
    float r = float(color & uint(0x000000ff)) / 255.0;
    float g = float((color & uint(0x0000ff00)) >> 8) / 255.0;
    float b = float((color & uint(0x00ff0000)) >> 16) / 255.0;
    float a = float((color & uint(0xff000000)) >> 24) / 255.0;
    return vec4(r, g, b, a);
}

bool point_in_rect(vec2 p, vec2 p0, vec2 p1) {
    return p.x >= p0.x &&
           p.y >= p0.y &&
           p.x <= p1.x &&
           p.y <= p1.y;
}

vec4 handle_prim(int location, uint packed_color) {
    uint kind = uint(vBlendingPos[location].w);
    vec4 result = vec4(0, 0, 0, 0);

    vec2 rect_pos = vBlendingPos[location].xy / vBlendingPos[location].z;
    vec4 rect_rect = vBlendingRect[location];

    if (point_in_rect(rect_pos, rect_rect.xy, rect_rect.zw)) {
        vec4 color = unpack_color(packed_color);
        switch (kind) {
            case PRIM_KIND_RECT: {
                result = color;
                break;
            }
            case PRIM_KIND_TEXT: {
                result = vec4(color.rgb, color.a * texture(sMask, rect_pos).a);
                break;
            }
            case PRIM_KIND_IMAGE: {
                result = texture(sDiffuse, rect_pos);
                break;
            }
        }
    }

    return result;
}

#endif
