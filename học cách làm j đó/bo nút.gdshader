shader_type canvas_item;

uniform float radius : hint_range(0.0, 100.0) = 100.0;

void fragment() {
    vec2 size = vec2(textureSize(TEXTURE, 0));
    vec2 px_uv = UV * size;
    vec2 from_edge = min(px_uv, size - px_uv);
    
    if (min(from_edge.x, from_edge.y) < radius) {
        float dist = length(max(radius - from_edge, vec2(0.0)));
        if (dist > radius) {
            discard;
        }
    }
    
    COLOR = texture(TEXTURE, UV);
}