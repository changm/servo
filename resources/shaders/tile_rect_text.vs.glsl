/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    L4P2Tile tile = tiles_l4p2[gl_InstanceID];
    vec2 pos = write_vertex(tile.rect);

    vec3 layer_pos = get_layer_pos(pos, tile.layer_info.x);

    TilePrimitive rect_prim = tile.prims[0];
    vPos0 = layer_pos;
    vColor0 = rect_prim.color;
    vRect0 = vec4(rect_prim.p0, rect_prim.p1);

    TilePrimitive text_prim = tile.prims[1];
    vec2 f = (layer_pos.xy - text_prim.p0) / (text_prim.p1 - text_prim.p0);
    vec2 interp_uv = mix(text_prim.st0, text_prim.st1, f * layer_pos.z);
    vPos1 = vec3(interp_uv, layer_pos.z);
    vColor1 = text_prim.color;
    vRect1 = vec4(text_prim.st0, text_prim.st1);
}
