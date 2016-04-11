/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    L4P1Tile tile = tiles_l4p1[gl_InstanceID];
    vec2 pos = write_vertex(tile.rect);

    vec3 layer_pos = get_layer_pos(pos, tile.layer_info.x);

    vPos0 = layer_pos;
    vColor0 = tile.prim.color;
    vRect0 = vec4(tile.prim.p0, tile.prim.p1);
}
