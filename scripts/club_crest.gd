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
	var rng := RandomNumberGenerator.new()
	rng.seed = maxi(1, seed_value)
	var palette := [
		[Color("#d9ad55"), Color("#13263c")],
		[Color("#f1f1f1"), Color("#c7354d")],
		[Color("#f0d56b"), Color("#1c3e75")],
		[Color("#f5f5f5"), Color("#176c4b")],
		[Color("#f0e9d8"), Color("#282c38")],
		[Color("#f5f5f5"), Color("#6c3b9b")],
		[Color("#e9c77a"), Color("#742d34")]
	]
	var colors: Array = palette[rng.randi_range(0, palette.size() - 1)]
	var trim: Color = colors[0]
	var primary: Color = colors[1]
	var shadow := Color("#000000", 0.24)
	draw_circle(Vector2(w * 0.5, h * 0.49), minf(w, h) * 0.46, shadow)
	var shield := PackedVector2Array([
		Vector2(w*0.12,h*0.08), Vector2(w*0.88,h*0.08),
		Vector2(w*0.84,h*0.62), Vector2(w*0.72,h*0.82),
		Vector2(w*0.5,h*0.96), Vector2(w*0.28,h*0.82),
		Vector2(w*0.16,h*0.62)
	])
	draw_colored_polygon(shield, trim)
	var inner := PackedVector2Array([
		Vector2(w*0.18,h*0.14), Vector2(w*0.82,h*0.14),
		Vector2(w*0.78,h*0.60), Vector2(w*0.68,h*0.77),
		Vector2(w*0.5,h*0.88), Vector2(w*0.32,h*0.77),
		Vector2(w*0.22,h*0.60)
	])
	draw_colored_polygon(inner, primary)
	for i in range(5):
		var x := w * (0.28 + float(i) * 0.11)
		draw_line(Vector2(x, h * 0.19), Vector2(w * (0.5 + (float(i)-2.0)*0.075), h * 0.68), Color(trim, 0.22), maxf(1.0, w * 0.018))
	draw_line(Vector2(w * 0.22, h * 0.32), Vector2(w * 0.78, h * 0.32), trim, maxf(1.0, w * 0.025))
	var initials := ""
	for word in club_name.replace("-", " ").split(" ", false):
		if not word.is_empty() and initials.length() < 3:
			initials += word.substr(0, 1).to_upper()
	if initials.is_empty():
		initials = "FC"
	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(w * 0.5, h * 0.58), initials, HORIZONTAL_ALIGNMENT_CENTER, w * 0.58, int(clampf(w * 0.27, 12, 28)), Color("#ffffff"))
	draw_circle(Vector2(w * 0.5, h * 0.72), maxf(2.0, w * 0.035), trim)
	draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color("#ffffff", 0.12), false, 1.0)
