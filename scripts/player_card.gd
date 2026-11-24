extends PanelContainer
class_name DynastyPlayerCard

signal swap_requested(source_id: int, target_id: int)
signal sell_requested(player_id: int)
signal renew_requested(player_id: int)
signal detail_requested(player_id: int)

var player: Dictionary = {}

const GOLD := Color("#e7bd68")
const ICE := Color("#8ce5ff")
const MUTED := Color("#91a4ba")

func _format_money(value: int) -> String:
	var raw := str(maxi(0, value))
	var formatted := ""
	for i in range(raw.length()):
		if i > 0 and (raw.length() - i) % 3 == 0:
			formatted += "."
		formatted += raw.substr(i, 1)
	return formatted

func _make_label(value: String, font_size: int, color: Color, centered := false) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _make_small_button(caption: String, callback: Callable, disabled := false) -> Button:
	var button := Button.new()
	button.text = caption
	button.disabled = disabled
	button.custom_minimum_size = Vector2(0, 34)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.add_theme_font_size_override("font_size", 11)
	button.pressed.connect(callback)
	return button

func setup(data: Dictionary) -> void:
	player = data
	custom_minimum_size = Vector2(166, 294)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var shell := StyleBoxFlat.new()
	shell.bg_color = Color("#111f31")
	shell.border_color = Color("#344c67")
	shell.set_border_width_all(1)
	shell.set_corner_radius_all(14)
	shell.shadow_color = Color(0, 0, 0, 0.32)
	shell.shadow_size = 7
	shell.shadow_offset = Vector2(0, 3)
	shell.content_margin_left = 8
	shell.content_margin_right = 8
	shell.content_margin_top = 8
	shell.content_margin_bottom = 8
	add_theme_stylebox_override("panel", shell)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	add_child(box)

	var portrait_frame := PanelContainer.new()
	portrait_frame.custom_minimum_size = Vector2(0, 132)
	portrait_frame.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var portrait_style := StyleBoxFlat.new()
	portrait_style.bg_color = Color("#172d45")
	portrait_style.border_color = Color("#4c6a88")
	portrait_style.set_border_width_all(1)
	portrait_style.set_corner_radius_all(10)
	portrait_frame.add_theme_stylebox_override("panel", portrait_style)
	box.add_child(portrait_frame)

	var portrait = preload("res://scripts/player_portrait.gd").new()
	portrait.custom_minimum_size = Vector2(0, 126)
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.seed_value = int(player.get("portrait_seed", player.get("id", 1)))
	portrait.player_name = str(player.get("name", "Player"))
	portrait_frame.add_child(portrait)

	var rating_row := HBoxContainer.new()
	rating_row.alignment = BoxContainer.ALIGNMENT_CENTER
	rating_row.add_theme_constant_override("separation", 7)
	box.add_child(rating_row)
	var rating_value := int(player.get("rating", 0))
	var rating := _make_label(str(rating_value), 27, GOLD if rating_value >= 80 else ICE if rating_value >= 68 else Color("#d1dbe5"), true)
	rating.add_theme_font_size_override("font_size", 27)
	rating_row.add_child(rating)
	var overall_tag := _make_label("OVR", 10, MUTED, true)
	overall_tag.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	rating_row.add_child(overall_tag)
	var position_tag := _make_label(str(player.get("position", "—")), 12, Color("#ffffff"), true)
	position_tag.add_theme_stylebox_override("normal", _tag_style(Color("#24445f"), Color("#78dff1")))
	box.add_child(position_tag)

	var name_label := _make_label(str(player.get("name", "Giocatore")), 14, Color("#f2f6fb"), true)
	name_label.add_theme_font_size_override("font_size", 14)
	box.add_child(name_label)

	var details := _make_label(str(player.get("age", 0)) + " ANNI   •   " + str(player.get("fitness", 0)) + "% FORMA", 10, MUTED, true)
	box.add_child(details)

	var condition := _make_label("", 10, Color("#a8d7bd"), true)
	var injury_turns := int(player.get("injury", 0))
	var suspension_turns := int(player.get("suspension", 0))
	if injury_turns > 0:
		condition.text = "INFORTUNATO • " + str(injury_turns) + " turni"
		condition.add_theme_color_override("font_color", Color("#ff858b"))
	elif suspension_turns > 0:
		condition.text = "SQUALIFICATO • " + str(suspension_turns) + " turni"
		condition.add_theme_color_override("font_color", Color("#ffc46e"))
	elif bool(player.get("loan", false)):
		condition.text = "IN PRESTITO"
		condition.add_theme_color_override("font_color", GOLD)
	else:
		condition.text = "MORALE " + str(player.get("morale", 70)) + "%  •  " + str(player.get("contract", 0)) + " ANNI"
	box.add_child(condition)

	var wage := _make_label("€" + _format_money(int(player.get("wage", 0))) + " / SETT.", 10, MUTED, true)
	box.add_child(wage)

	var origin := _make_label("ROSA REALE" if bool(player.get("real_player", false)) else "PROFILO GENERATO", 9, Color("#78c8a1") if bool(player.get("real_player", false)) else Color("#9aabc0"), true)
	box.add_child(origin)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 5)
	box.add_child(actions)
	var player_id := int(player.get("id", -1))
	var profile := _make_small_button("PROFILO", func(): detail_requested.emit(player_id))
	actions.add_child(profile)
	var renew := _make_small_button("RINNOVA" if not bool(player.get("loan", false)) else "PRESTITO", func(): renew_requested.emit(player_id), bool(player.get("loan", false)))
	actions.add_child(renew)
	var sell := _make_small_button("VENDI", func(): sell_requested.emit(player_id), bool(player.get("loan", false)))
	box.add_child(sell)

func _tag_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 8
	style.content_margin_right = 8
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style

func _get_drag_data(_at_position: Vector2) -> Variant:
	var preview := PanelContainer.new()
	var preview_style := StyleBoxFlat.new()
	preview_style.bg_color = Color("#18344f")
	preview_style.border_color = ICE
	preview_style.set_border_width_all(2)
	preview_style.set_corner_radius_all(9)
	preview.add_theme_stylebox_override("panel", preview_style)
	var preview_label := Label.new()
	preview_label.text = "  " + str(player.get("name", "Giocatore")) + "  "
	preview_label.add_theme_color_override("font_color", Color("#ffffff"))
	preview.add_child(preview_label)
	set_drag_preview(preview)
	return {"player_id": int(player.get("id", -1))}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and int(data.get("player_id", -1)) != int(player.get("id", -1))

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	swap_requested.emit(int(data.get("player_id", -1)), int(player.get("id", -1)))
