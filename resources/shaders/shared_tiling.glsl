/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

//======================================================================================
// Vertex shader attributes and uniforms
//======================================================================================
#ifdef WR_VERTEX_SHADER
    // Attribute inputs
    in vec4 aPositionRect;
#endif

//======================================================================================
// Fragment shader attributes and uniforms
//======================================================================================
#ifdef WR_FRAGMENT_SHADER
#endif

//======================================================================================
// Interpolator definitions
//======================================================================================

// Simple pass
#define SIMPLE_MAX_OPS      4

varying vec3 vSimplePosition[SIMPLE_MAX_OPS];
flat varying uint vSimpleColor[SIMPLE_MAX_OPS];
flat varying vec4 vSimplePosRect[SIMPLE_MAX_OPS];
flat varying uint vSimpleMisc[SIMPLE_MAX_OPS];
flat varying int vSimpleCmdCount;

// Complex pass
#define COMPLEX_MAX_LAYERS      6
#define COMPLEX_MAX_OPS         20

varying vec3 vComplexPosition[COMPLEX_MAX_LAYERS];
flat varying uvec2 vComplexCmds[COMPLEX_MAX_OPS];
flat varying int vComplexCmdCount;

//======================================================================================
// Shared types and constants
//======================================================================================
#define CMD_SET_LAYER           uint(0)
#define CMD_DRAW_RECT           uint(1)
#define CMD_DRAW_IMAGE          uint(4)
#define CMD_DRAW_TEXT           uint(6)

//======================================================================================
// Shared types and UBOs
//======================================================================================
struct TileInfo {
    uvec4 keys[UBO_INDEX_COUNT];
};

layout(std140) uniform IndexBuffer {
    TileInfo tile_info;
};

struct Rectangle {
    vec2 p0;
    vec2 p1;
    vec4 color;
};

layout(std140) uniform Rectangles {
    Rectangle rectangles[UBO_RECTANGLE_COUNT];
};

struct Text {
    vec2 p0;
    vec2 st0;
    vec2 p1;
    vec2 st1;
    vec4 color;
};

layout(std140) uniform Texts {
    Text texts[UBO_TEXT_COUNT];
};

struct Image {
    vec2 p0;
    vec2 st0;
    vec2 p1;
    vec2 st1;
};

layout(std140) uniform Images {
    Image images[UBO_IMAGE_COUNT];
};

//======================================================================================
// VS only types and UBOs
//======================================================================================
#ifdef WR_VERTEX_SHADER

struct InstanceInfo {
    uvec2 cmd_info;
    vec2 scroll_offset;
    vec4 rect;
};

layout(std140) uniform Instances {
    InstanceInfo instance_info[UBO_INSTANCE_COUNT];
};

struct Layer {
    vec4 blend_info;
    vec2 p0;
    vec2 p1;
    mat4 inv_transform;
    vec4 screen_vertices[4];
};

layout(std140) uniform Layers {
    Layer layers[UBO_LAYER_COUNT];
};

#endif

//======================================================================================
// Shared functions
//======================================================================================
bool point_in_rect(vec2 p, vec2 p0, vec2 p1) {
    return p.x >= p0.x &&
           p.y >= p0.y &&
           p.x <= p1.x &&
           p.y <= p1.y;
}

uint extract_index(uint virtual_index) {
    uint value = tile_info.keys[virtual_index >> uint(2)][virtual_index & uint(0x3)];
    return value;
}

void decode_cmd(uint index, out uint cmd_type, out uint cmd_index) {
    uint cmd = extract_index(index);
    cmd_type = (cmd & uint(0xff000000)) >> 24;
    cmd_index = cmd & uint(0x00ffffff);
}

//======================================================================================
// VS only functions
//======================================================================================
#ifdef WR_VERTEX_SHADER

bool rect_intersect_rect(vec2 r0p0, vec2 r0p1, vec2 r1p0, vec2 r1p1) {
    bvec2 a = lessThan(r0p0, r1p1);
    bvec2 b = lessThan(r1p0, r0p1);
    return all(a) && all(b);
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

#endif

//======================================================================================
// FS only functions
//======================================================================================
#ifdef WR_FRAGMENT_SHADER

vec4 unpack_color(uint color) {
    float r = float(color & uint(0x000000ff)) / 255.0;
    float g = float((color & uint(0x0000ff00)) >> 8) / 255.0;
    float b = float((color & uint(0x00ff0000)) >> 16) / 255.0;
    float a = float((color & uint(0xff000000)) >> 24) / 255.0;
    return vec4(r, g, b, a);
}

#endif
