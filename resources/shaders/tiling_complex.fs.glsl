/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec3 result = vec3(1,1,1);
    uint clip_index = uint(0xffffffff);

    for (int i=0 ; i < vComplexCmdCount ; ++i) {
        uvec2 info = vComplexCmds[i];
        uint cmd = info.x;
        uint layer_index = info.y;

        uint cmd_type, cmd_index;
        decode_cmd(cmd, cmd_type, cmd_index);

        vec2 local_pos = vComplexPosition[layer_index].xy;

        switch (cmd_type) {
            case CMD_SET_CLIP:
                clip_index = cmd_index;
                break;
            case CMD_CLEAR_CLIP:
                clip_index = uint(0xffffffff);
                break;
            default:
                if (clip_index != uint(0xffffffff)) {
                    Clip clip = clips[clip_index];

                    float d0 = distance(local_pos, clip.top_left.position);
                    float d1 = distance(local_pos, clip.top_right.position);
                    float d2 = distance(local_pos, clip.bottom_left.position);
                    float d3 = distance(local_pos, clip.bottom_right.position);
                    bool top_left_out = local_pos.x < clip.top_left.position.x &&
                                        local_pos.y < clip.top_left.position.y &&
                                        (d0 > clip.top_left.outer_radius.x ||
                                         d0 < clip.top_left.inner_radius.x);
                    bool top_right_out = local_pos.x > clip.top_right.position.x &&
                                         local_pos.y < clip.top_right.position.y &&
                                         (d1 > clip.top_right.outer_radius.x ||
                                          d1 < clip.top_right.inner_radius.x);
                    bool bottom_left_out = local_pos.x < clip.bottom_left.position.x &&
                                           local_pos.y > clip.bottom_left.position.y &&
                                           (d2 > clip.bottom_left.outer_radius.x ||
                                            d2 < clip.bottom_left.inner_radius.x);
                    bool bottom_right_out = local_pos.x > clip.bottom_right.position.x &&
                                            local_pos.y > clip.bottom_right.position.y &&
                                            (d3 > clip.bottom_right.outer_radius.x ||
                                             d3 < clip.bottom_right.inner_radius.x);

                    if (top_left_out || top_right_out || bottom_left_out || bottom_right_out) {
                        break;
                    }
                }

                vec4 prim_color = vec4(0,0,0,0);

                switch (cmd_type) {
                    case CMD_DRAW_RECT:
                        {
                            Rectangle rect = rectangles[cmd_index];
                            if (point_in_rect(local_pos.xy, rect.p0, rect.p1)) {
                                prim_color = rect.color;
                            }
                        }
                        break;
                    case CMD_DRAW_TEXT:
                        {
                            Text text = texts[cmd_index];
                            if (point_in_rect(local_pos, text.p0, text.p1)) {
                                vec2 f = (local_pos - text.p0) / (text.p1 - text.p0);
                                vec2 uv = mix(text.st0, text.st1, f);
                                prim_color = vec4(text.color.rgb, text.color.a * texture(sMask, uv).a);
                            }
                        }
                        break;
                    case CMD_DRAW_IMAGE:
                        {
                            Image image = images[cmd_index];
                            if (point_in_rect(local_pos, image.p0, image.p1)) {
                                vec2 f = (local_pos - image.p0) / (image.p1 - image.p0);
                                vec2 uv = mix(image.st0, image.st1, f);
                                prim_color = texture(sDiffuse, uv);
                            }
                        }
                        break;
                }

                result = mix(result, prim_color.rgb, prim_color.a);
        }
    }

    oFragColor = vec4(result, 1);
}

/*
#define CMD_SET_LAYER           uint(0)
#define CMD_DRAW_RECT           uint(1)
#define CMD_SET_CLIP            uint(2)
#define CMD_CLEAR_CLIP          uint(3)
#define CMD_DRAW_IMAGE          uint(4)
#define CMD_DRAW_GRADIENT       uint(5)
#define CMD_DRAW_TEXT           uint(6)

#define FEATURE_CLIP
#define FEATURE_GRADIENT
#define FEATURE_IMAGE
#define FEATURE_TEXT
#define FEATURE_RECT

struct TileInfo {
    uvec4 keys[UBO_INDEX_COUNT];
};

struct Layer {
    vec4 blend_info;
    mat4 transform;
    mat4 inv_transform;
    vec4 screen_vertices[4];
};

layout(std140) uniform Misc {
    vec4 background_color;
};

layout(std140) uniform IndexBuffer {
    TileInfo tile_info;
};

layout(std140) uniform Layers {
    Layer layers[UBO_LAYER_COUNT];
};

#ifdef FEATURE_RECT
struct Rectangle {
    vec2 p0;
    vec2 p1;
    vec4 color;
};

layout(std140) uniform Rectangles {
    Rectangle rectangles[UBO_RECTANGLE_COUNT];
};
#endif

#ifdef FEATURE_TEXT
struct Glyph {
    vec2 p0;
    vec2 p1;
    vec2 st0;
    vec2 st1;
};

struct Text {
    vec2 p0;
    vec2 p1;
    vec4 color;
    uvec4 glyph_indices;
};

layout(std140) uniform Glyphs {
    Glyph glyphs[UBO_GLYPH_COUNT];
};

layout(std140) uniform Texts {
    Text texts[UBO_TEXT_COUNT];
};
#endif

#ifdef FEATURE_IMAGE
struct Image {
    vec2 p0;
    vec2 st0;
    vec2 p1;
    vec2 st1;
};

layout(std140) uniform Images {
    Image images[UBO_IMAGE_COUNT];
};
#endif

#ifdef FEATURE_GRADIENT
struct GradientStop {
    vec4 color;
    vec4 offset;
};

struct GradientRectangle {
    vec2 p0;
    vec2 p1;
    vec4 constants;
    uvec4 stop_indices;
};

layout(std140) uniform Gradients {
    GradientRectangle gradients[UBO_GRADIENT_COUNT];
};

layout(std140) uniform GradientStops {
    GradientStop gradient_stops[UBO_GRADIENT_STOP_COUNT];
};
#endif

#ifdef FEATURE_CLIP
struct ClipCorner {
    ivec2 position;
    ivec2 outer_radius;
    ivec2 inner_radius;
    ivec2 padding;
};

struct Clip {
    vec4 rect;
    ClipCorner top_left;
    ClipCorner top_right;
    ClipCorner bottom_left;
    ClipCorner bottom_right;
};

layout(std140) uniform Clips {
    Clip clips[UBO_CLIP_COUNT];
};
#endif

uint extract_index(uint virtual_index) {
    uint value = tile_info.keys[virtual_index >> uint(2)][virtual_index & uint(0x3)];
    return value;
}

void decode_cmd(uint index, out uint cmd_type, out uint cmd_index) {
    uint cmd = extract_index(index);
    cmd_type = (cmd & uint(0xff000000)) >> 24;
    cmd_index = cmd & uint(0x00ffffff);
}

vec4 bilerp(vec4 a, vec4 b, vec4 c, vec4 d, vec2 f) {
    vec4 x = mix(a, b, f.y);
    vec4 y = mix(c, d, f.y);
    return mix(x, y, f.x);
}

bool point_in_rect(vec2 p, vec2 p0, vec2 p1) {
    vec2 s = step(p0, p) - step(p1, p);
    return s.x * s.y != 0.0;
}

#ifdef FEATURE_RECT
void handle_rectangle(uint rect_index,
                      vec2 frag_position,
                      inout vec4 prim_color) {
    Rectangle rect = rectangles[rect_index];
    if (point_in_rect(frag_position, rect.p0, rect.p1)) {
        prim_color = rect.color;
    }
}
#endif

#ifdef FEATURE_TEXT
void handle_text(uint text_index,
                 vec2 frag_position,
                 inout vec4 prim_color) {
    Text text = texts[text_index];
    if (point_in_rect(frag_position, text.p0, text.p1)) {
        uint glyph_start_index = text.glyph_indices.x;
        uint glyph_end_index = text.glyph_indices.y;
        vec2 local_pos = frag_position;

        // TODO(gw): This is a linear search over all glyphs - needs to be smarter!
        // TODO(gw): Early outs as soon as it finds a match - need to handle case
        //           of glyph overlap too!
        for (uint i=glyph_start_index ; i < glyph_end_index ; ++i) {
            Glyph glyph = glyphs[i];
            if (point_in_rect(local_pos, glyph.p0, glyph.p1)) {
                vec2 f = (local_pos - glyph.p0) / (glyph.p1 - glyph.p0);
                vec2 uv = mix(glyph.st0, glyph.st1, f);
                prim_color = text.color * Texture(sDiffuse, uv);
            }
        }
    }
}
#endif

#ifdef FEATURE_IMAGE
void handle_image(uint image_index,
                  vec2 frag_position,
                  inout vec4 prim_color) {
    Image image = images[image_index];
    if (point_in_rect(frag_position, image.p0, image.p1)) {
        vec2 f = (frag_position - image.p0) / (image.p1 - image.p0);
        vec2 uv = mix(image.st0, image.st1, f);
        prim_color = Texture(sDiffuse, uv);
    }
}
#endif

#ifdef FEATURE_GRADIENT
void handle_gradient(uint gradient_index,
                     vec2 frag_position,
                     inout vec4 prim_color) {
    GradientRectangle gradient = gradients[gradient_index];
    if (point_in_rect(frag_position, gradient.p0, gradient.p1)) {
        float sin_angle = gradient.constants.x;
        float cos_angle = gradient.constants.y;
        float d = gradient.constants.z;
        float rx = gradient.constants.w;

        float rot_x = frag_position.x * cos_angle - frag_position.y * sin_angle;

        uint stop_index = gradient.stop_indices.x;
        uint stop_count = gradient.stop_indices.y;

        GradientStop stop0 = gradient_stops[stop_index+uint(0)];
        GradientStop stop1 = gradient_stops[stop_index+uint(1)];

        prim_color = mix(stop0.color, stop1.color, smoothstep(rx + stop0.offset.x * d, rx + stop1.offset.x * d, rot_x));

        for (uint i=uint(1) ; i < stop_count-uint(1) ; ++i) {
            GradientStop stopA = gradient_stops[stop_index + i + uint(0)];
            GradientStop stopB = gradient_stops[stop_index + i + uint(1)];

            prim_color = mix(prim_color, stopB.color, smoothstep(rx + stopA.offset.x * d, rx + stopB.offset.x * d, rot_x));
        }
    }
}
#endif

float ScalarTriple(vec3 u, vec3 v, vec3 w) {
    return dot(cross(u, v), w);
}

bool IntersectLineQuad(vec3 p, vec3 q, vec4 a, vec4 b, vec4 c, vec4 d, out vec3 r) {
    vec3 sa = a.xyz / a.w;
    vec3 sb = b.xyz / b.w;
    vec3 sc = c.xyz / c.w;
    vec3 sd = d.xyz / d.w;

    vec3 pq = q - p;
    vec3 pa = sa - p;
    vec3 pb = sb - p;
    vec3 pc = sc - p;

    vec3 m = cross(pc, pq);
    float v = dot(pa, m);

    if (v >= 0.0) {
        float u = -dot(pb, m);
        if (u < 0.0)
            return false;
        float w = ScalarTriple(pq, pb, pa);
        if (w < 0.0)
            return false;
        float denom = 1.0 / (u + v + w);
        u *= denom;
        v *= denom;
        w *= denom;
        r = u*sa + v*sb + w*sc;
    } else {
        vec3 pd = sd - p;
        float u = dot(pd, m);
        if (u < 0.0)
            return false;
        float w = ScalarTriple(pq, pa, pd);
        if (w < 0.0)
            return false;
        v = -v;
        float denom = 1.0 / (u + v + w);
        u *= denom;
        v *= denom;
        w *= denom;
        r = u*sa + v*sd + w*sc;
    }

    return true;
}

void main(void) {
    vec3 current_color = background_color.rgb;
#if 1
    uint cmd_index = uint(vCmdInfo.x);
    uint cmd_count = uint(vCmdInfo.y);

    bool layer_valid = false;
    vec2 layer_position = vec2(0.0, 0.0);
#ifdef FEATURE_CLIP
    uint clip_index = uint(0xffffffff);
#endif

    for (uint c=cmd_index ; c < cmd_index + cmd_count ; ++c) {
        uint cmd_type, cmd_index;
        decode_cmd(c, cmd_type, cmd_index);

        vec4 prim_color = vec4(0.0, 0.0, 0.0, 0.0);

#ifdef FEATURE_CLIP
        if (layer_valid && clip_index != uint(0xffffffff)) {
            Clip clip = clips[clip_index];

            float d0 = distance(layer_position, clip.top_left.position);
            float d1 = distance(layer_position, clip.top_right.position);
            float d2 = distance(layer_position, clip.bottom_left.position);
            float d3 = distance(layer_position, clip.bottom_right.position);
            bool top_left_out = layer_position.x < clip.top_left.position.x &&
                                layer_position.y < clip.top_left.position.y &&
                                (d0 > clip.top_left.outer_radius.x ||
                                 d0 < clip.top_left.inner_radius.x);
            bool top_right_out = layer_position.x > clip.top_right.position.x &&
                                 layer_position.y < clip.top_right.position.y &&
                                 (d1 > clip.top_right.outer_radius.x ||
                                  d1 < clip.top_right.inner_radius.x);
            bool bottom_left_out = layer_position.x < clip.bottom_left.position.x &&
                                   layer_position.y > clip.bottom_left.position.y &&
                                   (d2 > clip.bottom_left.outer_radius.x ||
                                    d2 < clip.bottom_left.inner_radius.x);
            bool bottom_right_out = layer_position.x > clip.bottom_right.position.x &&
                                    layer_position.y > clip.bottom_right.position.y &&
                                    (d3 > clip.bottom_right.outer_radius.x ||
                                     d3 < clip.bottom_right.inner_radius.x);

            if (top_left_out || top_right_out || bottom_left_out || bottom_right_out) {
                continue;
            }
        }
#endif

        switch (cmd_type) {
            case CMD_SET_LAYER:
                {
                    vec3 p = vec3(vPosition.xy, -1000.0);
                    vec3 q = vec3(vPosition.xy,  1000.0);
                    vec3 r;

                    Layer layer = layers[cmd_index];
                    layer_valid = IntersectLineQuad(p,
                                                    q,
                                                    layer.screen_vertices[0],
                                                    layer.screen_vertices[1],
                                                    layer.screen_vertices[2],
                                                    layer.screen_vertices[3],
                                                    r);

                    if (layer_valid) {
                        vec4 inv_position = layer.inv_transform * vec4(r, 1.0);
                        layer_position = inv_position.xy / inv_position.w;
                    }
                    // TODO(gw): If not valid, store cmd count for layer in struct, and increment c by that to skip all commands!!
                }
                break;
#ifdef FEATURE_RECT
            case CMD_DRAW_RECT:
                //if (layer_valid) {
                    handle_rectangle(cmd_index, layer_position, prim_color);
                //}
                break;
#endif
#ifdef FEATURE_IMAGE
            case CMD_DRAW_IMAGE:
                if (layer_valid) {
                    handle_image(cmd_index, layer_position, prim_color);
                }
                break;
#endif
#ifdef FEATURE_GRADIENT
            case CMD_DRAW_GRADIENT:
                //if (layer_valid) {
                    handle_gradient(cmd_index, layer_position, prim_color);
                //}
                break;
#endif
#ifdef FEATURE_TEXT
            case CMD_DRAW_TEXT:
                //if (layer_valid) {
                    handle_text(cmd_index, layer_position, prim_color);
                //}
                break;
#endif
#ifdef FEATURE_CLIP
            case CMD_SET_CLIP:
                clip_index = cmd_index;
                break;
            case CMD_CLEAR_CLIP:
                clip_index = uint(0xffffffff);
                break;
#endif
            default:
                // Unexpected!
                //current_color = vec3(1,0,1);
                break;
        }

        //if (cmd_type == CMD_DRAW_TEXT || cmd_type == CMD_DRAW_RECT) {
        //    break;
       // }

        current_color = prim_color.rgb * prim_color.a + current_color * (1.0 - prim_color.a);
    }
#endif

    SetFragColor(vec4(current_color, 1));
}
*/
