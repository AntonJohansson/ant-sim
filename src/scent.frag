#version 330

in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture0;

out vec4 finalColor;

void main() {
    ivec2 size = textureSize(texture0,0);
    float dx = 1.0 / 800.0;
    float dy = 1.0 / 600.0;

    vec2 v = vec2(fragTexCoord.x, 1.0 - fragTexCoord.y);

    vec4 c00 = texture(texture0, v + vec2(-dx, -dy));
    vec4 c01 = texture(texture0, v + vec2(  0, -dy));
    vec4 c02 = texture(texture0, v + vec2( dx, -dy));

    vec4 c10 = texture(texture0, v + vec2(-dx,   0));
    vec4 c11 = texture(texture0, v + vec2(  0,   0));
    vec4 c12 = texture(texture0, v + vec2( dx,   0));

    vec4 c20 = texture(texture0, v + vec2(-dx,  dy));
    vec4 c21 = texture(texture0, v + vec2(  0,  dy));
    vec4 c22 = texture(texture0, v + vec2( dx,  dy));

    vec4 col = 0.1249*c00 + 0.125*c01 + 0.1249*c02
             + 0.125*c10 + 0.000*c11 + 0.125*c12
             + 0.1249*c20 + 0.125*c21 + 0.1249*c22;

    col.r = clamp(col.r, 0, 1);
    col.g = clamp(col.g, 0, 1);
    col.b = clamp(col.b, 0, 1);
    col.a = clamp(col.a, 0, 1);

    finalColor = vec4(col.rgb, 1);
}
