extends PanelContainer
class_name DynastyPlayerCard

signal swap_requested(source_id: int, target_id: int)

var player: Dictionary = {}

func setup(data: Dictionary) -> void:
	player = data
	custom_minimum_size = Vector2(145, 178)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	add_child(box)
	var rating := Label.new()
	rating.text = str(player.get("rating", 0)) + " OVR"
	rating.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating.add_theme_font_size_override("font_size", 24)
	rating.add_theme_color_override("font_color", Color("#8ce5ff"))
	box.add_child(rating)
	var pos := Label.new()
	pos.text = str(player.get("position", ""))
	pos.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(pos)
	var name_label := Label.new()
	name_label.text = str(player.get("name", "Giocatore"))
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(name_label)
	var details := Label.new()
	details.text = str(player.get("age", 0)) + " anni\n" + str(player.get("fitness", 0)) + "% forma"
	details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(details)
	var hint := Label.new()
	hint.text = "Trascina per scambiare"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 10)
	box.add_child(hint)

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := Label.new()
	preview.text = str(player.get("name", "Giocatore"))
	preview.add_theme_color_override("font_color", Color("#8ce5ff"))
	set_drag_preview(preview)
	return {"player_id": int(player.get("id", -1))}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and int(data.get("player_id", -1)) != int(player.get("id", -1))

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	swap_requested.emit(int(data.get("player_id", -1)), int(player.get("id", -1)))
