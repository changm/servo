/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void vs(Command cmd, vec2 layer_pos) {
    Primitive text_prim = primitives[cmd.prim_indices.x];
    Primitive rect_prim = primitives[cmd.prim_indices.y];

    vec2 rect_f = (layer_pos - rect_prim.rect.xy) / rect_prim.rect.zw;
	vRectColor = get_rect_color(rect_prim, rect_f);

    vec2 text_f = (layer_pos - text_prim.rect.xy) / text_prim.rect.zw;
	vTextColor = text_prim.color0;
    vTextUv = mix(text_prim.st.xy, text_prim.st.zw, text_f);
}
