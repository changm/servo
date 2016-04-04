/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void)
{
    vColorTexCoord = aColorTexCoordRectTop.xy;
    gl_Position = uTransform * vec4(aPosition.xy, 0.0, 1.0);
}

