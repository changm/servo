/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main() {
    CompositeTile tile = tiles[gl_InstanceID];

    vec4 rect = tile.rect;

    vec4 pos = vec4(mix(rect.xy, rect.xy + rect.zw, aPosition.xy), 0, 1);
    gl_Position = uTransform * pos;

    vUv0 = write_prim(pos.xy, tile.prim_indices[0].x);
    vUv1 = write_prim(pos.xy, tile.prim_indices[0].y);
    vUv2 = write_prim(pos.xy, tile.prim_indices[0].z);

    vClipSt = mix(tile.clip_st_rect.xy, tile.clip_st_rect.zw, aPosition.xy);
}
