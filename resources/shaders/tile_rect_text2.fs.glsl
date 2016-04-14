/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 result = fetch_initial_color();

    vec2 rect_pos = vPos0.xy / vPos0.z;
    vec4 rect_rect = vRect0;
    vec4 rect_color = vColor0;

    if (point_in_rect(rect_pos, rect_rect.xy, rect_rect.zw)) {
        result = mix(result, rect_color, rect_color.a);
    }

    vec2 text_uv0 = vPos1.xy / vPos1.z;
    vec4 text_uv_rect0 = vRect1;
    vec4 text_color0 = vColor1;

    if (point_in_rect(text_uv0, text_uv_rect0.xy, text_uv_rect0.zw)) {
        vec4 prim_color = vec4(text_color0.rgb, text_color0.a * texture(sMask, text_uv0).a);
        result = mix(result, prim_color, prim_color.a);
    }

    vec2 text_uv1 = vPos2.xy / vPos2.z;
    vec4 text_uv_rect1 = vRect2;
    vec4 text_color1 = vColor2;

    if (point_in_rect(text_uv1, text_uv_rect1.xy, text_uv_rect1.zw)) {
        vec4 prim_color = vec4(text_color1.rgb, text_color1.a * texture(sMask, text_uv1).a);
        result = mix(result, prim_color, prim_color.a);
    }

    oFragColor = result;
}
