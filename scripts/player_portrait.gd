extends Control
## Original illustrated footballer portrait. Deterministic per player; no external photos or likenesses.
var seed_value := 1
var player_name := "Player"

func _ellipse(cx: float, cy: float, rx: float, ry: float, color: Color, steps: int = 36) -> void:
	var points := PackedVector2Array()
	for i in range(steps):
		var angle := TAU * float(i) / float(steps)
		points.append(Vector2(cx + cos(angle) * rx, cy + sin(angle) * ry))
	draw_colored_polygon(points, color)

func _poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func _draw() -> void:
	if size.x < 2.0 or size.y < 2.0:
		return
	var rng := RandomNumberGenerator.new()
	rng.seed = maxi(1, seed_value)
	var w := size.x
	var h := size.y
	var u := minf(w, h)
	var skin_tones := [Color("#f3d2b8"), Color("#e8b995"), Color("#d59b78"), Color("#bd805f"), Color("#986449"), Color("#744a39"), Color("#dca17f")]
	var hair_tones := [Color("#171b24"), Color("#30241f"), Color("#53382c"), Color("#8c603d"), Color("#c5a16a"), Color("#d5d2c9"), Color("#382c4e")]
	var kits := [Color("#cf3650"), Color("#2677b9"), Color("#16845c"), Color("#e7edf2"), Color("#6848b8"), Color("#d89a31"), Color("#17304e"), Color("#202a35")]
	var skin: Color = skin_tones[rng.randi_range(0, skin_tones.size() - 1)]
	var hair: Color = hair_tones[rng.randi_range(0, hair_tones.size() - 1)]
	var kit: Color = kits[rng.randi_range(0, kits.size() - 1)]
	var hair_style := rng.randi_range(0, 5)
	var beard_style := rng.randi_range(0, 3)
	var eye_color: Color = [Color("#263443"), Color("#49352d"), Color("#315b55"), Color("#25262b")][rng.randi_range(0, 3)]
	var bg := Color("#10243a")
	var glow := Color("#315978")
	var face_x := w * 0.5
	var face_y := h * 0.365
	var face_rx := u * 0.238
	var face_ry := u * 0.285

	# Studio backdrop with subtle radial light, diagonal texture and vignette.
	draw_rect(Rect2(Vector2.ZERO, size), bg, true)
	_ellipse(w * 0.5, h * 0.34, u * 0.49, u * 0.49, Color(glow, 0.68), 48)
	_ellipse(w * 0.5, h * 0.34, u * 0.39, u * 0.40, Color("#3b6884", 0.28), 48)
	for i in range(7):
		var x := w * (0.02 + float(i) * 0.16)
		draw_line(Vector2(x, 0), Vector2(x + w * 0.32, h * 0.64), Color("#d9efff", 0.045), maxf(1.0, u * 0.008))
	for i in range(12):
		var px := rng.randf_range(2.0, maxf(3.0, w - 2.0))
		var py := rng.randf_range(2.0, h * 0.59)
		draw_circle(Vector2(px, py), rng.randf_range(0.5, 1.35), Color("#e6f4ff", rng.randf_range(0.08, 0.24)))
	draw_rect(Rect2(Vector2(0, h * 0.72), Vector2(w, h * 0.28)), Color("#071727", 0.22), true)

	# Shoulders, shirt and neck.
	_poly([
		Vector2(w * 0.06, h), Vector2(w * 0.13, h * 0.80),
		Vector2(w * 0.28, h * 0.70), Vector2(w * 0.40, h * 0.66),
		Vector2(w * 0.60, h * 0.66), Vector2(w * 0.72, h * 0.70),
		Vector2(w * 0.87, h * 0.80), Vector2(w * 0.94, h)
	], kit.darkened(0.12))
	_poly([
		Vector2(w * 0.08, h), Vector2(w * 0.16, h * 0.80),
		Vector2(w * 0.31, h * 0.72), Vector2(w * 0.39, h * 0.70),
		Vector2(w * 0.34, h), Vector2(w * 0.08, h)
	], kit.lightened(0.10))
	_poly([
		Vector2(w * 0.92, h), Vector2(w * 0.84, h * 0.80),
		Vector2(w * 0.69, h * 0.72), Vector2(w * 0.61, h * 0.70),
		Vector2(w * 0.66, h), Vector2(w * 0.92, h)
	], kit.darkened(0.03))
	# Shirt pattern and seams.
	var pattern := rng.randi_range(0, 3)
	for i in range(4):
		var x := w * (0.36 + float(i) * 0.09)
		if pattern == 0:
			draw_line(Vector2(x, h * 0.73), Vector2(x, h), Color("#ffffff", 0.14), maxf(1.0, u * 0.012))
		elif pattern == 1 and i % 2 == 0:
			draw_line(Vector2(x, h * 0.73), Vector2(x - w * 0.025, h), Color("#ffffff", 0.15), maxf(1.0, u * 0.018))
		elif pattern == 2:
			draw_line(Vector2(w * 0.20, h * (0.77 + i * 0.035)), Vector2(w * 0.80, h * (0.77 + i * 0.035)), Color("#ffffff", 0.09), 1.0)
	draw_line(Vector2(w * 0.18, h * 0.80), Vector2(w * 0.82, h * 0.80), Color("#ffffff", 0.24), maxf(1.0, u * 0.012))
	draw_rect(Rect2(w * 0.445, h * 0.54, w * 0.11, h * 0.17), skin.darkened(0.10), true)
	draw_rect(Rect2(w * 0.455, h * 0.55, w * 0.09, h * 0.16), skin, true)

	# Ears and face silhouette with soft shadow and lit cheek planes.
	_ellipse(w * 0.267, h * 0.39, u * 0.060, u * 0.085, skin.darkened(0.16))
	_ellipse(w * 0.733, h * 0.39, u * 0.060, u * 0.085, skin.darkened(0.16))
	_ellipse(face_x, face_y + u * 0.012, face_rx * 1.045, face_ry * 1.04, Color("#070e18", 0.38))
	_ellipse(face_x, face_y, face_rx, face_ry, skin)
	_ellipse(w * 0.405, h * 0.43, u * 0.075, u * 0.105, skin.lightened(0.07))
	_ellipse(w * 0.595, h * 0.43, u * 0.075, u * 0.105, skin.lightened(0.045))
	_ellipse(w * 0.5, h * 0.50, u * 0.105, u * 0.055, skin.darkened(0.035))

	# Hair cap and six distinct silhouettes.
	if hair_style == 0:
		_ellipse(w * 0.5, h * 0.235, u * 0.248, u * 0.155, hair)
		_poly([Vector2(w*0.25,h*0.29),Vector2(w*0.30,h*0.19),Vector2(w*0.43,h*0.16),Vector2(w*0.52,h*0.20),Vector2(w*0.65,h*0.15),Vector2(w*0.76,h*0.27),Vector2(w*0.65,h*0.31),Vector2(w*0.37,h*0.29)], hair)
	elif hair_style == 1:
		_ellipse(w * 0.5, h * 0.225, u * 0.258, u * 0.17, hair)
		for i in range(7):
			_ellipse(w * (0.285 + i * 0.072), h * (0.18 + (0.025 if i % 2 == 0 else 0.0)), u * 0.065, u * 0.075, hair.lightened(0.025))
	elif hair_style == 2:
		_ellipse(w * 0.5, h * 0.225, u * 0.24, u * 0.125, hair)
		_poly([Vector2(w*0.27,h*0.25),Vector2(w*0.35,h*0.17),Vector2(w*0.48,h*0.20),Vector2(w*0.57,h*0.15),Vector2(w*0.72,h*0.24),Vector2(w*0.65,h*0.34),Vector2(w*0.54,h*0.29),Vector2(w*0.42,h*0.33)], hair)
	elif hair_style == 3:
		_ellipse(w * 0.5, h * 0.235, u * 0.25, u * 0.16, hair)
		_poly([Vector2(w*0.28,h*0.27),Vector2(w*0.34,h*0.12),Vector2(w*0.62,h*0.12),Vector2(w*0.75,h*0.26),Vector2(w*0.66,h*0.31),Vector2(w*0.35,h*0.30)], hair)
	elif hair_style == 4:
		_ellipse(w * 0.5, h * 0.205, u * 0.20, u * 0.12, hair)
		_ellipse(w * 0.5, h * 0.16, u * 0.105, u * 0.10, hair.lightened(0.04))
	else:
		_ellipse(w * 0.5, h * 0.23, u * 0.255, u * 0.17, hair)
		for i in range(5):
			draw_line(Vector2(w * (0.34 + i * 0.075), h * 0.15), Vector2(w * (0.32 + i * 0.08), h * 0.27), hair.lightened(0.07), maxf(1.0, u * 0.016))

	# Brows, eyes, irises, nose and mouth.
	var eye_y := h * 0.385
	draw_line(Vector2(w * 0.355, eye_y - h * 0.055), Vector2(w * 0.465, eye_y - h * 0.065), hair.darkened(0.12), maxf(1.4, u * 0.026))
	draw_line(Vector2(w * 0.535, eye_y - h * 0.065), Vector2(w * 0.645, eye_y - h * 0.055), hair.darkened(0.12), maxf(1.4, u * 0.026))
	_ellipse(w * 0.415, eye_y, u * 0.039, u * 0.026, Color("#fff8ed"))
	_ellipse(w * 0.585, eye_y, u * 0.039, u * 0.026, Color("#fff8ed"))
	_ellipse(w * 0.418, eye_y, u * 0.018, u * 0.022, eye_color)
	_ellipse(w * 0.588, eye_y, u * 0.018, u * 0.022, eye_color)
	_ellipse(w * 0.423, eye_y - u * 0.008, u * 0.006, u * 0.007, Color("#ffffff"))
	_ellipse(w * 0.593, eye_y - u * 0.008, u * 0.006, u * 0.007, Color("#ffffff"))
	draw_line(Vector2(w * 0.5, h * 0.405), Vector2(w * 0.482, h * 0.465), skin.darkened(0.20), maxf(1.0, u * 0.012))
	draw_line(Vector2(w * 0.482, h * 0.465), Vector2(w * 0.518, h * 0.465), skin.darkened(0.20), maxf(1.0, u * 0.012))
	draw_arc(Vector2(w * 0.5, h * 0.492), u * 0.060, 0.15, PI - 0.15, 18, Color("#874d48"), maxf(1.0, u * 0.014))

	# Optional facial hair in several shapes.
	if beard_style == 1:
		_poly([Vector2(w*0.32,h*0.47),Vector2(w*0.36,h*0.54),Vector2(w*0.5,h*0.60),Vector2(w*0.64,h*0.54),Vector2(w*0.68,h*0.47),Vector2(w*0.61,h*0.51),Vector2(w*0.5,h*0.53),Vector2(w*0.39,h*0.51)], hair.darkened(0.08))
	elif beard_style == 2:
		draw_arc(Vector2(w * 0.5, h * 0.45), u * 0.17, 0.20, PI - 0.20, 28, hair.darkened(0.12), maxf(1.0, u * 0.025))
	elif beard_style == 3:
		_ellipse(w * 0.5, h * 0.555, u * 0.11, u * 0.035, hair.darkened(0.12))

	# Collar, shirt badge, sleeve trim and subtle portrait frame.
	_poly([Vector2(w*0.395,h*0.68),Vector2(w*0.5,h*0.755),Vector2(w*0.605,h*0.68),Vector2(w*0.565,h*0.65),Vector2(w*0.5,h*0.705),Vector2(w*0.435,h*0.65)], Color("#f2f5f7"))
	draw_line(Vector2(w * 0.18, h * 0.835), Vector2(w * 0.32, h * 0.78), Color("#ffffff", 0.35), maxf(1.0, u * 0.018))
	draw_line(Vector2(w * 0.82, h * 0.835), Vector2(w * 0.68, h * 0.78), Color("#ffffff", 0.35), maxf(1.0, u * 0.018))
	_ellipse(w * 0.68, h * 0.765, u * 0.026, u * 0.032, Color("#f4f6f8", 0.92))
	_ellipse(w * 0.68, h * 0.765, u * 0.016, u * 0.021, kit.darkened(0.25))
	draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color("#d9e8f3", 0.42), false, 1.4)
