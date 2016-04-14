/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 result = fetch_initial_color();

    vec4 c0 = texture(sTiling, vec2(vCompositeUv0.x, 1.0 - vCompositeUv0.y));
    result = mix(result, c0, c0.a);

    vec4 c1 = texture(sTiling, vec2(vCompositeUv1.x, 1.0 - vCompositeUv1.y));
    result = mix(result, c1, c1.a);

    oFragColor = result;
}
