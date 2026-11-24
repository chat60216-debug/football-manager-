extends PanelContainer
class_name DynastyPlayerCard

signal swap_requested(source_id: int, target_id: int)
signal sell_requested(player_id: int)
signal renew_requested(player_id: int)
signal detail_requested(player_id: int)

var player: Dictionary = {}

class PlayerPortrait extends Control:
	var seed_value: int = 1
	func _draw() -> void:
		var rng := RandomNumberGenerator.new()
		rng.seed = seed_value
		var skin_tones := [Color("#f2c7a5"), Color("#d9a078"), Color("#b97850"), Color("#8d573d"), Color("#f0d0b0"), Color("#c58b68")]
		var hair_colors := [Color("#241a18"), Color("#493126"), Color("#17191f"), Color("#a97842"), Color("#d6c18d")]
		var kit_colors := [Color("#7d2be0"), Color("#168acb"), Color("#d8324b"), Color("#e5e9ef"), Color("#16865c"), Color("#e39b20")]
		var skin: Color = skin_tones[rng.randi_range(0, skin_tones.size() - 1)]
		var hair: Color = hair_colors[rng.randi_range(0, hair_colors.size() - 1)]
		var kit: Color = kit_colors[rng.randi_range(0, kit_colors.size() - 1)]
		var w := size.x
		var h := size.y
		draw_rect(Rect2(Vector2.ZERO, size), Color("#14253b"))
		draw_rect(Rect2(Vector2(0, h * 0.72), Vector2(w, h * 0.28)), Color("#203d5b"))
		draw_colored_polygon(PackedVector2Array([Vector2(w*0.12,h),Vector2(w*0.22,h*0.76),Vector2(w*0.38,h*0.68),Vector2(w*0.62,h*0.68),Vector2(w*0.78,h*0.76),Vector2(w*0.9,h)]), kit)
		draw_rect(Rect2(Vector2(w*0.43,h*0.59),Vector2(w*0.14,h*0.16)),skin)
		draw_circle(Vector2(w*0.5,h*0.39),minf(w,h)*0.235,skin)
		draw_circle(Vector2(w*0.5,h*0.29),minf(w,h)*0.235,hair)
		draw_rect(Rect2(Vector2(w*0.265,h*0.31),Vector2(w*0.47,h*0.09)),hair)
		draw_circle(Vector2(w*0.415,h*0.4),w*0.018,Color("#20212a"))
		draw_circle(Vector2(w*0.585,h*0.4),w*0.018,Color("#20212a"))
		draw_line(Vector2(w*0.46,h*0.49),Vector2(w*0.54,h*0.49),Color("#854f43"),maxf(1.0,w*0.012))
		draw_rect(Rect2(Vector2(w*0.31,h*0.67),Vector2(w*0.38,h*0.035)),Color(1,1,1,0.65))

func _format_money(value: int) -> String:
	var raw := str(maxi(0, value))
	var formatted := ""
	for i in range(raw.length()):
		if i > 0 and (raw.length() - i) % 3 == 0:
			formatted += "."
		formatted += raw.substr(i, 1)
	return formatted

func setup(data: Dictionary) -> void:
	player = data
	custom_minimum_size = Vector2(145, 226)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 3)
	add_child(box)
	var portrait := PlayerPortrait.new()
	portrait.custom_minimum_size = Vector2(120, 112)
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.seed_value = int(player.get("portrait_seed", player.get("id", 1)))
	box.add_child(portrait)
	var rating_value := int(player.get("rating", 0))
	var rating := Label.new()
	rating.text = str(rating_value) + " OVR"
	rating.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rating.add_theme_font_size_override("font_size", 24)
	var rating_color := Color("#e5bd69") if rating_value >= 80 else Color("#8ce5ff") if rating_value >= 68 else Color("#c4d0dc")
	rating.add_theme_color_override("font_color", rating_color)
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
	details.text = str(player.get("age", 0)) + " anni  •  " + str(player.get("fitness", 0)) + "% forma\n" + str(player.get("nationality", ""))
	details.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(details)
	var condition := Label.new()
	var injury_turns := int(player.get("injury", 0))
	var suspension_turns := int(player.get("suspension", 0))
	if injury_turns > 0:
		condition.text = "INFORTUNATO • " + str(injury_turns) + " turni"
		condition.add_theme_color_override("font_color", Color("#ff7d83"))
	elif suspension_turns > 0:
		condition.text = "SQUALIFICATO • " + str(suspension_turns) + " turni"
		condition.add_theme_color_override("font_color", Color("#ffbd69"))
	else:
		condition.text = "Morale " + str(player.get("morale", 70)) + "% • Contratto " + str(player.get("contract", 0)) + " anni"
		condition.add_theme_color_override("font_color", Color("#9fc6b4"))
	condition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	condition.add_theme_font_size_override("font_size", 10)
	box.add_child(condition)
	var wage := Label.new()
	wage.text = "€" + _format_money(int(player.get("wage", 0))) + "/sett."
	wage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wage.add_theme_font_size_override("font_size", 10)
	wage.add_theme_color_override("font_color", Color("#9eafc1"))
	box.add_child(wage)
	var hint := Label.new()
	hint.text = ("Calciatore reale importato • avatar generato" if bool(player.get("real_player", false)) else "Giocatore generato • avatar unico") + "\ntrascina per scambiare"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 10)
	box.add_child(hint)
	var profile := Button.new()
	profile.text = "Apri profilo"
	profile.pressed.connect(func(): detail_requested.emit(int(player.get("id", -1))))
	box.add_child(profile)
	var renew := Button.new()
	renew.text = "Prestito in corso" if bool(player.get("loan", false)) else "Rinnova contratto"
	renew.disabled = bool(player.get("loan", false))
	renew.pressed.connect(func(): renew_requested.emit(int(player.get("id", -1))))
	box.add_child(renew)
	var sell := Button.new()
	sell.text = "Giocatore in prestito" if bool(player.get("loan", false)) else "Vendi"
	sell.disabled = bool(player.get("loan", false))
	sell.pressed.connect(func(): sell_requested.emit(int(player.get("id", -1))))
	box.add_child(sell)

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
