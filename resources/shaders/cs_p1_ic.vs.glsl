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

    for (int i=0 ; i < MAX_LAYERS_PER_COMPOSITE ; ++i) {
        //CompositeLayer layer = tile.layers[i];
        vLayerAlpha[i] = 1.0;
        vLayerReset[i] = 1.0;
        /*
        if (layer.prim_index_count.y == uint(0)) {
            vLayerAlpha[i] = 0.0;
            vLayerReset[i] = 0.0;
        } else {
            vLayerAlpha[i] = layer.value.x;
            vLayerReset[i] = 1.0;
        }*/
    }

/*
    for (int i=0 ; i < MAX_LAYERS_PER_COMPOSITE ; ++i) {
        CompositeLayer layer = tile.layers[i];
        vBlendValues[i] = layer.value.x;
        vPrimIndex[i] = layer.prim_index_count.x;
        vPrimCount[i] = layer.prim_index_count.y;
    }*/
}
