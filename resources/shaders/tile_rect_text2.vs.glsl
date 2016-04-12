/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    L4P3Tile tile = tiles_l4p3[gl_InstanceID];
    vec2 pos = write_vertex(tile.rect);

    vec3 layer_pos = get_layer_pos(pos, tile.layer_info.x);

    TilePrimitive rect_prim = tile.prims[0];
    TilePrimitive text_prim0 = tile.prims[1];
    TilePrimitive text_prim1 = tile.prims[2];

    vPos0 = layer_pos;
    vColor0 = rect_prim.color;
    vRect0 = rect_prim.rect;

    vec2 f0 = (layer_pos.xy - text_prim0.rect.xy) / (text_prim0.rect.zw - text_prim0.rect.xy);
    vec2 interp_uv0 = mix(text_prim0.st.xy, text_prim0.st.zw, f0 * layer_pos.z);
    vPos1 = vec3(interp_uv0, layer_pos.z);
    vColor1 = text_prim0.color;
    vRect1 = text_prim0.st;

    vec2 f1 = (layer_pos.xy - text_prim1.rect.xy) / (text_prim1.rect.zw - text_prim1.rect.xy);
    vec2 interp_uv1 = mix(text_prim1.st.xy, text_prim1.st.zw, f1 * layer_pos.z);
    vPos2 = vec3(interp_uv1, layer_pos.z);
    vColor2 = text_prim1.color;
    vRect2 = text_prim1.st;
}
