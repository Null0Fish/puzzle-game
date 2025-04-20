shader_type canvas_item;

uniform vec4 lava_tint;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    COLOR = tex_color * lava_tint;
}
