shader_type canvas_item;

uniform float sector_angle : hint_range(0.0, 360.0) = 90.0; // total width in degrees
uniform float rotation_deg : hint_range(-360.0, 360.0) = 0.0; // 0 = right, positive = clockwise on screen
uniform float feather_deg : hint_range(0.0, 45.0) = 0.0; // soft edge width in degrees

void fragment() {
  vec2 p = UV - vec2(0.5);
  float a = atan(p.y, p.x);
  float dir = radians(rotation_deg);

  // Shortest angular distance from the sector's center direction, in [0, PI].
  float diff = abs(mod(a - dir + PI, TAU) - PI);

  float half_w = radians(sector_angle) * 0.5;
  float feather = max(radians(feather_deg), 0.0001);
  float mask = 1.0 - smoothstep(half_w, half_w + feather, diff);

  COLOR.a *= mask;
}