/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void vs(vec2 pos, Command cmd, Primitive main_prim) {
    vUv = mix(main_prim.st.xy, main_prim.st.zw, aPosition.xy);
    vColor = main_prim.color;

    write_rect(0, cmd.prim_indices[0].y, cmd.layer_indices[0].y, pos);
}
