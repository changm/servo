/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

void write_simple_op(uint cmd,
                     vec3 pos,
                     vec4 color,
                     vec2 p0,
                     vec2 p1) {
    if (vSimpleCmdCount < SIMPLE_MAX_OPS) {
        vSimplePosition[vSimpleCmdCount] = pos;
        vSimpleColor[vSimpleCmdCount] = pack_color(color);
        vSimplePosRect[vSimpleCmdCount] = vec4(p0, p1);
        vSimpleMisc[vSimpleCmdCount] = cmd;
    }
    vSimpleCmdCount += 1;
}

void main(void)
{
    InstanceInfo instance = instance_info[gl_InstanceID];

    uint tile_cmd_index = instance.cmd_info.x;
    uint tile_cmd_count = instance.cmd_info.y;

    vec4 pos = vec4(instance.rect.xy + aPosition.xy, 0, 1);
    gl_Position = uTransform * pos;

    vSimpleCmdCount = 0;

    for (int i=0 ; i < SIMPLE_MAX_OPS ; ++i) {
        vSimpleMisc[i] = CMD_DRAW_RECT;
        vSimpleColor[i] = uint(0);
        vSimplePosition[i] = vec3(0,0,0);
        vSimplePosRect[i] = vec4(0,0,0,0);
    }

    vec4 local_pos;

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

                    local_pos = untransform(instance.rect.xy + instance.scroll_offset + aPosition.xy, n, a, layer.inv_transform);
                }
                break;
            case CMD_DRAW_RECT:
                {
                    Rectangle rect = rectangles[cmd_index];
                    write_simple_op(CMD_DRAW_RECT, local_pos.xyw, rect.color, rect.p0, rect.p1);
                }
                break;
            case CMD_DRAW_IMAGE:
                {
                    Image image = images[cmd_index];
                    vec2 f = (local_pos.xy - image.p0) / (image.p1 - image.p0);
                    vec2 interp_uv = mix(image.st0, image.st1, f * local_pos.w);
                    write_simple_op(CMD_DRAW_IMAGE, vec3(interp_uv, local_pos.w), vec4(1,1,1,1), image.st0, image.st1);
                }
            case CMD_DRAW_TEXT:
                {
                    Text text = texts[cmd_index];
                    vec2 f = (local_pos.xy - text.p0) / (text.p1 - text.p0);
                    vec2 interp_uv = mix(text.st0, text.st1, f * local_pos.w);
                    write_simple_op(CMD_DRAW_TEXT, vec3(interp_uv, local_pos.w), text.color, text.st0, text.st1);
                }
        }
    }
}
