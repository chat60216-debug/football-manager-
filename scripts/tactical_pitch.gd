extends Control
signal slots_swapped(first_slot: int, second_slot: int)

var players: Array = []
var slot_ids: Array = []
var formation := "4-3-3"
var dragging_slot := -1
var pointer := Vector2.ZERO
var selected_slot := -1

func _ready() -> void:
	custom_minimum_size = Vector2(0, 430)
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

func _draw() -> void:
	var area := Rect2(Vector2(10, 8), Vector2(maxf(0, size.x - 20), maxf(0, size.y - 16)))
	draw_rect(area, Color("#176b45"), true)
	draw_rect(area, Color("#d8f2df"), false, 3)
	draw_line(Vector2(area.position.x, area.position.y + area.size.y * 0.5), Vector2(area.end.x, area.position.y + area.size.y * 0.5), Color("#d8f2df"), 2)
	draw_arc(Vector2(size.x * 0.5, area.position.y + area.size.y * 0.5), 42, 0, TAU, 48, Color("#d8f2df"), 2)
	draw_rect(Rect2(Vector2(size.x*0.5-95, area.position.y), Vector2(190, 52)), Color("#d8f2df"), false, 2)
	draw_rect(Rect2(Vector2(size.x*0.5-95, area.end.y-52), Vector2(190, 52)), Color("#d8f2df"), false, 2)
	var points := _positions()
	var font := ThemeDB.fallback_font
	for i in range(mini(11, points.size())):
		var center := Vector2(area.position.x + points[i].x * area.size.x, area.position.y + points[i].y * area.size.y)
		var player := _slot_player(i)
		var is_selected := i == selected_slot or i == dragging_slot
		draw_circle(center, 23 if is_selected else 20, Color("#ffe082") if is_selected else Color("#8ce5ff"))
		draw_arc(center, 22, 0, TAU, 32, Color("#071522"), 2)
		var shirt := str(i + 1)
		draw_string(font, center + Vector2(-5, 5), shirt, HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#071522"))
		var name := str(player.get("name", "Slot " + str(i + 1)))
		var words := name.split(" ")
		var short_name := words[words.size()-1] if words.size() > 0 else name
		if short_name.length() > 12:
			short_name = short_name.substr(0, 11) + "."
		draw_string(font, center + Vector2(-44, 40), short_name, HORIZONTAL_ALIGNMENT_CENTER, 88, 12, Color.WHITE)
	if dragging_slot >= 0:
		draw_circle(pointer, 26, Color(1, 0.88, 0.35, 0.35))

func _nearest_slot(pos: Vector2) -> int:
	var points := _positions()
	var area := Rect2(Vector2(10, 8), Vector2(maxf(0, size.x - 20), maxf(0, size.y - 16)))
	var best := -1
	var distance := 100000.0
	for i in range(mini(11, points.size())):
		var center := Vector2(area.position.x + points[i].x * area.size.x, area.position.y + points[i].y * area.size.y)
		var d := center.distance_to(pos)
		if d < distance and d < 48:
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
