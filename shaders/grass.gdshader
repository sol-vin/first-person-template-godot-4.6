shader_type spatial;
render_mode cull_back;

// Per-component sRGB -> Linear conversion (alpha is NOT gamma-corrected).
vec3 srgb_to_linear(vec3 c) {
    vec3 lo = c / 12.92;
    vec3 hi = pow((c + 0.055) / 1.055, vec3(2.4));
    // step(edge, x): 0 when x < edge, 1 when x >= edge
    vec3 t = step(vec3(0.04045), c);
    return mix(lo, hi, t);
}

void vertex(){
	NORMAL = vec3(0.0, 1.0, 0.0);
	VERTEX.x += sin(COLOR.g + TIME * 0.25 + UV.y) * ( 1.0 - UV.y) * 0.1;
	VERTEX.z += cos(COLOR.g + TIME * 0.1 + UV.y) * ( 1.0 - UV.y) * 0.1;
}

void fragment() {
    vec3 vcol_rgb = COLOR.rgb;
    #if CURRENT_RENDERER != RENDERER_MOBILE
        vcol_rgb = srgb_to_linear(vcol_rgb);
    #endif
	
    ALBEDO = vcol_rgb;
    //ALPHA  = albedo_color.a * vcol_a;
	EMISSION = vcol_rgb;
}