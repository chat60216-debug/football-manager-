extends Control
## Deterministic illustrated footballer portrait. No external photos or network assets required.
var seed_value := 1
var player_name := "Player"

func _ellipse(cx: float, cy: float, rx: float, ry: float, color: Color, steps: int = 28) -> void:
	var points := PackedVector2Array()
	for i in range(steps):
		var angle := TAU * float(i) / float(steps)
		points.append(Vector2(cx + cos(angle) * rx, cy + sin(angle) * ry))
	draw_colored_polygon(points, color)

func _draw() -> void:
	if size.x < 2.0 or size.y < 2.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = maxi(1, seed_value)
	var w := size.x
	var h := size.y
	var unit := minf(w, h)
	var skin_tones := [Color("#f4d1b3"), Color("#e4b18d"), Color("#c98964"), Color("#a96d4d"), Color("#81513d"), Color("#d99a78")]
	var hair_tones := [Color("#17191f"), Color("#30221e"), Color("#51372b"), Color("#8a5b35"), Color("#c6a16a"), Color("#d7d2c8")]
	var kits := [Color("#d83d55"), Color("#2878bd"), Color("#16865d"), Color("#e5e9ef"), Color("#6d49b9"), Color("#e2a43b"), Color("#172c48")]
	var skin: Color = skin_tones[rng.randi_range(0, skin_tones.size() - 1)]
	var hair: Color = hair_tones[rng.randi_range(0, hair_tones.size() - 1)]
	var kit: Color = kits[rng.randi_range(0, kits.size() - 1)]
	var hair_style := rng.randi_range(0, 4)
	var has_beard := rng.randf() > 0.64
	var bg_a := Color("#10243b")
	var bg_b := Color("#1d3c59")
	draw_rect(Rect2(Vector2.ZERO, size), bg_a, true)
	draw_rect(Rect2(Vector2(0, h * 0.56), Vector2(w, h * 0.44)), bg_b, true)
	_ellipse(w * 0.5, h * 0.35, unit * 0.43, unit * 0.43, Color("#274c68", 0.7))
	for i in range(5):
		var x := w * (0.08 + float(i) * 0.21)
		draw_line(Vector2(x, 0), Vector2(x + w * 0.16, h * 0.58), Color("#b8d8e8", 0.055), 1.0)
	for i in range(18):
		var px := rng.randf_range(3.0, maxf(4.0, w - 3.0))
		var py := rng.randf_range(3.0, h * 0.58)
		draw_circle(Vector2(px, py), rng.randf_range(0.5, 1.3), Color("#d5e9f4", 0.22))
	# Neck and shoulders, with a layered shirt silhouette.
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.12, h), Vector2(w * 0.18, h * 0.77),
		Vector2(w * 0.34, h * 0.68), Vector2(w * 0.42, h * 0.65),
		Vector2(w * 0.58, h * 0.65), Vector2(w * 0.66, h * 0.68),
		Vector2(w * 0.82, h * 0.77), Vector2(w * 0.9, h)
	]), kit)
	draw_colored_polygon(PackedVector2Array([
		Vector2(w * 0.12, h), Vector2(w * 0.18, h * 0.77),
		Vector2(w * 0.34, h * 0.68), Vector2(w * 0.40, h * 0.72),
		Vector2(w * 0.31, h), Vector2(w * 0.12, h)
	]), kit.lightened(0.13))
	draw_line(Vector2(w * 0.5, h * 0.76), Vector2(w * 0.5, h * 0.98), Color("#ffffff", 0.16), maxf(1.0, unit * 0.012))
	draw_rect(Rect2(w * 0.445, h * 0.55, w * 0.11, h * 0.17), skin.darkened(0.04), true)
	# Ears and face.
	_ellipse(w * 0.275, h * 0.385, unit * 0.055, unit * 0.085, skin.darkened(0.06))
	_ellipse(w * 0.725, h * 0.385, unit * 0.055, unit * 0.085, skin.darkened(0.06))
	_ellipse(w * 0.5, h * 0.375, unit * 0.235, unit * 0.285, skin)
	_ellipse(w * 0.5, h * 0.48, unit * 0.16, unit * 0.13, skin.lightened(0.035))
	# Hair silhouette and style.
	if hair_style == 0:
		_ellipse(w * 0.5, h * 0.235, unit * 0.245, unit * 0.145, hair)
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.26,h*0.28),Vector2(w*0.35,h*0.17),Vector2(w*0.52,h*0.20),Vector2(w*0.68,h*0.16),Vector2(w*0.75,h*0.29),Vector2(w*0.65,h*0.32),Vector2(w*0.38,h*0.29)]), hair)
	elif hair_style == 1:
		_ellipse(w * 0.5, h * 0.235, unit * 0.255, unit * 0.16, hair)
		for i in range(5):
			_ellipse(w * (0.31 + i * 0.095), h * (0.19 + (0.025 if i % 2 == 0 else 0.0)), unit * 0.065, unit * 0.075, hair.lightened(0.035))
	elif hair_style == 2:
		_ellipse(w * 0.5, h * 0.22, unit * 0.24, unit * 0.12, hair)
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.28,h*0.24),Vector2(w*0.72,h*0.24),Vector2(w*0.69,h*0.35),Vector2(w*0.61,h*0.30),Vector2(w*0.53,h*0.36),Vector2(w*0.44,h*0.30),Vector2(w*0.34,h*0.34)]), hair)
	else:
		_ellipse(w * 0.5, h * 0.235, unit * 0.255, unit * 0.16, hair)
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.26,h*0.26),Vector2(w*0.34,h*0.13),Vector2(w*0.62,h*0.13),Vector2(w*0.75,h*0.27),Vector2(w*0.66,h*0.30),Vector2(w*0.35,h*0.30)]), hair)
	# Eyebrows, eyes, nose and expression.
	var eye_y := h * 0.385
	draw_line(Vector2(w * 0.37, eye_y - h * 0.055), Vector2(w * 0.46, eye_y - h * 0.065), hair.darkened(0.12), maxf(1.2, unit * 0.025))
	draw_line(Vector2(w * 0.54, eye_y - h * 0.065), Vector2(w * 0.63, eye_y - h * 0.055), hair.darkened(0.12), maxf(1.2, unit * 0.025))
	_ellipse(w * 0.415, eye_y, unit * 0.036, unit * 0.024, Color("#fff8ed"))
	_ellipse(w * 0.585, eye_y, unit * 0.036, unit * 0.024, Color("#fff8ed"))
	_ellipse(w * 0.418, eye_y, unit * 0.014, unit * 0.021, Color("#28313b"))
	_ellipse(w * 0.588, eye_y, unit * 0.014, unit * 0.021, Color("#28313b"))
	draw_line(Vector2(w * 0.5, h * 0.405), Vector2(w * 0.485, h * 0.465), skin.darkened(0.17), maxf(1.0, unit * 0.012))
	draw_line(Vector2(w * 0.485, h * 0.465), Vector2(w * 0.515, h * 0.47), skin.darkened(0.17), maxf(1.0, unit * 0.012))
	draw_arc(Vector2(w * 0.5, h * 0.495), unit * 0.055, 0.18, PI - 0.18, 16, Color("#874d48"), maxf(1.0, unit * 0.014))
	if has_beard:
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.31,h*0.47),Vector2(w*0.36,h*0.55),Vector2(w*0.5,h*0.61),Vector2(w*0.64,h*0.55),Vector2(w*0.69,h*0.47),Vector2(w*0.61,h*0.51),Vector2(w*0.5,h*0.53),Vector2(w*0.39,h*0.51)]), hair.darkened(0.08))
	# Collar and shirt details drawn last for crisp edges.
	draw_colored_polygon(PackedVector2Array([Vector2(w*0.405,h*0.68),Vector2(w*0.5,h*0.75),Vector2(w*0.595,h*0.68),Vector2(w*0.56,h*0.65),Vector2(w*0.5,h*0.70),Vector2(w*0.44,h*0.65)]), Color("#f0f4f8"))
	draw_line(Vector2(w * 0.18, h * 0.79), Vector2(w * 0.82, h * 0.79), Color("#ffffff", 0.2), maxf(1.0, unit * 0.012))
	draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color("#d8e5ef", 0.32), false, 1.2)
