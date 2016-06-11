/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void main(void) {
    vec4 prim_colors[4];
    prim_colors[0] = texture(sLayer0, vUv0);
    prim_colors[1] = texture(sLayer1, vUv1);
    prim_colors[2] = texture(sLayer2, vUv2);
    prim_colors[3] = texture(sLayer3, vUv3);

    vec4 result = vec4(1, 1, 1, 1);
    vec4 layer_color = vec4(0, 0, 0, 0);

    layer_color = mix(layer_color, prim_colors[0], prim_colors[0].a);
    if (vLayerCmds.x == CMD_MIX) {
        result = mix(result, layer_color, layer_color.a);
        layer_color = vec4(0, 0, 0, 0);
    }

    layer_color = mix(layer_color, prim_colors[1], prim_colors[1].a);
    if (vLayerCmds.y == CMD_MIX) {
        result = mix(result, layer_color, layer_color.a);
        layer_color = vec4(0, 0, 0, 0);
    }

    layer_color = mix(layer_color, prim_colors[2], prim_colors[2].a);
    if (vLayerCmds.z == CMD_MIX) {
        result = mix(result, layer_color, layer_color.a);
        layer_color = vec4(0, 0, 0, 0);
    }

    layer_color = mix(layer_color, prim_colors[3], prim_colors[3].a);
    if (vLayerCmds.w == CMD_MIX) {
        result = mix(result, layer_color, layer_color.a);
        layer_color = vec4(0, 0, 0, 0);
    }

    oFragColor = result;

    /*
     layer index invalid -> mask out color (alpha = 0) [or just don't mix into final result!?]

        Either:
            accumulate into current layer color
                OR
            mix into layer with layer opacity (and reset current layer color)

            init layer color = zero
            init result = zero
                mix prim color into layer color
                if layer changes
                    mix layer color into current result
                    reset layer color
                (0/1) mix that into result (if layer changes)

        */

    //oFragColor = prim_colors[2];

    /*
    vec4 result = fetch_initial_color();

    vec4 layer_color = prim_colors[3];

    layer_color = vLayerReset[2] * layer_color;
    layer_color = mix(layer_color, prim_colors[2], prim_colors[2].a);
    result = mix(result, layer_color, vLayerAlpha[2] * layer_color.a);

    layer_color = vLayerReset[1] * layer_color;
    layer_color = mix(layer_color, prim_colors[1], prim_colors[1].a);
    result = mix(result, layer_color, vLayerAlpha[1] * layer_color.a);

    layer_color = vLayerReset[0] * layer_color;
    layer_color = mix(layer_color, prim_colors[0], prim_colors[0].a);
    result = mix(result, layer_color, vLayerAlpha[0] * layer_color.a);
*/

    //result = mix(result, prim_colors[3], prim_colors[3].a);
    //result = mix(result, prim_colors[2], prim_colors[2].a);
    //result = mix(result, prim_colors[1], prim_colors[1].a);
    //result = mix(result, prim_colors[0], prim_colors[0].a);

    /*
    for (int i=MAX_LAYERS_PER_COMPOSITE-1 ; i >= 0 ; --i) {
        float layer_alpha = vBlendValues[i];
        int prim_index = int(vPrimIndex[i]);
        int prim_count = int(vPrimCount[i]);

        vec4 layer_color = vec4(0, 0, 0, 0);
        for (int j=prim_index+prim_count-1 ; j >= prim_index ; --j) {
            vec4 prim_color = prim_colors[j];
            layer_color = mix(layer_color, prim_color, prim_color.a);
        }

        result = mix(result, layer_color, layer_alpha * layer_color.a);
    }*/

    //oFragColor = result;
}
