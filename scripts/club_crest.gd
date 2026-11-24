extends Control
## Fictional, deterministic club crest generated from the club name.
var club_name := "DYNASTY FC"
var seed_value := 1

func setup(name: String, seed: int = 0) -> void:
	club_name = name
	seed_value = seed if seed != 0 else absi(name.hash())
	queue_redraw()

func _draw() -> void:
	if size.x < 2.0 or size.y < 2.0:
		return
	var w := size.x
	var h := size.y
	var u := minf(w, h)
	var rng := RandomNumberGenerator.new()
	rng.seed = maxi(1, seed_value)
	var palette := [
		[Color("#e6bd69"), Color("#13263c"), Color("#254b70")],
		[Color("#f4f1e8"), Color("#c7354d"), Color("#6d1d31")],
		[Color("#f0d56b"), Color("#1c3e75"), Color("#3566a4")],
		[Color("#f5f5f5"), Color("#176c4b"), Color("#2c9871")],
		[Color("#f0e9d8"), Color("#282c38"), Color("#4c596b")],
		[Color("#f5f5f5"), Color("#6c3b9b"), Color("#9668c4")],
		[Color("#e9c77a"), Color("#742d34"), Color("#a64b54")],
		[Color("#f1f4f8"), Color("#202b3d"), Color("#49647e")]
	]
	var colors: Array = palette[rng.randi_range(0, palette.size() - 1)]
	var trim: Color = colors[0]
	var primary: Color = colors[1]
	var secondary: Color = colors[2]
	var center := Vector2(w * 0.5, h * 0.48)

	# Metallic halo and dark medallion.
	draw_circle(center + Vector2(0, 3), u * 0.475, Color("#000000", 0.32))
	draw_circle(center, u * 0.465, Color("#0a1727"))
	draw_arc(center, u * 0.455, 0, TAU, 72, Color(trim, 0.72), maxf(1.0, u * 0.018))
	draw_arc(center, u * 0.425, 0, TAU, 72, Color("#ffffff", 0.10), maxf(1.0, u * 0.006))

	# Shield silhouette, bevel and inner field.
	var shield := PackedVector2Array([
		Vector2(w*0.13,h*0.08), Vector2(w*0.87,h*0.08),
		Vector2(w*0.83,h*0.59), Vector2(w*0.72,h*0.79),
		Vector2(w*0.5,h*0.94), Vector2(w*0.28,h*0.79),
		Vector2(w*0.17,h*0.59)
	])
	draw_colored_polygon(shield, trim)
	var inner := PackedVector2Array([
		Vector2(w*0.19,h*0.14), Vector2(w*0.81,h*0.14),
		Vector2(w*0.77,h*0.58), Vector2(w*0.68,h*0.75),
		Vector2(w*0.5,h*0.87), Vector2(w*0.32,h*0.75),
		Vector2(w*0.23,h*0.58)
	])
	draw_colored_polygon(inner, primary)

	# Club-specific pattern.
	var motif := rng.randi_range(0, 3)
	if motif == 0:
		for i in range(5):
			var x := w * (0.27 + float(i) * 0.115)
			draw_line(Vector2(x, h * 0.17), Vector2(w * (0.5 + (float(i) - 2.0) * 0.075), h * 0.72), Color(secondary, 0.72), maxf(1.0, w * 0.045))
	elif motif == 1:
		for i in range(4):
			var y := h * (0.23 + float(i) * 0.105)
			draw_line(Vector2(w * 0.22, y), Vector2(w * 0.78, y), Color(secondary, 0.8), maxf(1.0, w * 0.038))
	elif motif == 2:
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.2,h*0.17),Vector2(w*0.8,h*0.17),Vector2(w*0.5,h*0.67)]), Color(secondary, 0.68))
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.2,h*0.7),Vector2(w*0.8,h*0.7),Vector2(w*0.5,h*0.36)]), Color(trim, 0.30))
	else:
		draw_circle(Vector2(w * 0.5, h * 0.43), u * 0.19, Color(secondary, 0.88))
		draw_arc(Vector2(w * 0.5, h * 0.43), u * 0.19, 0, TAU, 40, trim, maxf(1.0, u * 0.012))
		draw_line(Vector2(w * 0.35, h * 0.43), Vector2(w * 0.65, h * 0.43), trim, maxf(1.0, u * 0.012))
		draw_line(Vector2(w * 0.5, h * 0.25), Vector2(w * 0.5, h * 0.61), trim, maxf(1.0, u * 0.012))

	# Initials in a dedicated central plate.
	var initials := ""
	for word in club_name.replace("-", " ").split(" ", false):
		if not word.is_empty() and initials.length() < 3:
			initials += word.substr(0, 1).to_upper()
	if initials.is_empty():
		initials = "FC"
	var plate := Rect2(w * 0.245, h * 0.325, w * 0.51, h * 0.235)
	draw_rect(plate.grow(1.5), trim, true)
	draw_rect(plate, Color(primary, 0.94), true)
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(w * 0.5, h * 0.505), initials, HORIZONTAL_ALIGNMENT_CENTER, w * 0.49, int(clampf(w * 0.25, 12, 30)), Color("#ffffff"))

	# Crown stars and football detail.
	var stars := rng.randi_range(1, 3)
	for i in range(stars):
		var x := w * (0.5 + (float(i) - float(stars - 1) * 0.5) * 0.14)
		var y := h * 0.215
		var r := maxf(2.0, u * 0.027)
		var points := PackedVector2Array()
		for j in range(10):
			var angle := -PI * 0.5 + TAU * float(j) / 10.0
			var radius := r if j % 2 == 0 else r * 0.42
			points.append(Vector2(x + cos(angle) * radius, y + sin(angle) * radius))
		draw_colored_polygon(points, trim)
	draw_circle(Vector2(w * 0.5, h * 0.70), maxf(3.0, u * 0.045), trim)
	draw_circle(Vector2(w * 0.5, h * 0.70), maxf(2.0, u * 0.029), Color("#ffffff"))
	draw_arc(center, u * 0.465, 0, TAU, 72, Color("#ffffff", 0.20), 1.0)
