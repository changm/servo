/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

#define INVALID_LAYER_INDEX	uint(0xffffffff)

//#define CMD_ACCUMULATE		uint(0)
//#define CMD_MIX				uint(1)

varying vec2 vUv0;
varying vec2 vUv1;
varying vec2 vUv2;
varying vec2 vUv3;

//flat varying vec4 vLayerCmds;
flat varying vec4 vLayerValues;
