#version 460 core

#include <flutter/runtime_effect.glsl>

uniform float u_time;
uniform vec2 u_resolution;

out vec4 fragColor;

// 2D Random function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// 2D Noise function
float noise(vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st);

    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.y * u.x;
}

void main() {
    vec2 st = gl_FragCoord.xy / u_resolution.xy;
    st.x *= u_resolution.x / u_resolution.y;

    float n = noise(st * 4.0 + u_time * 0.1);

    // Color palette
    vec3 color1 = vec3(0.07, 0.0, 0.2); // Deep Indigo
    vec3 color2 = vec3(0.8, 0.1, 0.5); // Electric Magenta
    vec3 color3 = vec3(0.2, 0.5, 0.9); // Bright Blue

    vec3 color = mix(color1, color2, smoothstep(0.4, 0.6, n));
    color = mix(color, color3, smoothstep(0.7, 0.75, n));

    // Add shimmering stars
    float stars = pow(noise(st * 200.0 + u_time * 0.2), 30.0);
    color += stars * vec3(0.9, 0.9, 1.0);

    fragColor = vec4(color, 1.0);
}