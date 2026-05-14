shader_type canvas_item;


uniform vec4 primary_original_0: source_color;
uniform vec4 primary_original_1: source_color;
uniform vec4 primary_original_2: source_color;
uniform vec4 primary_original_3: source_color;
uniform vec4 primary_original_4: source_color;
uniform vec4 primary_replace_0: source_color;
uniform vec4 primary_replace_1: source_color;
uniform vec4 primary_replace_2: source_color;
uniform vec4 primary_replace_3: source_color;
uniform vec4 primary_replace_4: source_color;

uniform vec4 secondary_original_0: source_color;
uniform vec4 secondary_original_1: source_color;
uniform vec4 secondary_original_2: source_color;
uniform vec4 secondary_original_3: source_color;
uniform vec4 secondary_replace_0: source_color;
uniform vec4 secondary_replace_1: source_color;
uniform vec4 secondary_replace_2: source_color;
uniform vec4 secondary_replace_3: source_color;

const float precision = 0.1;


vec4 swap_color(vec4 color){
	vec4 original_colors[9] = vec4[9] (primary_original_0, primary_original_1, primary_original_2, primary_original_3, primary_original_4, secondary_original_0, secondary_original_1, secondary_original_2, secondary_original_3);
	vec4 replace_colors[9] = vec4[9] (primary_replace_0, primary_replace_1, primary_replace_2, primary_replace_3, primary_replace_4, secondary_replace_0, secondary_replace_1, secondary_replace_2, secondary_replace_3);
	for (int i = 0; i < 9; i ++) {
		if (distance(color, original_colors[i]) <= precision){
			return replace_colors[i];
		}
	}
	return color;
}


void fragment() {
	COLOR = swap_color(texture(TEXTURE, UV));
}
