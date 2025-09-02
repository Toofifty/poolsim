#version 300 es

precision mediump float;
uniform sampler2D texture;
uniform float sizeX;
uniform float sizeY;
in vec4 vertTexCoord;

vec4 pixelate(sampler2D tex, vec2 uv) {
    // vec2 coord = vec2( ceil(uv.x * sizeX) / sizeX,
    //     ceil(uv.y * sizeY) / sizeY );
    vec2 coord = vec2(uv.x, uv.y);
    return texture2D(tex, coord);
}

vec4 reduce_palette(vec4 color, float max_colors_per_channel) {
    if(max_colors_per_channel <= 0.0) {
            return color;
    }
    return ceil(color * max_colors_per_channel) / max_colors_per_channel;
}

vec4 grayscale(vec4 color) {
    return vec4(color.x, color.x, color.x, 1);
}

void main() {
	vec4 color = pixelate(texture, vertTexCoord.xy);
    // gl_FragColor = color;
    gl_FragColor = reduce_palette(color, 5.0);
}