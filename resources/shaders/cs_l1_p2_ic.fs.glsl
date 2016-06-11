/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
	vec4 c0 = fetch_initial_color();
    vec4 c1 = texture(sLayer0, vUv0);
    vec4 c2 = texture(sLayer1, vUv1);

    vec4 result;
    result = mix(c0, c1, c1.a);
    result = mix(result, c2, c2.a);

    oFragColor = result;
}
