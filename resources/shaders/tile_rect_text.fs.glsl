/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec3 result = vec3(1, 1, 1);

    vec2 rect_pos = vPos0.xy / vPos0.z;
    vec4 rect_rect = vRect0;
    vec4 rect_color = vColor0;

    if (point_in_rect(rect_pos, rect_rect.xy, rect_rect.zw)) {
        result = rect_color.rgb;
    }

    vec2 text_uv = vPos1.xy / vPos1.z;
    vec4 text_uv_rect = vRect1;
    vec4 text_color = vColor1;

    if (point_in_rect(text_uv, text_uv_rect.xy, text_uv_rect.zw)) {
		vec4 prim_color = vec4(text_color.rgb, text_color.a * texture(sMask, text_uv).a);
		result = mix(result, prim_color.rgb, prim_color.a);
	}

    oFragColor = vec4(result, 1);
}
