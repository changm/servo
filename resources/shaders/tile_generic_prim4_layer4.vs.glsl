/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void handle_prim(uint kind, int index, TilePrimitive prim, vec3 layer_pos, out uint color) {
    vGenericPos[index].w = float(kind); 

    switch (kind) {
        case PRIM_KIND_RECT: {
            vGenericPos[index].xyz = layer_pos;
            color = pack_color(prim.color);
            vGenericRect[index] = prim.rect;
            break;
        }
        case PRIM_KIND_TEXT: {
            vec2 f = (layer_pos.xy - prim.rect.xy) / (prim.rect.zw - prim.rect.xy);
            vec2 interp_uv = mix(prim.st.xy, prim.st.zw, f * layer_pos.z);
            vGenericPos[index].xyz = vec3(interp_uv, layer_pos.z);
            color = pack_color(prim.color);
            vGenericRect[index] = prim.st;
            break;
        }
        case PRIM_KIND_IMAGE: {
            vec2 f = (layer_pos.xy - prim.rect.xy) / (prim.rect.zw - prim.rect.xy);
            vec2 interp_uv = mix(prim.st.xy, prim.st.zw, f * layer_pos.z);
            vGenericPos[index].xyz = vec3(interp_uv, layer_pos.z);
            color = pack_color(prim.color);
            vGenericRect[index] = prim.st;
            break;
        }
    }
}

void main(void) {
    L4P4Tile tile = tiles_l4p4[gl_InstanceID];
    vec2 pos = write_vertex(tile.target_rect, tile.screen_rect);

    vec3 layer_pos0 = get_layer_pos(pos, tile.layer_info.x);
    handle_prim(tile.prim_info.x, 0, tile.prims[0], layer_pos0, vGenericColor[0].x);

    vec3 layer_pos1 = get_layer_pos(pos, tile.layer_info.y);
    handle_prim(tile.prim_info.y, 1, tile.prims[1], layer_pos1, vGenericColor[0].y);

    vec3 layer_pos2 = get_layer_pos(pos, tile.layer_info.z);
    handle_prim(tile.prim_info.z, 2, tile.prims[2], layer_pos2, vGenericColor[0].z);

    vec3 layer_pos3 = get_layer_pos(pos, tile.layer_info.w);
    handle_prim(tile.prim_info.w, 3, tile.prims[3], layer_pos3, vGenericColor[0].w);
}
