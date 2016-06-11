#line 1

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main() {
    CompositeTile tile = tiles[gl_InstanceID];
    vec2 pos = write_vertex(tile);

    vUv0 = write_prim(pos, tile.prim_indices[0].x);
    vUv1 = write_prim(pos, tile.prim_indices[0].y);
    vUv2 = write_prim(pos, tile.prim_indices[0].z);
    vUv3 = write_prim(pos, tile.prim_indices[0].w);

    vLayerCmds.x = tile.layer_indices[0].x == tile.layer_indices[0].y ? 0.0 : 1.0;
    vLayerCmds.y = tile.layer_indices[0].y == tile.layer_indices[0].z ? 0.0 : 1.0;
    vLayerCmds.z = tile.layer_indices[0].z == tile.layer_indices[0].w ? 0.0 : 1.0;
    vLayerCmds.w = tile.layer_indices[0].w == INVALID_LAYER_INDEX ? 0.0 : 1.0;
}
