/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/*
struct Clip {
    vec4 rect;
    vec4 radius_p3;
    uvec4 layer_p3;
};

struct ClipMask {
    uvec4 rect;
    uvec4 screen_origin_unused2;
    Clip clips[4];
};

layout(std140) uniform Items {
    ClipMask clips[256];
};
*/

void main(void) {
    /*
    ClipMask clip = clips[gl_InstanceID];

    vec2 pos = mix(clip.rect.xy, clip.rect.xy + clip.rect.zw, aPosition.xy);
    gl_Position = uTransform * vec4(pos, 0.0, 1.0);

    vec2 virtual_pos = mix(clip.screen_origin_unused2.xy,
                           clip.screen_origin_unused2.xy + clip.rect.zw,
                           aPosition.xy);
    virtual_pos /= uDevicePixelRatio;

    vLayerPos0 = get_layer_pos(virtual_pos, clip.clips[0].layer_p3.x);
    vClipRect0 = vec4(clip.clips[0].rect.xy, clip.clips[0].rect.xy + clip.clips[0].rect.zw);
    vClipInfo0 = clip.clips[0].radius_p3;

    vLayerPos1 = get_layer_pos(virtual_pos, clip.clips[1].layer_p3.x);
    vClipRect1 = vec4(clip.clips[1].rect.xy, clip.clips[1].rect.xy + clip.clips[1].rect.zw);
    vClipInfo1 = clip.clips[1].radius_p3;

    vLayerPos2 = get_layer_pos(virtual_pos, clip.clips[2].layer_p3.x);
    vClipRect2 = vec4(clip.clips[2].rect.xy, clip.clips[2].rect.xy + clip.clips[2].rect.zw);
    vClipInfo2 = clip.clips[2].radius_p3;
    */
}
