/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    CompositeTile tile = tiles_composite[gl_InstanceID];
    write_vertex(tile.rect, tile.rect);

    vCompositeUv0 = tile.uv_rect0.xy + aPosition.xy * tile.uv_rect0.zw;
    vCompositeUv1 = tile.uv_rect1.xy + aPosition.xy * tile.uv_rect1.zw;
}
