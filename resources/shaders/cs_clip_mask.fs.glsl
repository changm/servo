/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 result;

    result.x = do_clip(vLayerPos0.xy, vClipRect0, vClipInfo0.x);
    result.y = do_clip(vLayerPos1.xy, vClipRect1, vClipInfo1.x);
    result.z = do_clip(vLayerPos2.xy, vClipRect2, vClipInfo2.x);
    result.w = 1.0;

    oFragColor = result;
}
