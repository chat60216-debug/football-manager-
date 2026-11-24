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
	button.add_theme_font_size_override("font_size", 10)
	button.pressed.connect(callback)
	return button

func _tag_style(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(6)
	style.content_margin_left = 7
	style.content_margin_right = 7
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	return style

func _progress_row(parent: VBoxContainer, caption: String, value: int, tint: Color) -> void:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	parent.add_child(row)
	var title := _make_label(caption, 9, MUTED)
	title.custom_minimum_size = Vector2(52, 16)
	row.add_child(title)
	var bar := ProgressBar.new()
	bar.min_value = 0
	bar.max_value = 100
	bar.value = clampi(value, 0, 100)
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(0, 8)
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_theme_stylebox_override("background", _tag_style(Color("#0a1725"), Color("#23394f")))
	var fill := StyleBoxFlat.new()
	fill.bg_color = tint
	fill.set_corner_radius_all(4)
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)
	var score := _make_label(str(value), 9, Color("#dce8f4"))
	score.custom_minimum_size = Vector2(25, 16)
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(score)

func setup(data: Dictionary) -> void:
	player = data
	custom_minimum_size = Vector2(190, 326)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var starter := bool(player.get("starting_xi", false))
	var captain := bool(player.get("captain", false))
	var injured := int(player.get("injury", 0)) > 0
	var suspended := int(player.get("suspension", 0)) > 0
	var shell := StyleBoxFlat.new()
	shell.bg_color = Color("#14253a") if starter else Color("#101e30")
	shell.border_color = GOLD if captain else Color("#39718a") if starter else Color("#293e55")
	shell.set_border_width_all(2 if captain else 1)
	shell.set_corner_radius_all(13)
	shell.shadow_color = Color(0, 0, 0, 0.28)
	shell.shadow_size = 5
	shell.shadow_offset = Vector2(0, 2)
	shell.content_margin_left = 8
	shell.content_margin_right = 8
	shell.content_margin_top = 8
	shell.content_margin_bottom = 8
	add_theme_stylebox_override("panel", shell)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 5)
	add_child(box)

	var hero := PanelContainer.new()
	hero.custom_minimum_size = Vector2(0, 120)
	var hero_style := StyleBoxFlat.new()
	hero_style.bg_color = Color("#0c1a2a")
	hero_style.border_color = Color("#314b65")
	hero_style.set_border_width_all(1)
	hero_style.set_corner_radius_all(9)
	hero.add_theme_stylebox_override("panel", hero_style)
	box.add_child(hero)
	var portrait = preload("res://scripts/player_portrait.gd").new()
	portrait.custom_minimum_size = Vector2(0, 116)
	portrait.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait.seed_value = int(player.get("portrait_seed", player.get("id", 1)))
	portrait.player_name = str(player.get("name", "Player"))
	hero.add_child(portrait)

	var identity := HBoxContainer.new()
	identity.add_theme_constant_override("separation", 5)
	box.add_child(identity)
	var rating_value := int(player.get("rating", 0))
	var rating := _make_label(str(rating_value), 28, GOLD if rating_value >= 80 else ICE if rating_value >= 68 else Color("#d1dbe5"))
	rating.add_theme_font_size_override("font_size", 28)
	identity.add_child(rating)
	var rating_meta := VBoxContainer.new()
	rating_meta.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rating_meta.add_theme_constant_override("separation", 0)
	identity.add_child(rating_meta)
	rating_meta.add_child(_make_label("OVERALL", 9, MUTED))
	rating_meta.add_child(_make_label(str(player.get("position", "—")) + "  •  " + str(player.get("age", 0)) + " ANNI", 11, Color("#edf4fb")))
	var status := "CAPITANO" if captain else "TITOLARE" if starter else "RISERVA"
	var status_panel := PanelContainer.new()
	status_panel.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	status_panel.add_theme_stylebox_override("panel", _tag_style(Color("#3b3020") if captain or starter else Color("#1b2e43"), GOLD if captain or starter else Color("#58718c")))
	var status_label := _make_label(status, 9, GOLD if captain or starter else Color("#b5c8dc"), true)
	status_panel.add_child(status_label)
	identity.add_child(status_panel)

	var player_name := _make_label(str(player.get("name", "Giocatore")), 13, Color("#f3f7fc"))
	player_name.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(player_name)
	var club_line := _make_label(str(player.get("club", "Club non indicato")), 9, MUTED)
	club_line.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	box.add_child(club_line)

	_progress_row(box, "CONDIZ.", int(player.get("fitness", 100)), Color("#75d7a0") if int(player.get("fitness", 100)) >= 70 else Color("#e6b65e") if int(player.get("fitness", 100)) >= 45 else Color("#ee777e"))
	_progress_row(box, "MORALE", int(player.get("morale", 70)), Color("#79cbe8") if int(player.get("morale", 70)) >= 55 else Color("#e6b65e"))
	var condition := "INFORTUNATO • " + str(player.get("injury", 0)) + " TURNI" if injured else "SQUALIFICATO • " + str(player.get("suspension", 0)) + " TURNI" if suspended else "IN PRESTITO" if bool(player.get("loan", false)) else str(player.get("contract", 0)) + " ANNI DI CONTRATTO"
	var condition_label := _make_label(condition, 9, Color("#ff8d93") if injured else Color("#ffc46e") if suspended or bool(player.get("loan", false)) else Color("#9db2c7"))
	box.add_child(condition_label)
	var wage := _make_label("€" + str(int(player.get("wage", 0))) + " / SETT.   •   " + ("DATI IMPORTATI" if bool(player.get("real_player", false)) else "GENERATO"), 9, MUTED)
	box.add_child(wage)

	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 5)
	box.add_child(actions)
	var player_id := int(player.get("id", -1))
	actions.add_child(_make_small_button("PROFILO", func(): detail_requested.emit(player_id)))
	actions.add_child(_make_small_button("RINNOVA", func(): renew_requested.emit(player_id), bool(player.get("loan", false))))
	box.add_child(_make_small_button("VENDI / LISTA", func(): sell_requested.emit(player_id), bool(player.get("loan", false))))

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
