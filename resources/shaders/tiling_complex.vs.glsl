/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

uint current_layer = uint(0);

void write_complex_layer(vec3 pos) {
    vComplexPosition[current_layer++] = pos;
}

void write_complex_op(uint cmd) {
    if (vComplexCmdCount < COMPLEX_MAX_OPS) {           // TODO: Should guarantee this CPU-side
        vComplexCmds[vComplexCmdCount] = uvec2(cmd, current_layer-uint(1));
    }
    vComplexCmdCount += 1;
}

void main(void)
{
    InstanceInfo instance = instance_info[gl_InstanceID];

    uint tile_cmd_index = instance.cmd_info.x;
    uint tile_cmd_count = instance.cmd_info.y;

    vec4 pos = vec4(instance.rect.xy + aPosition.xy * instance.rect.zw, 0, 1);
    gl_Position = uTransform * pos;

    vComplexCmdCount = 0;

    for (uint c=tile_cmd_index ; c < tile_cmd_index + tile_cmd_count ; ++c) {
        uint cmd_type, cmd_index;
        decode_cmd(c, cmd_type, cmd_index);

        switch (cmd_type) {
            case CMD_SET_LAYER:
                {
                    Layer layer = layers[cmd_index];
                    vec3 a = layer.screen_vertices[0].xyz / layer.screen_vertices[0].w;
                    vec3 b = layer.screen_vertices[3].xyz / layer.screen_vertices[3].w;
                    vec3 c = layer.screen_vertices[2].xyz / layer.screen_vertices[2].w;
                    vec3 n = normalize(cross(b-a, c-a));

                    vec4 local_pos = untransform(pos.xy, n, a, layer.inv_transform);
                    write_complex_layer(local_pos.xyw);
                }
                break;
            case CMD_DRAW_RECT:
            case CMD_DRAW_IMAGE:
            case CMD_DRAW_TEXT:
            case CMD_SET_CLIP:
            case CMD_CLEAR_CLIP:
                {
                    write_complex_op(c);
                }
                break;
        }
    }
}
