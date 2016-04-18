/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 result = fetch_initial_color();

    vec4 prim_color = handle_prim(1, vBlendingColor[0].y);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(2, vBlendingColor[0].z);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(3, vBlendingColor[0].w);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(4, vBlendingColor[1].x);
    result = mix(result, prim_color, prim_color.a);

    prim_color = handle_prim(5, vBlendingColor[1].y);
    result = mix(result, prim_color, prim_color.a);

    vec4 main_color = handle_prim(0, vBlendingColor[0].x);
    result = mix(result, main_color, main_color.a);

    oFragColor = result;
}
