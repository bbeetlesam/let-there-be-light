extern vec2 lightPos;
extern float radius;

vec4 effect(vec4 color, Image texture, vec2 tex_coords, vec2 screen_coords) {
    float dist = distance(screen_coords, lightPos);
    float intensity = 1.0 - smoothstep(radius * 0.5, radius, dist);

    intensity = floor(intensity * 5.0) / 7.0;

    vec4 texColor = Texel(texture, tex_coords);
    return texColor * vec4(vec3(intensity), 1.0);
}