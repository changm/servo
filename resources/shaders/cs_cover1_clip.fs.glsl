/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 initial_color = fetch_initial_color();
    vec4 clip_mask = texture(sCache, vClipSt);

    vec4 c0 = texture(sLayer0, vUv);
    oFragColor = mix(initial_color, c0, c0.a * clip_mask.x);
}
