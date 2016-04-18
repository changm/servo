/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void vs(vec2 pos, Command cmd, Primitive main_prim) {
    write_generic(0, cmd.prim_indices[0].x, cmd.layer_indices[0].x, pos, vBlendingColor[0].x);
    write_generic(1, cmd.prim_indices[0].y, cmd.layer_indices[0].y, pos, vBlendingColor[0].y);
    write_generic(2, cmd.prim_indices[0].z, cmd.layer_indices[0].z, pos, vBlendingColor[0].z);
    write_generic(3, cmd.prim_indices[0].w, cmd.layer_indices[0].w, pos, vBlendingColor[0].w);
    write_generic(4, cmd.prim_indices[1].x, cmd.layer_indices[1].x, pos, vBlendingColor[1].x);
    write_generic(5, cmd.prim_indices[1].y, cmd.layer_indices[1].y, pos, vBlendingColor[1].y);
}
