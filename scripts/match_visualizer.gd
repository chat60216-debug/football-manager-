extends Control
class_name DynastyMatchVisualizer

var report: Dictionary = {}
var elapsed := 0.0
var celebration := 0.0
var ball_from := Vector2(0.35, 0.55)
var ball_to := Vector2(0.68, 0.42)
var ball_position := Vector2(0.5, 0.5)
var event_cursor := 0
var ball_move_progress := 1.0

const GRASS_A := Color("#12613f")
const GRASS_B := Color("#18764b")
const WHITE := Color("#f3fff7")
const CYAN := Color("#67e6f4")
const RED := Color("#ff6578")

func setup(data: Dictionary) -> void:
	report = data.duplicate(true)
	custom_minimum_size = Vector2(0, 390)
	elapsed = 0.0
	celebration = 0.0
	ball_position = Vector2(0.5, 0.5)
	ball_move_progress = 1.0
	event_cursor = 0
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if celebration > 0.0:
		celebration = maxf(0.0, celebration - delta)
	var events: Array = report.get("events", [])
	if event_cursor < events.size() and elapsed > float(event_cursor) * 0.11:
		var e: Dictionary = events[event_cursor]
		if str(e.get("type", "")) == "goal":
			celebration = 2.0
			ball_from = ball_position
			var home_scored := str(e.get("team", "")) == str(report.get("home", ""))
			ball_to = Vector2(0.92, 0.5) if home_scored else Vector2(0.08, 0.5)
			ball_move_progress = 0.0
		event_cursor += 1
	if ball_move_progress < 1.0:
		ball_move_progress = minf(1.0, ball_move_progress + delta * 1.8)
		var eased := ball_move_progress * ball_move_progress * (3.0 - 2.0 * ball_move_progress)
		ball_position = ball_from.lerp(ball_to, eased)
	else:
		var phase := fposmod(elapsed * 0.24, 1.0)
		var arc := sin(phase * PI)
		ball_position = Vector2(0.18 + phase * 0.64, 0.5 + sin(elapsed * 1.8) * 0.19 * arc)
	queue_redraw()

func _draw_stands(area: Rect2) -> void:
	draw_rect(area, Color("#071321"), true)
	var roof := PackedVector2Array([
		Vector2(area.position.x, area.position.y + area.size.y * 0.04),
		Vector2(area.position.x + area.size.x * 0.12, area.position.y),
		Vector2(area.end.x - area.size.x * 0.12, area.position.y),
		Vector2(area.end.x, area.position.y + area.size.y * 0.04),
		Vector2(area.end.x, area.position.y + area.size.y * 0.16),
		Vector2(area.position.x, area.position.y + area.size.y * 0.16)
	])
	draw_colored_polygon(roof, Color("#1a2c42"))
	for row in range(4):
		var y := area.position.y + area.size.y * (0.07 + float(row) * 0.035)
		for col in range(64):
			var x := area.position.x + area.size.x * (0.025 + float(col) * 0.015)
			var tone := Color("#b9c8d7", 0.28) if (row + col) % 3 == 0 else Color("#6e879e", 0.2)
			draw_circle(Vector2(x, y), maxf(1.0, area.size.x * 0.0018), tone)
	for side in [0, 1]:
		var x := area.position.x + area.size.x * (0.055 if side == 0 else 0.945)
		draw_line(Vector2(x, area.position.y + 5), Vector2(x, area.end.y * 0.9), Color("#f8e9bd", 0.65), 2.0)
		draw_circle(Vector2(x, area.position.y + 7), maxf(3.0, area.size.x * 0.012), Color("#fff3d0", 0.9))
		for ray in range(4):
			draw_line(Vector2(x, area.position.y + 8), Vector2(x + (1 if side == 0 else -1) * (12 + ray * 8), area.position.y + area.size.y * 0.22), Color("#fff0c2", 0.045), 7.0)

func _draw_pitch(area: Rect2) -> void:
	draw_rect(area, GRASS_A, true)
	for i in range(12):
		if i % 2 == 0:
			draw_rect(Rect2(area.position.x + area.size.x * float(i) / 12.0, area.position.y, area.size.x / 12.0, area.size.y), GRASS_B, true)
	draw_rect(area, WHITE, false, 2)
	var center := area.get_center()
	draw_line(Vector2(center.x, area.position.y), Vector2(center.x, area.end.y), WHITE, 2)
	draw_arc(center, area.size.y * 0.14, 0, TAU, 48, WHITE, 2)
	draw_circle(center, 3, WHITE)
	var box_w := area.size.x * 0.18
	var box_h := area.size.y * 0.54
	draw_rect(Rect2(Vector2(area.position.x, center.y - box_h * 0.5), Vector2(box_w, box_h)), WHITE, false, 2)
	draw_rect(Rect2(Vector2(area.end.x - box_w, center.y - box_h * 0.5), Vector2(box_w, box_h)), WHITE, false, 2)
	# Subtle broadcast-style crowd/player shadows and tactical markers.
	var drift := sin(elapsed * 1.8) * 0.018
	for i in range(11):
		var row := int(i / 4)
		var col := i % 4
		var x := 0.10 + float(col) * 0.095 + drift
		var y := 0.18 + float(row) * 0.31 + (0.05 if col % 2 == 0 else -0.03)
		var point := Vector2(area.position.x + x * area.size.x, area.position.y + y * area.size.y)
		draw_circle(point + Vector2(0, 4), 9, Color(0, 0, 0, 0.24))
		draw_circle(point, 7, CYAN)
		draw_circle(point + Vector2(-2, -2), 2, Color("#ffffff", 0.7))
	for i in range(11):
		var row := int(i / 4)
		var col := i % 4
		var x := 0.90 - float(col) * 0.095 - drift
		var y := 0.18 + float(row) * 0.31 + (0.05 if col % 2 == 0 else -0.03)
		var point := Vector2(area.position.x + x * area.size.x, area.position.y + y * area.size.y)
		draw_circle(point + Vector2(0, 4), 9, Color(0, 0, 0, 0.24))
		draw_circle(point, 7, RED)
		draw_circle(point + Vector2(-2, -2), 2, Color("#ffffff", 0.7))
	var ball := Vector2(area.position.x + ball_position.x * area.size.x, area.position.y + ball_position.y * area.size.y)
	draw_circle(ball + Vector2(0, 2), 8, Color(0, 0, 0, 0.3))
	draw_circle(ball, 5, Color("#ffffff"))
	draw_arc(ball, 7, 0, TAU, 20, Color("#1b2735"), 1.2)

func _draw() -> void:
	var full := Rect2(Vector2.ZERO, size)
	draw_rect(full, Color("#071321"), true)
	var stand_area := Rect2(Vector2(4, 4), Vector2(maxf(1, size.x - 8), size.y * 0.27))
	_draw_stands(stand_area)
	var pitch_area := Rect2(Vector2(8, size.y * 0.255), Vector2(maxf(1, size.x - 16), size.y * 0.70))
	_draw_pitch(pitch_area)
	if celebration > 0.0:
		var alpha := minf(0.75, celebration * 0.6)
		draw_rect(pitch_area, Color("#ffd36a", alpha * 0.12), true)
		draw_string(ThemeDB.fallback_font, Vector2(size.x * 0.5 - 56, size.y * 0.59), "GOOOOL!", HORIZONTAL_ALIGNMENT_CENTER, 112, 28, Color("#fff1a8", alpha + 0.2))
