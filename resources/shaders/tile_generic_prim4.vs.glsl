/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void handle_prim(uint kind, int index, TilePrimitive prim, vec3 layer_pos) {
    switch (kind) {
        case PRIM_KIND_RECT: {
            vGenericPos[index] = layer_pos;
            vGenericColor[index] = prim.color;
            vGenericRect[index] = vec4(prim.p0, prim.p1);
            break;
        }
        case PRIM_KIND_TEXT: {
            vec2 f = (layer_pos.xy - prim.p0) / (prim.p1 - prim.p0);
            vec2 interp_uv = mix(prim.st0, prim.st1, f * layer_pos.z);
            vGenericPos[index] = vec3(interp_uv, layer_pos.z);
            vGenericColor[index] = prim.color;
            vGenericRect[index] = vec4(prim.st0, prim.st1);
            break;
        }
        case PRIM_KIND_IMAGE: {
            vec2 f = (layer_pos.xy - prim.p0) / (prim.p1 - prim.p0);
            vec2 interp_uv = mix(prim.st0, prim.st1, f * layer_pos.z);
            vGenericPos[index] = vec3(interp_uv, layer_pos.z);
            vGenericColor[index] = prim.color;
            vGenericRect[index] = vec4(prim.st0, prim.st1);
            break;
        }
    }
}

void main(void) {
    L4P4Tile tile = tiles_l4p4[gl_InstanceID];
    vec2 pos = write_vertex(tile.rect);
    vec3 layer_pos = get_layer_pos(pos, tile.layer_info.x);

    vGenericKind0 = tile.prim_info;
    handle_prim(tile.prim_info.x, 0, tile.prims[0], layer_pos);
    handle_prim(tile.prim_info.y, 1, tile.prims[1], layer_pos);
    handle_prim(tile.prim_info.z, 2, tile.prims[2], layer_pos);
    handle_prim(tile.prim_info.w, 3, tile.prims[3], layer_pos);
}
