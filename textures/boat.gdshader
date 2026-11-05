shader_type spatial;
varying vec2 world_xz;
// Speed of the waves and of the normal map scroll. 0 freezes the water. The
// 0.01 step stops the water jumping when TIME wraps round after an hour.
uniform float wave_speed : hint_range(0.0, 2.0, 0.01) = 0.5;

const vec2 WAVE_DIR[4] = vec2[4](
	vec2(0.958, 0.287), vec2(-0.447, 0.894), vec2(0.6, -0.8), vec2(-0.894, -0.447)
);
const float WAVE_LENGTH[4] = float[4](1.0, 0.71, 0.53, 0.37);
const float WAVE_SHARE[4] = float[4](0.4, 0.27, 0.2, 0.13);
const float WAVE_HALF_TURNS[4] = float[4](1.0, 2.0, 2.0, 3.0);

// How high a crest can rise above the plane, in metres. 0 turns waves off.
uniform float wave_height : hint_range(0.0, 1.0) = 0.1;
// Length of the longest wave in metres. The other three are shorter.
uniform float wave_length : hint_range(0.5, 20.0) = 4.0;

// Height of the surface at a world position, and its slope along x and z.
vec3 waves(vec2 xz, float t) {
	float height = 0.0;
	vec2 slope = vec2(0.0);
	for (int i = 0; i < 4; i++) {
		float k = TAU / (wave_length * WAVE_LENGTH[i]);
		float phase = k * dot(WAVE_DIR[i], xz) - PI * WAVE_HALF_TURNS[i] * t;
		float amplitude = wave_height * WAVE_SHARE[i];
		height += amplitude * sin(phase);
		// d/dx and d/dz of amplitude * sin(phase): the chain rule gives
		// amplitude * cos(phase) * k * direction.
		slope += amplitude * cos(phase) * k * WAVE_DIR[i];
	}
	return vec3(height, slope);
}

void vertex() {
	// Waves are placed in world space, so tiles of water side by side line up.
	vec3 world = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_xz = world.xz;
	vec3 wave = waves(world.xz, TIME * wave_speed);
	VERTEX.y = wave.x;
	// The surface y = h(x, z) has the normal (-dh/dx, 1, -dh/dz). Tangent and
	// binormal tilt by the slope along their own direction, so normal mapping
	// follows the waves.
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
