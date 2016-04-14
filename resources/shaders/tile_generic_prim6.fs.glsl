/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

vec4 handle_prim(int index, uint packed_color) {
    uint kind = uint(vGenericPos[index].w);
    vec4 result = vec4(0, 0, 0, 0);

    vec2 rect_pos = vGenericPos[index].xy / vGenericPos[index].z;
    vec4 rect_rect = vGenericRect[index];

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

void main(void) {
    vec4 result = fetch_initial_color();

    vec4 prim_color = handle_prim(0, vGenericColor[0].x);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(1, vGenericColor[0].y);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(2, vGenericColor[0].z);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(3, vGenericColor[0].w);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(4, vGenericColor[1].x);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(5, vGenericColor[1].y);
    result = mix(result, prim_color, prim_color.a);

    oFragColor = result;
}
