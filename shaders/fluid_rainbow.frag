#version 460 core
precision highp float;

uniform vec2 iResolution; // Canvas resolution (width, height)
uniform float iTime;      // Time elapsed since start
uniform vec2 iMouse;      // Mouse position

out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / iResolution.xy;
    vec2 mouse = iMouse / iResolution.xy;
    float dist = distance(uv, mouse);
    float angle = atan(uv.y - mouse.y, uv.x - mouse.x);
    float colorFactor = sin(iTime + angle * 3.0) * 0.5 + 0.5;
    vec3 color = 0.5 + 0.5 * cos(6.2831 * (colorFactor + vec3(0.0, 0.33, 0.67)));
    color *= smoothstep(0.2, 0.0, dist);
    fragColor = vec4(color, 1.0);
}
