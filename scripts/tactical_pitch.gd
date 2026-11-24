extends Control
signal slots_swapped(first_slot: int, second_slot: int)

var players: Array = []
var slot_ids: Array = []
var formation := "4-3-3"
var dragging_slot := -1
var pointer := Vector2.ZERO
var selected_slot := -1

const LINE := Color("#e7f5ec")
const PITCH_DARK := Color("#12613f")
const PITCH_LIGHT := Color("#18764b")
const ACCENT := Color("#63e3f1")
const GOLD := Color("#ffd36a")

func _ready() -> void:
	custom_minimum_size = Vector2(0, 450)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mouse_filter = Control.MOUSE_FILTER_STOP
	queue_redraw()

func set_lineup(player_list: Array, ids: Array, module: String) -> void:
	players = player_list
	slot_ids = ids
	formation = module
	queue_redraw()

func _positions() -> Array:
	match formation:
		"4-2-3-1":
			return [Vector2(0.5,0.91),Vector2(0.14,0.72),Vector2(0.38,0.72),Vector2(0.62,0.72),Vector2(0.86,0.72),Vector2(0.35,0.57),Vector2(0.65,0.57),Vector2(0.16,0.38),Vector2(0.5,0.36),Vector2(0.84,0.38),Vector2(0.5,0.17)]
		"4-4-2":
			return [Vector2(0.5,0.91),Vector2(0.14,0.72),Vector2(0.38,0.72),Vector2(0.62,0.72),Vector2(0.86,0.72),Vector2(0.14,0.49),Vector2(0.38,0.49),Vector2(0.62,0.49),Vector2(0.86,0.49),Vector2(0.38,0.19),Vector2(0.62,0.19)]
		"3-5-2":
			return [Vector2(0.5,0.91),Vector2(0.25,0.72),Vector2(0.5,0.72),Vector2(0.75,0.72),Vector2(0.12,0.48),Vector2(0.32,0.53),Vector2(0.5,0.47),Vector2(0.68,0.53),Vector2(0.88,0.48),Vector2(0.38,0.19),Vector2(0.62,0.19)]
		_:
			return [Vector2(0.5,0.91),Vector2(0.14,0.72),Vector2(0.38,0.72),Vector2(0.62,0.72),Vector2(0.86,0.72),Vector2(0.25,0.49),Vector2(0.5,0.52),Vector2(0.75,0.49),Vector2(0.18,0.2),Vector2(0.5,0.16),Vector2(0.82,0.2)]

func _slot_player(slot: int) -> Dictionary:
	if slot < 0 or slot >= slot_ids.size():
		return {}
	for p in players:
		if int(p.get("id", -1)) == int(slot_ids[slot]):
			return p
	return {}

func _draw_pitch(area: Rect2) -> void:
	draw_rect(area, PITCH_DARK, true)
	var stripe_count := 10
	for i in range(stripe_count):
		if i % 2 == 0:
			var stripe := Rect2(area.position.x + area.size.x * float(i) / stripe_count, area.position.y, area.size.x / stripe_count, area.size.y)
			draw_rect(stripe, PITCH_LIGHT, true)
	# A soft outer frame and complete pitch markings.
	draw_rect(area, LINE, false, 2.2)
	var mid_y := area.position.y + area.size.y * 0.5
	draw_line(Vector2(area.position.x, mid_y), Vector2(area.end.x, mid_y), LINE, 2)
	draw_arc(Vector2(area.get_center().x, mid_y), area.size.x * 0.145, 0, TAU, 64, LINE, 2)
	draw_circle(Vector2(area.get_center().x, mid_y), 3.5, LINE)
	var box_w := area.size.x * 0.62
	var box_d := area.size.y * 0.16
	var six_w := area.size.x * 0.30
	var six_d := area.size.y * 0.065
	var box_x := area.get_center().x - box_w * 0.5
	var six_x := area.get_center().x - six_w * 0.5
	# Top and bottom penalty areas, six-yard boxes and penalty spots.
	draw_rect(Rect2(Vector2(box_x, area.position.y), Vector2(box_w, box_d)), LINE, false, 2)
	draw_rect(Rect2(Vector2(box_x, area.end.y - box_d), Vector2(box_w, box_d)), LINE, false, 2)
	draw_rect(Rect2(Vector2(six_x, area.position.y), Vector2(six_w, six_d)), LINE, false, 2)
	draw_rect(Rect2(Vector2(six_x, area.end.y - six_d), Vector2(six_w, six_d)), LINE, false, 2)
	draw_circle(Vector2(area.get_center().x, area.position.y + area.size.y * 0.105), 3, LINE)
	draw_circle(Vector2(area.get_center().x, area.end.y - area.size.y * 0.105), 3, LINE)
	# Penalty arcs are clipped visually by the box edge.
	draw_arc(Vector2(area.get_center().x, area.position.y + box_d), area.size.x * 0.145, 0.22, PI - 0.22, 32, LINE, 2)
	draw_arc(Vector2(area.get_center().x, area.end.y - box_d), area.size.x * 0.145, PI + 0.22, TAU - 0.22, 32, LINE, 2)
	# Goals sit just outside each end line.
	var goal_w := area.size.x * 0.19
	var goal_d := 8.0
	var goal_x := area.get_center().x - goal_w * 0.5
	draw_rect(Rect2(Vector2(goal_x, area.position.y - goal_d), Vector2(goal_w, goal_d)), Color("#c8d7e2"), false, 2)
	draw_rect(Rect2(Vector2(goal_x, area.end.y), Vector2(goal_w, goal_d)), Color("#c8d7e2"), false, 2)
	# Corner arcs.
	for corner in [Vector2(area.position.x, area.position.y), Vector2(area.end.x, area.position.y), Vector2(area.position.x, area.end.y), Vector2(area.end.x, area.end.y)]:
		var start_angle := 0.0
		if corner.x < area.get_center().x and corner.y < area.get_center().y:
			start_angle = 0.0
		elif corner.x > area.get_center().x and corner.y < area.get_center().y:
			start_angle = PI * 0.5
		elif corner.x > area.get_center().x:
			start_angle = PI
		else:
			start_angle = PI * 1.5
		draw_arc(corner, 11, start_angle, start_angle + PI * 0.5, 16, LINE, 1.5)

func _draw_player(center: Vector2, slot: int, player: Dictionary) -> void:
	var selected := slot == selected_slot or slot == dragging_slot
	var radius := 21.0 if selected else 18.0
	# Drop shadow, luminous rim and shirt disc.
	draw_circle(center + Vector2(0, 4), radius + 2, Color(0, 0, 0, 0.28))
	draw_circle(center, radius + 3, GOLD if selected else Color("#d9f8ff"))
	draw_circle(center, radius, Color("#f4fbff") if selected else ACCENT)
	draw_circle(center, radius - 3, Color("#10263a"))
	var number := str(player.get("number", slot + 1))
	var font := ThemeDB.fallback_font
	draw_string(font, center + Vector2(0, 5), number, HORIZONTAL_ALIGNMENT_CENTER, 34, 13, Color.WHITE)
	var full_name := str(player.get("name", "Giocatore " + str(slot + 1)))
	var words := full_name.split(" ")
	var short_name := str(words[words.size() - 1]) if not words.is_empty() else full_name
	if short_name.length() > 13:
		short_name = short_name.substr(0, 12) + "…"
	var label_width := 92.0
	var label_rect := Rect2(center + Vector2(-label_width * 0.5, 25), Vector2(label_width, 19))
	draw_rect(label_rect, Color("#071522", 0.88), true)
	draw_string(font, center + Vector2(0, 39), short_name, HORIZONTAL_ALIGNMENT_CENTER, label_width, 10, Color("#f4f8ff"))

func _draw() -> void:
	var area := Rect2(Vector2(12, 14), Vector2(maxf(0, size.x - 24), maxf(0, size.y - 28)))
	_draw_pitch(area)
	var points := _positions()
	for i in range(mini(11, points.size())):
		var center := Vector2(area.position.x + points[i].x * area.size.x, area.position.y + points[i].y * area.size.y)
		_draw_player(center, i, _slot_player(i))
	if dragging_slot >= 0:
		draw_circle(pointer + Vector2(0, 4), 28, Color(0, 0, 0, 0.25))
		draw_circle(pointer, 27, Color(GOLD, 0.22))
		draw_arc(pointer, 27, 0, TAU, 48, GOLD, 2)

func _nearest_slot(pos: Vector2) -> int:
	var points := _positions()
	var area := Rect2(Vector2(12, 14), Vector2(maxf(0, size.x - 24), maxf(0, size.y - 28)))
	var best := -1
	var distance := 100000.0
	for i in range(mini(11, points.size())):
		var center := Vector2(area.position.x + points[i].x * area.size.x, area.position.y + points[i].y * area.size.y)
		var d := center.distance_to(pos)
		if d < distance and d < 56:
			distance = d
			best = i
	return best

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging_slot = _nearest_slot(event.position)
			selected_slot = dragging_slot
			pointer = event.position
			queue_redraw()
		elif dragging_slot >= 0:
			var target := _nearest_slot(event.position)
			if target >= 0 and target != dragging_slot:
				slots_swapped.emit(dragging_slot, target)
			dragging_slot = -1
			queue_redraw()
	elif event is InputEventMouseMotion and dragging_slot >= 0:
		pointer = event.position
		queue_redraw()
	elif event is InputEventScreenTouch:
		if event.pressed:
			dragging_slot = _nearest_slot(event.position)
			selected_slot = dragging_slot
			pointer = event.position
			queue_redraw()
		elif dragging_slot >= 0:
			var target := _nearest_slot(event.position)
			if target >= 0 and target != dragging_slot:
				slots_swapped.emit(dragging_slot, target)
			dragging_slot = -1
			queue_redraw()
	elif event is InputEventScreenDrag and dragging_slot >= 0:
		pointer = event.position
		queue_redraw()
