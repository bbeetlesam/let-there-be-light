extern vec2 resolution; // ukuran canvas
extern float softness;  // seberapa jauh fade-nya

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord)
{
    vec4 pixel = Texel(texture, texCoord);

    vec2 center = resolution / 2.0;
    vec2 toCenter = abs(screenCoord - center);

    // Normalize: 0 (center), 1 (tepi)
    vec2 norm = toCenter / (resolution / 2.0);
    float strength = max(norm.x, norm.y);

    // Fade dari tengah ke hitam
    float fade = smoothstep(0.0, softness, strength);

    return mix(pixel, vec4(0.0, 0.0, 0.0, 1.0), fade) * color;
}