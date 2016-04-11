/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

vec4 handle_prim(uint kind, int index) {
    vec4 result = vec4(0, 0, 0, 0);

    vec2 rect_pos = vGenericPos[index].xy / vGenericPos[index].z;
    vec4 rect_rect = vGenericRect[index];

    if (point_in_rect(rect_pos, rect_rect.xy, rect_rect.zw)) {
        switch (kind) {
            case PRIM_KIND_RECT: {
                result = vGenericColor[index];
                break;
            }
            case PRIM_KIND_TEXT: {
                result = vec4(vGenericColor[index].rgb, vGenericColor[index].a * texture(sMask, rect_pos).a);
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
    vec3 result = vec3(1, 1, 1);

    vec4 prim_color = handle_prim(vGenericKind0.x, 0);
    result = mix(result, prim_color.rgb, prim_color.a);

    prim_color = handle_prim(vGenericKind0.y, 1);
    result = mix(result, prim_color.rgb, prim_color.a);

    prim_color = handle_prim(vGenericKind0.z, 2);
    result = mix(result, prim_color.rgb, prim_color.a);

    prim_color = handle_prim(vGenericKind0.w, 3);
    result = mix(result, prim_color.rgb, prim_color.a);

    oFragColor = vec4(result,1);
}
