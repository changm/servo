/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void vs(Command cmd, vec2 layer_pos) {
    Primitive prim = primitives[cmd.prim_indices.x];
    vec2 f = (layer_pos - prim.rect.xy) / prim.rect.zw;
    vImageUv = mix(prim.st.xy, prim.st.zw, f);
    vImageColor = prim.color0;
}
