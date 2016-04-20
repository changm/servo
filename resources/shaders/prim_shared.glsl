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

varying vec4 vPrimPos0;
varying vec4 vPrimColor0;
flat varying vec4 vPrimRect0;

varying vec4 vPrimPos1;
varying vec4 vPrimColor1;
flat varying vec4 vPrimRect1;

varying vec4 vPrimPos2;
varying vec4 vPrimColor2;
flat varying vec4 vPrimRect2;

varying vec4 vPrimPos3;
varying vec4 vPrimColor3;
flat varying vec4 vPrimRect3;

flat varying vec4 vClipRect;
flat varying vec4 vClipParams;

//======================================================================================
// Shared types and constants
//======================================================================================
#define PRIM_KIND_RECT              uint(0)
#define PRIM_KIND_IMAGE             uint(1)
#define PRIM_KIND_TEXT              uint(2)
#define PRIM_KIND_BORDER_CORNER     uint(3)
#define PRIM_KIND_INVALID           uint(4)

//======================================================================================
// Shared types and UBOs
//======================================================================================

//======================================================================================
// VS only types and UBOs
//======================================================================================
#ifdef WR_VERTEX_SHADER

#define RECT_KIND_SOLID                     uint(0)
#define RECT_KIND_HORIZONTAL_GRADIENT       uint(1)
#define RECT_KIND_VERTICAL_GRADIENT         uint(2)
#define RECT_KIND_BORDER_CORNER             uint(3)

struct Primitive {
    vec4 rect;
    vec4 st;
    vec4 color0;
    vec4 color1;
    uvec4 info;
};

struct Layer {
    mat4 transform;
    mat4 inv_transform;
    vec4 screen_vertices[4];
};

struct Command {
    uvec4 prim_indices;
    uvec4 layer_indices;
    uvec4 clip_info;
};

struct ClipCorner {
    vec4 position;
    vec4 outer_inner_radii;
};

struct Clip {
    vec4 rect;
    ClipCorner top_left;
    ClipCorner top_right;
    ClipCorner bottom_left;
    ClipCorner bottom_right;
};

layout(std140) uniform Layers {
    Layer layers[256];
};

layout(std140) uniform Commands {
    Command commands[512];
};

layout(std140) uniform Primitives {
    Primitive primitives[512];
};

layout(std140) uniform Clips {
    Clip clips[256];
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
#define INVALID_CLIP_INDEX      uint(0xffffffff)

#define PRIM_ROTATION_0         uint(0)
#define PRIM_ROTATION_90        uint(1)
#define PRIM_ROTATION_180       uint(2)
#define PRIM_ROTATION_270       uint(3)

void write_clip(uint clip_index) {
    Clip clip = clips[clip_index];
    vClipRect = clip.rect;
    vClipParams = vec4(clip.top_left.outer_inner_radii.x,
                       clip.top_right.outer_inner_radii.x,
                       clip.bottom_left.outer_inner_radii.x,
                       clip.bottom_right.outer_inner_radii.x);
}

void write_border_clip(uint clip_index, uint rotation) {
    Clip clip = clips[clip_index];
    switch (rotation) {
        case PRIM_ROTATION_0: {
            vClipParams = vec4(clip.top_left.position.xy,
                               clip.top_left.outer_inner_radii.xz);
            break;
        }
        case PRIM_ROTATION_90: {
            vClipParams = vec4(clip.top_right.position.xy * vec2(-1.0, 1.0),
                               clip.top_right.outer_inner_radii.xz);
            break;
        }
        case PRIM_ROTATION_180: {
            vClipParams = vec4(clip.bottom_right.position.xy * vec2(-1.0, -1.0),
                               clip.bottom_right.outer_inner_radii.xz);
            break;
        }
        case PRIM_ROTATION_270: {
            vClipParams = vec4(clip.bottom_left.position.xy * vec2(1.0, -1.0),
                               clip.bottom_left.outer_inner_radii.xz);
            break;
        }
    }
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
    vec3 p = vec3(ref, -10000.0);
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

vec4 get_rect_color(Primitive prim, vec3 layer_pos) {
    vec4 result;

    switch (prim.info.y) {
        case RECT_KIND_SOLID: {
            result = prim.color0;
            break;
        }
        case RECT_KIND_HORIZONTAL_GRADIENT: {
            float f = (layer_pos.x - prim.rect.x) / (prim.rect.z - prim.rect.x);
            result = mix(prim.color0, prim.color1, f);
            break;
        }
        case RECT_KIND_VERTICAL_GRADIENT: {
            float f = (layer_pos.y - prim.rect.y) / (prim.rect.w - prim.rect.y);
            result = mix(prim.color0, prim.color1, f);
            break;
        }
        case RECT_KIND_BORDER_CORNER: {
            if (aPosition.z == 0.0) {
                result = prim.color0;
            } else {
                result = prim.color1;
            }
            break;
        }
    }

    return result;
}

void write_rect(uint prim_index,
                uint layer_index,
                vec2 pos,
                out vec3 out_pos,
                out vec4 out_color,
                out vec4 out_rect) {
    Primitive prim = primitives[prim_index];
    // TODO(gw): This can be simplified if VS time becomes a bottleneck!
    vec3 layer_pos = get_layer_pos(pos, layer_index);
    out_pos = layer_pos;
    out_color = get_rect_color(prim, layer_pos);
    out_rect = prim.rect;
}

void write_generic(uint prim_index,
                   uint layer_index,
                   uint clip_index,
                   vec2 pos,
                   out vec4 out_pos,
                   out vec4 out_color,
                   out vec4 out_rect) {
    if (prim_index == INVALID_PRIM_INDEX) {
        out_pos.w = float(PRIM_KIND_INVALID);
    } else {
        Primitive prim = primitives[prim_index];
        uint prim_kind = prim.info.x;

        // TODO(gw): This can be simplified if VS time becomes a bottleneck!
        vec3 layer_pos = get_layer_pos(pos, layer_index);
        out_pos.w = float(prim_kind);

        switch (prim_kind) {
            case PRIM_KIND_RECT: {
                out_pos.xyz = layer_pos;
                out_color = get_rect_color(prim, layer_pos);
                out_rect = prim.rect;
                break;
            }
            case PRIM_KIND_TEXT: {
                vec2 f = (layer_pos.xy - prim.rect.xy) / (prim.rect.zw - prim.rect.xy);
                vec2 interp_uv = mix(prim.st.xy, prim.st.zw, f * layer_pos.z);
                out_pos.xyz = vec3(interp_uv, layer_pos.z);
                out_color = prim.color0;
                out_rect = prim.st;
                break;
            }
            case PRIM_KIND_IMAGE: {
                vec2 f = (layer_pos.xy - prim.rect.xy) / (prim.rect.zw - prim.rect.xy);
                vec2 interp_uv = mix(prim.st.xy, prim.st.zw, f * layer_pos.z);
                out_pos.xyz = vec3(interp_uv, layer_pos.z);
                out_color = prim.color0;
                out_rect = prim.st;
                break;
            }
            case PRIM_KIND_BORDER_CORNER: {
                write_border_clip(clip_index, prim.info.z);
                out_pos.xyz = layer_pos;
                out_color = get_rect_color(prim, layer_pos);
                out_rect = prim.rect;
            }
        }
    }
}

void vs(Command cmd, Primitive main_prim, Layer main_layer);

// TODO(gw): Re-work this so that not all generic prim paths pay this cost? (Maybe irrelevant since it's a VS cost only)
vec2 write_vertex(Primitive prim, Layer layer) {
    vec2 local_pos = aPosition.xy;

    switch (prim.info.x) {
        case PRIM_KIND_BORDER_CORNER: {
            switch (prim.info.z) {
                case PRIM_ROTATION_0: {
                    local_pos.y = 1.0 - local_pos.y;
                    break;
                }
                case PRIM_ROTATION_90: {
                    break;
                }
                case PRIM_ROTATION_180: {
                    local_pos.x = 1.0 - local_pos.x;
                    break;
                }
                case PRIM_ROTATION_270: {
                    local_pos.x = 1.0 - local_pos.x;
                    local_pos.y = 1.0 - local_pos.y;
                    break;
                }
            }
            break;
        }
    }

    vec4 pos = layer.transform * vec4(mix(prim.rect.xy, prim.rect.zw, local_pos), 0, 1);

    switch (prim.info.x) {
        case PRIM_KIND_TEXT: {
            pos = round(pos * uDevicePixelRatio) / uDevicePixelRatio;
            break;
        }
    }

    gl_Position = uTransform * pos;
    return pos.xy / pos.w;
}

void main() {
    Command cmd = commands[gl_InstanceID];

    uint main_prim_index = cmd.prim_indices.x;
    uint main_layer_index = cmd.layer_indices.x;

    Primitive main_prim = primitives[main_prim_index];
    Layer main_layer = layers[main_layer_index];

    vs(cmd, main_prim, main_layer);
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

bool point_in_rect(vec2 p, vec2 p0, vec2 p1) {
    return p.x >= p0.x &&
           p.y >= p0.y &&
           p.x <= p1.x &&
           p.y <= p1.y;
}

void do_border_clip(vec2 pos) {
    float d = distance(pos, abs(vClipParams.xy));
    bool is_outside = all(lessThan(pos * sign(vClipParams.xy), vClipParams.xy)) &&
                      (d > vClipParams.z || d < vClipParams.w);
    if (is_outside) {
        discard;
    }
}

void do_clip(vec2 pos) {
    vec2 ref_tl = vClipRect.xy + vec2(vClipParams.x, vClipParams.x);
    vec2 ref_tr = vClipRect.xy + vec2(vClipRect.z - vClipParams.y, vClipParams.y);
    vec2 ref_bl = vClipRect.xy + vec2(vClipParams.z, vClipRect.w - vClipParams.z);
    vec2 ref_br = vClipRect.xy + vec2(vClipRect.z - vClipParams.w, vClipRect.w - vClipParams.w);

    float d_tl = distance(pos, ref_tl);
    float d_tr = distance(pos, ref_tr);
    float d_bl = distance(pos, ref_bl);
    float d_br = distance(pos, ref_br);

    bool out0 = pos.x < ref_tl.x && pos.y < ref_tl.y && d_tl > vClipParams.x;
    bool out1 = pos.x > ref_tr.x && pos.y < ref_tr.y && d_tr > vClipParams.y;
    bool out2 = pos.x < ref_bl.x && pos.y > ref_bl.y && d_bl > vClipParams.z;
    bool out3 = pos.x > ref_br.x && pos.y > ref_br.y && d_br > vClipParams.w;

    if (out0 || out1 || out2 || out3) {
        discard;
    }
}

vec4 handle_prim(vec4 pos,
                 vec4 color,
                 vec4 rect) {
    uint kind = uint(pos.w);
    vec4 result = vec4(0, 0, 0, 0);
    vec2 rect_pos = pos.xy;

    if (point_in_rect(rect_pos, rect.xy, rect.zw)) {
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
            case PRIM_KIND_BORDER_CORNER: {
                do_border_clip(pos.xy);
                result = color;
                break;
            }
        }
    }

    return result;
}

#endif
