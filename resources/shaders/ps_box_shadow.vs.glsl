/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void vs(Command cmd, Primitive main_prim, Layer main_layer) {
    vec2 pos = write_vertex(main_prim, main_layer);
    vec3 layer_pos = get_layer_pos(pos, cmd.layer_indices.x);

    vPos = layer_pos;

    vec2 f = aPosition.xy;

    switch (main_prim.info.z) {
        case PRIM_ROTATION_0: {
            break;
        }
        case PRIM_ROTATION_90: {
            f = vec2(f.y, 1.0 - f.x);
            break;
        }
        case PRIM_ROTATION_180: {
            f = vec2(1.0 - f.x, 1.0 - f.y);
            break;
        }
        case PRIM_ROTATION_270: {
            f = vec2(1.0 - f.y, f.x);
            break;
        }
    }

    vUv = mix(main_prim.st.xy, main_prim.st.zw, f);
    vColor = main_prim.color0;

    uint clip_in_index = cmd.clip_info.x;
    if (clip_in_index == INVALID_CLIP_INDEX) {
        vClipInRect = vec4(0, 0, 9e9, 9e9);
    } else {
        Clip clip_in = clips[clip_in_index];
        vClipInRect = clip_in.p0_p1;
    }

    uint clip_out_index = cmd.clip_info.y;
    if (clip_out_index == INVALID_CLIP_INDEX) {
        vClipOutRect = vec4(0, 0, 0, 0);
    } else {
        Clip clip_out = clips[clip_out_index];
        vClipOutRect = clip_out.p0_p1;
    }
}
