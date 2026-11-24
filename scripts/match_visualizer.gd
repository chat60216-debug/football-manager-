extends Control
class_name DynastyMatchVisualizer

var report: Dictionary = {}
var elapsed := 0.0
var celebration := 0.0
var ball_from := Vector2(0.35, 0.55)
var ball_to := Vector2(0.68, 0.42)
var ball_position := Vector2(0.5, 0.5)
var event_cursor := 0

const GRASS_A := Color("#12613f")
const GRASS_B := Color("#18764b")
const WHITE := Color("#f3fff7")
const CYAN := Color("#67e6f4")
const RED := Color("#ff6578")

func setup(data: Dictionary) -> void:
	report = data.duplicate(true)
	custom_minimum_size = Vector2(0, 330)
	elapsed = 0.0
	celebration = 0.0
	queue_redraw()

func _process(delta: float) -> void:
	elapsed += delta
	if celebration > 0.0:
		celebration = maxf(0.0, celebration - delta)
	var phase := fposmod(elapsed * 0.24, 1.0)
	var arc := sin(phase * PI)
	ball_position = Vector2(0.18 + phase * 0.64, 0.5 + sin(elapsed * 1.8) * 0.19 * arc)
	var events: Array = report.get("events", [])
	if event_cursor < events.size() and elapsed > float(event_cursor) * 0.11:
		var e: Dictionary = events[event_cursor]
		if str(e.get("type", "")) == "goal":
			celebration = 2.0
		event_cursor += 1
	queue_redraw()

func _draw() -> void:
	var area := Rect2(Vector2(8, 8), Vector2(maxf(1, size.x - 16), maxf(1, size.y - 16)))
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
	# Animated tactical shape: both teams shift as the ball travels.
	var drift := sin(elapsed * 1.8) * 0.025
	for i in range(11):
		var row := int(i / 4)
		var col := i % 4
		var x := 0.10 + float(col) * 0.095 + drift
		var y := 0.18 + float(row) * 0.31 + (0.05 if col % 2 == 0 else -0.03)
		var point := Vector2(area.position.x + x * area.size.x, area.position.y + y * area.size.y)
		draw_circle(point + Vector2(0, 3), 8, Color(0, 0, 0, 0.25))
		draw_circle(point, 7, CYAN)
	for i in range(11):
		var row := int(i / 4)
		var col := i % 4
		var x := 0.90 - float(col) * 0.095 - drift
		var y := 0.18 + float(row) * 0.31 + (0.05 if col % 2 == 0 else -0.03)
		var point := Vector2(area.position.x + x * area.size.x, area.position.y + y * area.size.y)
		draw_circle(point + Vector2(0, 3), 8, Color(0, 0, 0, 0.25))
		draw_circle(point, 7, RED)
	var ball := Vector2(area.position.x + ball_position.x * area.size.x, area.position.y + ball_position.y * area.size.y)
	draw_circle(ball, 8, Color("#102030"))
	draw_circle(ball, 5, Color("#ffffff"))
	if celebration > 0.0:
		var alpha := minf(0.75, celebration * 0.6)
		draw_rect(area, Color("#ffd36a", alpha * 0.18), true)
		draw_string(ThemeDB.fallback_font, Vector2(center.x - 56, center.y + 8), "GOOOOL!", HORIZONTAL_ALIGNMENT_CENTER, 112, 28, Color("#fff1a8", alpha + 0.2))
