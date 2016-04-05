/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

vec4 handle_cmd(int i) {
    vec4 result = vec4(0, 0, 0, 0);

    vec2 pos = vSimplePosition[i].xy / vSimplePosition[i].z;
    vec4 rect = vSimplePosRect[i];

    if (point_in_rect(pos.xy, rect.xy, rect.zw)) {
        uint cmd = vSimpleMisc[i];

        switch (cmd) {
            case CMD_DRAW_RECT:
                {
                    vec4 color = unpack_color(vSimpleColor[i]);
                    result = color;
                }
                break;
            case CMD_DRAW_TEXT:
                {
                    vec4 color = unpack_color(vSimpleColor[i]);
                    result = vec4(color.rgb, color.a * texture(sMask, pos).a);
                }
                break;
            case CMD_DRAW_IMAGE:
                {
                    result = texture(sDiffuse, pos);
                }
                break;
        }
    }

    return result;
}

void main(void) {
    vec4 c0 = handle_cmd(0);

    if (c0.a == 1.0) {
        oFragColor = c0;
        return;
    }
    vec4 c1 = handle_cmd(1);
    vec4 c2 = handle_cmd(2);
    vec4 c3 = handle_cmd(3);

    vec4 one = vec4(1,1,1,1);
    bvec4 alpha_ok = greaterThanEqual(vec4(c0.a, c1.a, c2.a, c3.a), one);

    if (any(alpha_ok)) {
        vec3 result = c3.rgb;
        result = mix(result, c2.rgb, c2.a);
        result = mix(result, c1.rgb, c1.a);
        result = mix(result, c0.rgb, c0.a);
        oFragColor = vec4(result, 1);
    } else {
        discard;
    }
}
