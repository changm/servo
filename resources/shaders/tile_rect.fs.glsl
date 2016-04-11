/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 result = vec4(1, 1, 1, 1);

    vec2 pos = vPos0.xy / vPos0.z;
    vec4 rect = vRect0;
    vec4 color = vColor0;

    if (point_in_rect(pos, rect.xy, rect.zw)) {
        result = color;
    }

    oFragColor = result;
}
