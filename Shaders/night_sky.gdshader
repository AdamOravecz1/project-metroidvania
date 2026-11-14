shader_type canvas_item;

uniform vec4 sky_color : source_color = vec4(0.015, 0.025, 0.09, 1.0);
uniform vec4 cloud_color : source_color = vec4(0.15, 0.08, 0.3, 1.0);
uniform vec2 pixel_resolution = vec2(1280.0, 720.0);

uniform float cloud_scale = 3.0;
uniform float cloud_strength = 0.18;
uniform float star_density = 0.985;

uniform float cloud_speed = 0.015;
uniform vec2 cloud_direction = vec2(1.0, 0.0);

// --- UTILITY FUNCTIONS ---

float random(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec2 hash22(vec2 p) {
    p = vec2(
        dot(p, vec2(127.1, 311.7)),
        dot(p, vec2(269.5, 183.3))
    );
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    float a = dot(hash22(i), f);
    float b = dot(hash22(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0));
    float c = dot(hash22(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0));
    float d = dot(hash22(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0));

    return 0.5 + 0.5 * mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// --- FRAGMENT SHADER ---

void fragment() {
    vec2 uv = floor(UV * pixel_resolution) / pixel_resolution;
    vec3 color = sky_color.rgb;

    // --- CLOUDS ---
	vec2 cloud_uv = uv * vec2(2.0, 5.0) * cloud_scale;
	cloud_uv += cloud_direction * TIME * cloud_speed;

    // Domain warping
    vec2 warp = vec2(
        noise(cloud_uv),
        noise(cloud_uv + vec2(5.2, 3.7))
    );
	vec2 pixel_offset = floor(cloud_direction * TIME * cloud_speed * pixel_resolution) / pixel_resolution;
	cloud_uv += pixel_offset;

    // Fractal noise calculation
    float clouds = noise(cloud_uv) + 
                   noise(cloud_uv * 2.0) * 0.5 + 
                   noise(cloud_uv * 4.0) * 0.25;
    clouds = (clouds / 1.75);
    clouds = floor(clouds * 16.0) / 16.0;

    // Height density mask (more clouds towards the top)
    float height_density = smoothstep(1.0, 0.0, uv.y);
    float threshold = mix(0.68, 0.38, height_density);

    float cloud_mask = smoothstep(threshold - 0.12, threshold + 0.12, clouds);
    cloud_mask = floor(cloud_mask * 5.0) / 5.0; // Quantize gradient

    color = mix(color, cloud_color.rgb, cloud_mask * cloud_strength);

    // --- STARS ---
    vec2 pixel_position = floor(UV * pixel_resolution);
    vec2 star_grid = pixel_position / 4.0;
    vec2 cell = floor(star_grid);
    vec2 local = fract(star_grid);

    float star_random = random(cell);
    vec2 star_pos = vec2(random(cell + 1.0), random(cell + 2.0));

    float distance_to_star = distance(local, star_pos);
    float star = step(distance_to_star, 0.035) * step(star_density, star_random);

    // Hide stars behind clouds
    float star_visibility = 1.0 - smoothstep(0.15, 0.65, cloud_mask);

    color += vec3(star) * 0.8 * star_visibility;

    COLOR = vec4(color, 1.0);
}