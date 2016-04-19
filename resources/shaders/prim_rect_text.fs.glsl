/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec2 rect_pos = vBlendingPos[0].xy / vBlendingPos[0].z;
    vec4 rect_rect = vBlendingRect[0];

    vec4 rect_color = vec4(1,1,1,1);
    if (point_in_rect(rect_pos, rect_rect.xy, rect_rect.zw)) {
        rect_color = vBlendingColor[0];
    }

    vec4 text_color = vec4(vColor.rgb, vColor.a * texture(sMask, vUv).a);
    oFragColor = mix(rect_color, text_color, text_color.a);
}
