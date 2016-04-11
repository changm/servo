/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    RectTextTile tile = rect_text_tiles[gl_InstanceID];
    vec2 pos = write_vertex(tile.tile_rect);

    vec3 layer_pos = get_layer_pos(pos, tile.layer_info.x);

    vPos0 = layer_pos;
    vColor0 = tile.rect_prim.color;
    vRect0 = vec4(tile.rect_prim.p0, tile.rect_prim.p1);

    vec2 f = (layer_pos.xy - tile.text_prim.p0) / (tile.text_prim.p1 - tile.text_prim.p0);
    vec2 interp_uv = mix(tile.text_prim.st0, tile.text_prim.st1, f * layer_pos.z);
    vPos1 = vec3(interp_uv, layer_pos.z);
    vColor1 = tile.text_prim.color;
    vRect1 = vec4(tile.text_prim.st0, tile.text_prim.st1);

    vec2 f = (layer_pos.xy - tile.text_prim.p0) / (tile.text_prim.p1 - tile.text_prim.p0);
    vec2 interp_uv = mix(tile.text_prim.st0, tile.text_prim.st1, f * layer_pos.z);
    vPos1 = vec3(interp_uv, layer_pos.z);
    vColor1 = tile.text_prim.color;
    vRect1 = vec4(tile.text_prim.st0, tile.text_prim.st1);
}
