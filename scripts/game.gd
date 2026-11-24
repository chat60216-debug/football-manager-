extends Control

const SAVE_PATH := "user://dynasty_save.json"
const CLUBS := ["AC Nova Milano", "Torino Athletic", "Bologna FC", "Lazio", "Real Sociedad", "Valencia", "Lyon", "Marseille", "Hamburg", "Stuttgart", "Bristol City", "Derby County", "Sporting CP", "Ajax", "Celtic"]
const FIRST := ["Luca", "Marco", "Andrea", "Matteo", "Davide", "Nicolò", "Samuele", "Tommaso", "Riccardo", "Edoardo", "Gabriel", "Leonardo", "Milan", "Noah", "Adam", "Diego", "Thiago", "Jonas", "Erik", "Hugo"]
const LAST := ["Rossi", "Bianchi", "Romano", "Conti", "Moretti", "Costa", "Marin", "Silva", "Meyer", "Kovac", "Dubois", "Santos", "Garcia", "Novak", "Ferrari", "Rinaldi", "Walker", "Bennett", "Petrov", "Lopez"]
const POSITIONS := ["POR", "TD", "DC", "DC", "TS", "CC", "CC", "CDC", "COC", "AD", "AS", "ATT"]
const ROLES := ["Cruciale", "Importante", "Promessa", "Turnover", "Sporadico"]
const COUNTRIES := ["Italia", "Inghilterra", "Spagna", "Francia", "Germania"]
const DIVISIONS := {"Italia":["Serie C","Serie B","Serie A"],"Inghilterra":["League Two","League One","Championship","Premier League"],"Spagna":["Liga 2","Liga 1"],"Francia":["Ligue 3","Ligue 2","Ligue 1"],"Germania":["Bundesliga 2","Bundesliga 1"]}

var club_name := ""
var country := "Italia"
var division := "Serie C"
var season := 2026
var day := 0
var cash := 2500000
var wage_budget := 65000
var players: Array = []
var league: Array = []
var fixtures: Array = []
var market: Array = []
var cup_round := 0
var cup_teams: Array = []
var cup_winner := ""
var european_status := "Non qualificato"
var tactics := {"mentalita":"Equilibrata","pressing":"Medio","costruzione":"Mista","linea":"Media","sostituzioni":"Equilibrate"}
var formation := "4-3-3"
var lineup_ids: Array = []
var training_focus := "Equilibrio"
var youth_players: Array = []
var staff := {"coach":0,"scout":0,"physio":0,"academy":0}
var season_history: Array = []
var last_season_message := ""
var real_roster_db: Dictionary = {}
var setup_real_club: OptionButton
var pyramid_state: Dictionary = {}
var sponsor_contract: Dictionary = {}
var facilities := {"training":1,"stadium":1,"medical":1,"academy":1}
var board_objective: Dictionary = {}
var board_confidence := 75
var match_report: Dictionary = {}
var european_competitions: Dictionary = {}
var qualified_european_comp := ""
var selected_sub_out := -1
var selected_sub_in := -1
var selected_tab := "Home"
var root: HBoxContainer
var content: VBoxContainer
var navigation: VBoxContainer
var selected_club_name := ""
var setup_manager_name: LineEdit
var setup_difficulty: OptionButton
var setup_budget: OptionButton
var career_difficulty := "Normale"
var manager_name := "Manager"
var starting_budget_mode := "Standard"
var status_label: Label
var setup_name: LineEdit
var setup_country: OptionButton
var setup_division: OptionButton
var market_fee: SpinBox
var market_wage: SpinBox
var market_years: SpinBox
var market_role: OptionButton
var selected_market_player := -1
var market_filter := "Tutti"
var ui_built := false

func _ready() -> void:
	randomize()
	_load_real_roster_database()
	_build_shell()
	if FileAccess.file_exists(SAVE_PATH):
		_clear_content()
		_label("FOOTBALL CAREER: DYNASTY", 28)
		_label("La tua prossima storia comincia qui.", 18)
		_button("CONTINUA LA CARRIERA", _load_game)
		_button("NUOVA CARRIERA", _show_setup)
	else:
		_show_setup()

func _make_dynasty_theme() -> Theme:
	var game_theme := Theme.new()
	game_theme.default_font_size = 16
	game_theme.set_color("font_color", "Label", Color("#e8f0fb"))
	game_theme.set_color("font_color", "Button", Color("#eaf4ff"))
	game_theme.set_color("font_hover_color", "Button", Color("#ffffff"))
	game_theme.set_color("font_pressed_color", "Button", Color("#ffffff"))
	game_theme.set_color("font_disabled_color", "Button", Color("#718096"))
	game_theme.set_font_size("font_size", "Button", 15)
	game_theme.set_font_size("font_size", "Label", 16)
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("#14243a")
	normal.border_color = Color("#294563")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(12)
	normal.content_margin_left = 12
	normal.content_margin_right = 12
	normal.content_margin_top = 9
	normal.content_margin_bottom = 9
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color("#203b59")
	hover.border_color = Color("#54c7e8")
	hover.set_border_width_all(2)
	hover.set_corner_radius_all(12)
	hover.content_margin_left = 12
	hover.content_margin_right = 12
	hover.content_margin_top = 9
	hover.content_margin_bottom = 9
	var pressed := StyleBoxFlat.new()
	pressed.bg_color = Color("#087f8c")
	pressed.border_color = Color("#70e1ed")
	pressed.set_border_width_all(1)
	pressed.set_corner_radius_all(12)
	pressed.content_margin_left = 12
	pressed.content_margin_right = 12
	pressed.content_margin_top = 9
	pressed.content_margin_bottom = 9
	for control_type in ["Button", "OptionButton"]:
		game_theme.set_stylebox("normal", control_type, normal)
		game_theme.set_stylebox("hover", control_type, hover)
		game_theme.set_stylebox("pressed", control_type, pressed)
		game_theme.set_stylebox("focus", control_type, hover)
	var field := StyleBoxFlat.new()
	field.bg_color = Color("#0d1b2c")
	field.border_color = Color("#35516d")
	field.set_border_width_all(1)
	field.set_corner_radius_all(10)
	field.content_margin_left = 12
	field.content_margin_right = 12
	field.content_margin_top = 8
	field.content_margin_bottom = 8
	game_theme.set_stylebox("normal", "LineEdit", field)
	game_theme.set_stylebox("focus", "LineEdit", hover)
	game_theme.set_color("font_color", "LineEdit", Color("#f3f7ff"))
	game_theme.set_color("font_placeholder_color", "LineEdit", Color("#8193aa"))
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color("#101f32")
	panel.border_color = Color("#243d59")
	panel.set_border_width_all(1)
	panel.set_corner_radius_all(16)
	panel.content_margin_left = 14
	panel.content_margin_right = 14
	panel.content_margin_top = 12
	panel.content_margin_bottom = 12
	game_theme.set_stylebox("panel", "PanelContainer", panel)
	return game_theme

func _build_shell() -> void:
	for child in get_children():
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = Color("#07101d")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	var accent := ColorRect.new()
	accent.color = Color("#d6a94b")
	accent.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	accent.custom_minimum_size = Vector2(0, 4)
	add_child(accent)
	root = HBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 0)
	root.theme = _make_dynasty_theme()
	add_child(root)
	var sidebar := PanelContainer.new()
	sidebar.custom_minimum_size = Vector2(196, 0)
	sidebar.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(sidebar)
	var side_box := VBoxContainer.new()
	side_box.add_theme_constant_override("separation", 12)
	sidebar.add_child(side_box)
	var brand := Label.new()
	brand.text = "DYNASTY"
	brand.add_theme_font_size_override("font_size", 26)
	brand.add_theme_color_override("font_color", Color("#e5bd69"))
	brand.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_box.add_child(brand)
	var edition := Label.new()
	edition.text = "FOOTBALL CAREER"
	edition.add_theme_font_size_override("font_size", 10)
	edition.add_theme_color_override("font_color", Color("#8295aa"))
	edition.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_box.add_child(edition)
	var separator := HSeparator.new()
	side_box.add_child(separator)
	navigation = VBoxContainer.new()
	navigation.add_theme_constant_override("separation", 5)
	side_box.add_child(navigation)
	for tab in ["Home","Rosa","Formazione","Calendario","Classifica","Mercato","Coppe","UEFA","Club","Giovanili","Staff","Statistiche","Società"]:
		var button := Button.new()
		button.text = tab
		button.custom_minimum_size = Vector2(0, 39)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func(): _show_tab(tab))
		navigation.add_child(button)
	var side_spacer := Control.new()
	side_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	side_box.add_child(side_spacer)
	var version := Label.new()
	version.text = "SEASON 2026 / 27"
	version.add_theme_font_size_override("font_size", 10)
	version.add_theme_color_override("font_color", Color("#71869d"))
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	side_box.add_child(version)
	var main := VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 0)
	root.add_child(main)
	var topbar := PanelContainer.new()
	topbar.custom_minimum_size = Vector2(0, 66)
	main.add_child(topbar)
	var top_row := HBoxContainer.new()
	top_row.add_theme_constant_override("separation", 12)
	topbar.add_child(top_row)
	status_label = Label.new()
	status_label.text = "CENTRO DIREZIONALE  /  LA TUA CARRIERA"
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.add_theme_color_override("font_color", Color("#dce7f3"))
	status_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_row.add_child(status_label)
	var season_mark := Label.new()
	season_mark.text = "DYNASTY  •  26/27"
	season_mark.add_theme_font_size_override("font_size", 11)
	season_mark.add_theme_color_override("font_color", Color("#d6b66f"))
	season_mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_row.add_child(season_mark)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	main.add_child(scroll)
	var page_panel := PanelContainer.new()
	page_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.add_child(page_panel)
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	page_panel.add_child(margin)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 13)
	margin.add_child(content)
	ui_built = true
	navigation.visible = false

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()

func _label(text_value: String, size := 16) -> Label:
	var l := Label.new()
	l.text = text_value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	if size >= 22:
		l.add_theme_color_override("font_color", Color("#79e1ed"))
	elif size >= 18:
		l.add_theme_color_override("font_color", Color("#f4f8ff"))
	else:
		l.add_theme_color_override("font_color", Color("#c5d4e5"))
	content.add_child(l)
	return l

func _button(text_value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size = Vector2(0, 50)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(callback)
	content.add_child(b)
	return b

func _add_button(text_value: String, callback: Callable) -> void:
	_button(text_value, callback)

func _show_setup() -> void:
	_show_team_selection()

func _show_team_selection() -> void:
	navigation.visible = false
	_clear_content()
	_label("01  /  SCEGLI IL TUO CLUB", 26)
	_label("Il primo passo della tua carriera. Seleziona il paese, il campionato e la squadra che guiderai.", 16)
	var selectors := HBoxContainer.new()
	selectors.add_theme_constant_override("separation", 12)
	content.add_child(selectors)
	var country_box := VBoxContainer.new()
	country_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selectors.add_child(country_box)
	var country_label := Label.new()
	country_label.text = "PAESE"
	country_label.add_theme_color_override("font_color", Color("#d6b66f"))
	country_box.add_child(country_label)
	setup_country = OptionButton.new()
	setup_country.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for c in COUNTRIES:
		setup_country.add_item(c)
	country_box.add_child(setup_country)
	var division_box := VBoxContainer.new()
	division_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selectors.add_child(division_box)
	var division_label := Label.new()
	division_label.text = "CAMPIONATO"
	division_label.add_theme_color_override("font_color", Color("#d6b66f"))
	division_box.add_child(division_label)
	setup_division = OptionButton.new()
	setup_division.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	division_box.add_child(setup_division)
	setup_country.item_selected.connect(_country_changed)
	setup_division.item_selected.connect(func(_index): _update_setup_real_clubs())
	_country_changed(0)
	_label("SELEZIONA LA SQUADRA", 18)
	var club_panel := PanelContainer.new()
	club_panel.custom_minimum_size = Vector2(0, 106)
	content.add_child(club_panel)
	var club_box := VBoxContainer.new()
	club_panel.add_child(club_box)
	var club_hint := Label.new()
	club_hint.text = "CLUB DISPONIBILI"
	club_hint.add_theme_font_size_override("font_size", 11)
	club_hint.add_theme_color_override("font_color", Color("#8da2b9"))
	club_box.add_child(club_hint)
	setup_real_club = OptionButton.new()
	setup_real_club.custom_minimum_size = Vector2(0, 48)
	setup_real_club.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	club_box.add_child(setup_real_club)
	_label("Oppure personalizza il nome del club selezionando “Club personalizzato”.", 13)
	setup_name = LineEdit.new()
	setup_name.placeholder_text = "Nome del tuo club"
	setup_name.text = "AC Nova Milano"
	content.add_child(setup_name)
	var note := Label.new()
	note.text = "Le rose reali vengono caricate quando disponibili; negli altri casi il gioco crea una rosa generata."
	note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note.add_theme_font_size_override("font_size", 12)
	note.add_theme_color_override("font_color", Color("#8295aa"))
	content.add_child(note)
	_button("CONTINUA  →  IMPOSTAZIONI CARRIERA", _continue_to_career_settings)

func _continue_to_career_settings() -> void:
	if not is_instance_valid(setup_real_club) or setup_real_club.selected < 0:
		return
	country = COUNTRIES[setup_country.selected]
	division = setup_division.get_item_text(setup_division.selected)
	if setup_real_club.selected == 0:
		selected_club_name = setup_name.text.strip_edges()
		if selected_club_name.is_empty():
			selected_club_name = "Dynasty FC"
	else:
		selected_club_name = setup_real_club.get_item_text(setup_real_club.selected)
	_show_career_settings()

func _show_career_settings() -> void:
	_clear_content()
	_label("02  /  IMPOSTA LA CARRIERA", 26)
	_label(selected_club_name.to_upper() + "   •   " + division + "   •   " + country, 18)
	_label("Ora definisci il profilo della tua esperienza. Queste opzioni saranno applicate alla nuova carriera.", 15)
	_label("NOME ALLENATORE")
	setup_manager_name = LineEdit.new()
	setup_manager_name.text = "Manager"
	setup_manager_name.placeholder_text = "Il tuo nome"
	content.add_child(setup_manager_name)
	_label("DIFFICOLTÀ")
	setup_difficulty = OptionButton.new()
	for option in ["Facile","Normale","Difficile","Legend"]:
		setup_difficulty.add_item(option)
	setup_difficulty.select(1)
	content.add_child(setup_difficulty)
	_label("SITUAZIONE FINANZIARIA")
	setup_budget = OptionButton.new()
	for option in ["Ricca","Standard","Limitata"]:
		setup_budget.add_item(option)
	setup_budget.select(1)
	content.add_child(setup_budget)
	_label("RIEPILOGO", 18)
	_label("Club: " + selected_club_name + "\nCampionato: " + division + "\nStagione iniziale: 2026/27\nModalità: Carriera manageriale completa", 15)
	var actions := HBoxContainer.new()
	actions.add_theme_constant_override("separation", 12)
	content.add_child(actions)
	var back := Button.new()
	back.text = "← CAMBIA CLUB"
	back.custom_minimum_size = Vector2(0, 54)
	back.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	back.pressed.connect(_show_team_selection)
	actions.add_child(back)
	var start := Button.new()
	start.text = "INIZIA LA CARRIERA  →"
	start.custom_minimum_size = Vector2(0, 54)
	start.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	start.pressed.connect(_new_career)
	actions.add_child(start)

func _country_changed(index: int) -> void:
	if not is_instance_valid(setup_country) or not is_instance_valid(setup_division):
		return
	country = COUNTRIES[index]
	setup_division.clear()
	for d in DIVISIONS[country]:
		setup_division.add_item(d)
	setup_division.select(DIVISIONS[country].size() - 1)
	_update_setup_real_clubs()

func _new_career() -> void:
	club_name = selected_club_name if selected_club_name != "" else "Dynasty FC"
	manager_name = setup_manager_name.text.strip_edges() if is_instance_valid(setup_manager_name) else "Manager"
	if manager_name == "":
		manager_name = "Manager"
	career_difficulty = setup_difficulty.get_item_text(setup_difficulty.selected) if is_instance_valid(setup_difficulty) else "Normale"
	starting_budget_mode = setup_budget.get_item_text(setup_budget.selected) if is_instance_valid(setup_budget) else "Standard"
	season = 2026
	last_season_message = ""
	pyramid_state.clear()
	match_report.clear()
	european_competitions.clear()
	qualified_european_comp = ""
	market_filter = "Tutti"
	tactics = {"mentalita":"Equilibrata","pressing":"Medio","costruzione":"Mista","linea":"Media","sostituzioni":"Equilibrate"}
	formation = "4-3-3"
	lineup_ids.clear()
	training_focus = "Equilibrio"
	day = 0
	match starting_budget_mode:
		"Ricca":
			cash = 6500000
			wage_budget = 135000
		"Limitata":
			cash = 850000
			wage_budget = 32000
		_:
			cash = 2500000
			wage_budget = 65000
	players.clear()
	staff = {"coach":0,"scout":0,"physio":0,"academy":0}
	for real_player in _players_for_real_club(club_name):
		players.append(real_player)
	for i in range(maxi(0, 22 - players.size())):
		var generated_player: Dictionary = _make_player(i)
		generated_player["generated"] = true
		if career_difficulty == "Difficile":
			generated_player["rating"] = maxi(45, int(generated_player.get("rating", 60)) - 3)
		elif career_difficulty == "Legend":
			generated_player["rating"] = maxi(42, int(generated_player.get("rating", 60)) - 6)
		players.append(generated_player)
	_ensure_lineup()
	_generate_league()
	_initialise_pyramid()
	_initialise_club_business()
	_build_european_competitions()
	_generate_market()
	youth_players.clear()
	season_history.clear()
	_generate_youth_intake()
	cup_round = 0
	cup_teams = [club_name] + CLUBS.slice(0, 7)
	cup_winner = ""
	european_status = "Non qualificato"
	_save_game()
	_show_tab("Home")

func _load_real_roster_database() -> void:
	real_roster_db.clear()
	if not FileAccess.file_exists("res://data/real_rosters.json"):
		return
	var file := FileAccess.open("res://data/real_rosters.json", FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		real_roster_db = parsed.get("competitions", {})

func _competition_code(c: String, d: String) -> String:
	var map := {"Inghilterra|Premier League":"ENG-PL","Inghilterra|Championship":"ENG-CH","Spagna|Liga 1":"ESP-LL","Spagna|Liga 2":"ESP-SD","Italia|Serie A":"ITA-SA","Italia|Serie B":"ITA-SB","Germania|Bundesliga 1":"DEU-BL","Germania|Bundesliga 2":"DEU-B2","Francia|Ligue 1":"FRA-L1","Francia|Ligue 2":"FRA-L2"}
	return str(map.get(c + "|" + d, ""))

func _serie_c_groups() -> Array:
	return [
		["Albinoleffe","Alcione Milano","Arzignano Valchiampo","Carpi","Cittadella","Desenzano","Dolomiti Bellunesi","Folgore Caratese","Giana Erminio","Juventus Next Gen","Lecco","Lumezzane","Novara","Ospitaletto Franciacorta","Pergolettese","Pro Vercelli","Renate","Trento","Treviso","Union Brescia"],
		["Atalanta U23","Campobasso","Forlì","Grosseto","Gubbio","Guidonia Montecelio","Latina","Livorno","Ostiamare","Perugia","Pescara","Pianese","Pineto","Ravenna","Reggiana","Sambenedettese","Spezia","Torres","Vado","Vis Pesaro"],
		["Altamura","Audace Cerignola","Bari","Barletta","Casarano","Casertana","Catania","Cavese","Cosenza","Crotone","Foggia","Giugliano","Inter U23","Monopoli","Picerno","Potenza","Salernitana","Savoia","Scafatese","Sorrento"]
	]

func _update_setup_real_clubs() -> void:
	if not is_instance_valid(setup_real_club) or not is_instance_valid(setup_division):
		return
	setup_real_club.clear()
	setup_real_club.add_item("Club personalizzato")
	var code := _competition_code(country, setup_division.get_item_text(setup_division.selected))
	var names: Array = []
	if country == "Italia" and setup_division.get_item_text(setup_division.selected) == "Serie C":
		for group in _serie_c_groups(): names.append_array(group)
	elif code != "" and real_roster_db.has(code):
		var clubs: Dictionary = real_roster_db[code].get("clubs", {})
		names = clubs.keys()
	else:
		var old_division := division
		division = setup_division.get_item_text(setup_division.selected)
		names = _league_team_names()
		division = old_division
	names.sort()
	for club in names:
		setup_real_club.add_item(str(club))

func _unique_player_id(extra: Array = []) -> int:
	var used_ids: Dictionary = {}
	for p in players: used_ids[int(p.get("id", -1))] = true
	for p in market: used_ids[int(p.get("id", -1))] = true
	for p in youth_players: used_ids[int(p.get("id", -1))] = true
	for p in extra: used_ids[int(p.get("id", -1))] = true
	var candidate: int = randi()
	while used_ids.has(candidate): candidate = randi()
	return candidate

func _players_for_real_club(club: String) -> Array:
	var result: Array = []
	var code := _competition_code(country, division)
	if code == "" or not real_roster_db.has(code):
		return result
	var clubs: Dictionary = real_roster_db[code].get("clubs", {})
	var chosen := club if clubs.has(club) else ""
	if chosen == "":
		var normal := club.to_lower().replace(" ", "").replace(".", "").replace("-", "")
		for candidate in clubs.keys():
			var other := str(candidate).to_lower().replace(" ", "").replace(".", "").replace("-", "")
			if normal == other or (normal.length() >= 4 and other.contains(normal)) or (other.length() >= 4 and normal.contains(other)):
				chosen = str(candidate)
				break
	if chosen == "": return result
	var rows: Array = clubs[chosen].get("players", [])
	var base_rating := 67
	if division in ["Premier League","Liga 1","Serie A","Ligue 1","Bundesliga 1"]: base_rating = 73
	for i in range(mini(rows.size(), 30)):
		var row: Dictionary = rows[i]
		var raw_pos := str(row.get("position", ""))
		var pos := "CC"
		if raw_pos == "GK": pos = "POR"
		elif raw_pos == "DF": pos = ["DC","TD","TS"][i % 3]
		elif raw_pos == "FW": pos = ["ATT","AS","AD"][i % 3]
		elif raw_pos == "MF": pos = ["CC","CDC","COC"][i % 3]
		var rating := clampi(base_rating + randi_range(-10, 10), 48, 91)
		var identity := str(row.get("qid", ""))
		if identity == "": identity = str(row.get("name", ""))
		var player_id := _unique_player_id(result)
		var portrait_seed := absi(hash(identity + "|" + chosen))
		var player_age := randi_range(18,34)
		var raw_age = row.get("age", null)
		if raw_age != null and str(raw_age).is_valid_int(): player_age = int(str(raw_age))
		if player_age < 16 or player_age > 45: player_age = randi_range(18,34)
		var shirt_number := 0
		var raw_number = row.get("number", null)
		if raw_number != null and str(raw_number).is_valid_int(): shirt_number = int(str(raw_number))
		result.append({"id":player_id,"portrait_seed":portrait_seed,"name":str(row.get("name","Player")),"position":pos,"age":player_age,"rating":rating,"potential":mini(94,rating+randi_range(2,16)),"wage":rating*65,"value":rating*rating*1350,"morale":randi_range(65,88),"fitness":100,"injury":0,"contract":randi_range(1,4),"role":ROLES[i % ROLES.size()],"goals":0,"assists":0,"apps":0,"yellow":0,"red":0,"nationality":str(row.get("nationality","")),"shirt_number":shirt_number,"real_player":true,"source":"OpenFootballBase"})
	return result

func _make_player(index: int) -> Dictionary:
	var pos: String = POSITIONS[index % POSITIONS.size()]
	var rating := randi_range(54, 76)
	var age := randi_range(17, 34)
	var player_id := _unique_player_id()
	return {"id":player_id,"portrait_seed":randi(),"name":FIRST.pick_random()+" "+LAST.pick_random(),"position":pos,"age":age,"rating":rating,"potential":mini(92,rating+randi_range(2,20)),"wage":randi_range(900,4200),"value":rating*rating*1200,"morale":randi_range(65,90),"fitness":randi_range(82,100),"injury":0,"contract":randi_range(1,4),"role":ROLES.pick_random(),"goals":0,"assists":0,"apps":0,"yellow":0,"red":0}

func _league_team_names() -> Array:
	var pyramid_key := country + "|" + division
	if pyramid_state.has(pyramid_key):
		return pyramid_state[pyramid_key].duplicate()
	var real_code := _competition_code(country, division)
	if country == "Italia" and division == "Serie C":
		for group in _serie_c_groups():
			if group.has(club_name): return group.duplicate()
		return _serie_c_groups()[randi_range(0, 2)].duplicate()
	if real_code != "" and real_roster_db.has(real_code):
		var real_clubs: Dictionary = real_roster_db[real_code].get("clubs", {})
		if real_clubs.size() > 0:
			var imported_names: Array = real_clubs.keys()
			imported_names.sort()
			return imported_names
	if country == "Inghilterra" and division == "League One":
		return ["AFC Wimbledon","Barnsley","Blackpool","Bradford City","Bromley","Burton Albion","Cambridge United","Doncaster Rovers","Huddersfield Town","Leicester City","Leyton Orient","Luton Town","Mansfield Town","Milton Keynes Dons","Notts County","Oxford United","Peterborough United","Plymouth Argyle","Reading","Sheffield Wednesday","Stevenage","Stockport County","Wigan Athletic","Wycombe Wanderers"]
	if country == "Inghilterra" and division == "League Two":
		return ["Accrington Stanley","Barnet","Bristol Rovers","Cheltenham Town","Chesterfield","Colchester United","Crawley Town","Crewe Alexandra","Exeter City","Fleetwood Town","Gillingham","Grimsby Town","Newport County","Northampton Town","Oldham Athletic","Port Vale","Rochdale","Rotherham United","Salford City","Shrewsbury Town","Swindon Town","Tranmere Rovers","Walsall","York City"]
	var key := country + "|" + division
	var db := {
		"Italia|Serie A":["Atalanta","Bologna","Cagliari","Como","Fiorentina","Frosinone","Genoa","Inter","Juventus","Lazio","Lecce","Milan","Monza","Napoli","Parma","Roma","Sassuolo","Torino","Udinese","Venezia"],
		"Italia|Serie B":["Arezzo","Ascoli","Avellino","Benevento","Carrarese","Catanzaro","Cesena","Cremonese","Empoli","Hellas Verona","Juve Stabia","Mantova","Modena","Padova","Palermo","Pisa","Sampdoria","Südtirol","Vicenza","Virtus Entella"],
		"Inghilterra|Premier League":["AFC Bournemouth","Arsenal","Aston Villa","Brentford","Brighton & Hove Albion","Chelsea","Coventry City","Crystal Palace","Everton","Fulham","Hull City","Ipswich Town","Leeds United","Liverpool","Manchester City","Manchester United","Newcastle United","Nottingham Forest","Sunderland","Tottenham Hotspur"],
		"Inghilterra|Championship":["Birmingham City","Blackburn Rovers","Bristol City","Bolton Wanderers","Burnley","Cardiff City","Charlton Athletic","Derby County","Lincoln City","Middlesbrough","Millwall","Norwich City","Portsmouth","Preston North End","Queens Park Rangers","Sheffield United","Southampton","Stoke City","Swansea City","Watford","West Bromwich Albion","West Ham United","Wrexham","Wolverhampton Wanderers"],
		"Inghilterra|League One":["AFC Wimbledon","Barnsley","Blackpool","Bradford City","Bromley","Burton Albion","Cambridge United","Doncaster Rovers","Huddersfield Town","Leicester City","Leyton Orient","Luton Town","Mansfield Town","Milton Keynes Dons","Notts County","Oxford United","Peterborough United","Plymouth Argyle","Reading","Sheffield Wednesday","Stevenage","Stockport County","Wigan Athletic","Wycombe Wanderers"],
		"Inghilterra|League Two":["Accrington Stanley","Barnet","Bristol Rovers","Cheltenham Town","Chesterfield","Colchester United","Crawley Town","Crewe Alexandra","Exeter City","Fleetwood Town","Gillingham","Grimsby Town","Newport County","Northampton Town","Oldham Athletic","Port Vale","Rochdale","Rotherham United","Salford City","Shrewsbury Town","Swindon Town","Tranmere Rovers","Walsall","York City"],
		"Spagna|Liga 1":["Athletic Club","Atlético de Madrid","CA Osasuna","Celta Vigo","Deportivo Alavés","Elche CF","FC Barcelona","Getafe CF","Levante UD","Málaga CF","Racing Santander","Rayo Vallecano","RC Deportivo","RCD Espanyol","Real Betis","Real Madrid","Real Sociedad","Sevilla FC","Valencia CF","Villarreal CF"],
		"Francia|Ligue 1":["Angers SCO","AJ Auxerre","Stade Brestois 29","Le Havre AC","Le Mans FC","RC Lens","FC Lorient","LOSC Lille","Olympique Lyonnais","Olympique de Marseille","AS Monaco","OGC Nice","Paris FC","Paris Saint-Germain","Stade Rennais","RC Strasbourg","Toulouse FC","ESTAC Troyes"],
		"Francia|Ligue 2":["FC Annecy","US Boulogne","Clermont Foot","Dijon FCO","USL Dunkerque","Grenoble Foot 38","EA Guingamp","Stade Lavallois","FC Metz","Montpellier HSC","AS Nancy-Lorraine","FC Nantes","Pau FC","Red Star FC","Stade de Reims","Rodez AF","AS Saint-Étienne","FC Sochaux-Montbéliard"],
		"Germania|Bundesliga 1":["FC Bayern München","Borussia Dortmund","RB Leipzig","Bayer 04 Leverkusen","VfB Stuttgart","Eintracht Frankfurt","SC Freiburg","TSG Hoffenheim","1. FSV Mainz 05","VfL Wolfsburg","Borussia Mönchengladbach","Werder Bremen","FC Augsburg","1. FC Union Berlin","1. FC Köln","Hamburger SV","FC St. Pauli","1. FC Heidenheim"],
		"Germania|Bundesliga 2":["VfL Wolfsburg","1. FC Heidenheim","FC St. Pauli","Hannover 96","SV Darmstadt 98","1. FC Kaiserslautern","Hertha BSC","1. FC Nürnberg","VfL Bochum","Karlsruher SC","Dynamo Dresden","Holstein Kiel","Arminia Bielefeld","1. FC Magdeburg","Eintracht Braunschweig","Greuther Fürth","Energie Cottbus","VfL Osnabrück"]
	}
	if db.has(key):
		return db[key].duplicate()
	var known: Array = []
	match country:
		"Italia": known = ["Albinoleffe","Alcione Milano","Arzignano Valchiampo","Carpi","Cittadella","Desenzano","Dolomiti Bellunesi","Folgore Caratese","Giana Erminio","Juventus Next Gen","Lecco","Lumezzane","Novara","Ospitaletto Franciacorta","Pergolettese","Pro Vercelli","Renate","Trento","Treviso","Union Brescia"]
		"Inghilterra": known = ["Birmingham City","Blackburn Rovers","Blackpool","Bolton Wanderers","Bradford City","Cardiff City","Charlton Athletic","Huddersfield Town","Leicester City","Middlesbrough","Millwall","Norwich City","Oxford United","Portsmouth","Preston North End","Queens Park Rangers","Reading","Sheffield United","Sheffield Wednesday","Stoke City","Swansea City","Watford","West Bromwich Albion","Wrexham"]
		"Spagna": known = ["Albacete","Almería","Burgos CF","Cádiz CF","CD Castellón","CD Leganés","CD Mirandés","Córdoba CF","Eibar","FC Andorra","Granada CF","Huesca","Las Palmas","Real Oviedo","Real Zaragoza","Sporting Gijón","Tenerife","Valladolid"]
		"Francia": known = ["FC Rouen 1899","Fleury 91","FC Versailles 78","US Orléans","Le Puy Foot 43","SM Caen","US Concarneau","Valenciennes FC","SC Aubagne Air-Bel","FC Villefranche-Beaujolais","Quevilly Rouen Métropole","Paris 13 Atletico","Bourg-en-Bresse 01","Amiens SC","SC Bastia","VFC La Roche-sur-Yon","US Thionville Lusitanos","AS Cannes"]
		"Germania": known = ["VfL Wolfsburg","1. FC Heidenheim","FC St. Pauli","Hannover 96","SV Darmstadt 98","1. FC Kaiserslautern","Hertha BSC","1. FC Nürnberg","VfL Bochum","Karlsruher SC","Dynamo Dresden","Holstein Kiel","Arminia Bielefeld","1. FC Magdeburg","Eintracht Braunschweig","Greuther Fürth","Energie Cottbus","VfL Osnabrück"]
	var target := 20
	if division in ["Championship","League One","League Two"]:
		target = 24
	elif division == "Liga 2":
		target = 22
	elif division in ["Ligue 2","Ligue 3","Bundesliga 2"]:
		target = 18
	elif division == "Serie C":
		target = 20
	while known.size() > target:
		known.pop_back()
	var generated_index := 1
	while known.size() < target:
		var generated: String = "FC " + str(LAST[(known.size() + generated_index) % LAST.size()]) + " " + str(generated_index)
		generated_index += 1
		if not known.has(generated):
			known.append(generated)
	return known

func _generate_league() -> void:
	league.clear()
	var names: Array = _league_team_names()
	if not names.has(club_name):
		if names.size() >= 18:
			names.pop_back()
		names.append(club_name)
	for team in names:
		league.append({"name":team,"pts":0,"p":0,"w":0,"d":0,"l":0,"gf":0,"ga":0})
	fixtures.clear()
	var rotation: Array = names.duplicate()
	if rotation.size() % 2 == 1:
		rotation.append("BYE")
	var first_leg: Array = []
	var rounds_per_leg := rotation.size() - 1
	for round_index in range(rounds_per_leg):
		var games: Array = []
		for j in range(int(rotation.size() / 2)):
			var home: String = rotation[j]
			var away: String = rotation[rotation.size() - 1 - j]
			if home != "BYE" and away != "BYE":
				games.append({"home":home,"away":away})
		first_leg.append(games)
		var last_team: String = rotation.pop_back()
		rotation.insert(1,last_team)
	for round_data in first_leg:
		fixtures.append(round_data)
	for round_data in first_leg:
		var return_games: Array = []
		for match_data in round_data:
			return_games.append({"home":match_data.away,"away":match_data.home})
		fixtures.append(return_games)

func _generate_market() -> void:
	market.clear()
	var real_pool: Array = []
	for comp_code in real_roster_db.keys():
		var comp: Dictionary = real_roster_db[comp_code]
		var clubs: Dictionary = comp.get("clubs", {})
		for club in clubs.keys():
			if str(club) == club_name: continue
			for row in clubs[club].get("players", []):
				real_pool.append({"row":row,"club":str(club),"division":str(comp.get("division", ""))})
	real_pool.shuffle()
	var target_size := 24 + int(staff.get("scout", 0)) * 3
	var real_count := mini(18, mini(target_size, real_pool.size()))
	for i in range(real_count):
		var entry: Dictionary = real_pool[i]
		var row: Dictionary = entry.get("row", {})
		var raw_pos := str(row.get("position", ""))
		var pos := "CC"
		if raw_pos == "GK": pos = "POR"
		elif raw_pos == "DF": pos = ["DC","TD","TS"][i % 3]
		elif raw_pos == "FW": pos = ["ATT","AS","AD"][i % 3]
		elif raw_pos == "MF": pos = ["CC","CDC","COC"][i % 3]
		var base_rating := 66
		if str(entry.get("division", "")) in ["Premier League","Liga 1","Serie A","Ligue 1","Bundesliga 1"]:
			base_rating = 73
		var rating := clampi(base_rating + randi_range(-12, 12), 45, 92)
		var identity := str(row.get("qid", row.get("name", "player")))
		var player_id := _unique_player_id(market)
		var portrait_seed := absi(hash(identity + "|" + str(entry.get("club", ""))))
		var player_age := randi_range(18,34)
		var raw_age = row.get("age", null)
		if raw_age != null and str(raw_age).is_valid_int(): player_age = int(str(raw_age))
		if player_age < 16 or player_age > 45: player_age = randi_range(18,34)
		var shirt_number := 0
		var raw_number = row.get("number", null)
		if raw_number != null and str(raw_number).is_valid_int(): shirt_number = int(str(raw_number))
		var player := {"id":player_id,"portrait_seed":portrait_seed,"name":str(row.get("name","Player")),"position":pos,"age":player_age,"rating":rating,"potential":mini(95,rating+randi_range(2,17)),"wage":rating*70,"value":rating*rating*1450,"morale":randi_range(60,88),"fitness":100,"injury":0,"contract":randi_range(1,4),"role":"Importante","goals":0,"assists":0,"apps":0,"yellow":0,"red":0,"nationality":str(row.get("nationality","")),"shirt_number":shirt_number,"real_player":true,"source":"OpenFootballBase","club":str(entry.get("club",""))}
		if int(staff.get("scout", 0)) > 0:
			player["rating"] = mini(92, int(player["rating"]) + randi_range(0, int(staff.get("scout", 0))))
			player["potential"] = mini(96, int(player["potential"]) + int(staff.get("scout", 0)))
		market.append(player)
	for i in range(target_size - market.size()):
		var generated: Dictionary = _make_player(i)
		generated["generated"] = true
		generated["value"] = int(generated["rating"] * generated["rating"] * 1450)
		generated["wage"] = randi_range(700,5000)
		generated["club"] = CLUBS.pick_random()
		market.append(generated)

func _show_tab(tab: String) -> void:
	selected_tab = tab
	if not ui_built:
		return
	navigation.visible = true
	status_label.text = "CENTRO DIREZIONALE  /  " + tab.to_upper()
	match tab:
		"Home": _show_home()
		"Rosa": _show_squad()
		"Formazione": _show_formation()
		"Mercato": _show_market()
		"Classifica": _show_table()
		"Calendario": _show_table()
		"Coppe": _show_cups()
		"Club": _show_club()
		"Giovanili": _show_youth()
		"Staff": _show_staff()
		"Statistiche": _show_stats()
		"UEFA": _show_uefa()
		"Società": _show_society()

func _show_home() -> void:
	_clear_content()
	var hero := PanelContainer.new()
	hero.custom_minimum_size = Vector2(0, 132)
	content.add_child(hero)
	var hero_box := VBoxContainer.new()
	hero.add_child(hero_box)
	var brand := Label.new()
	brand.text = "DYNASTY  /  MATCHDAY"
	brand.add_theme_font_size_override("font_size", 13)
	brand.add_theme_color_override("font_color", Color("#67dce9"))
	hero_box.add_child(brand)
	var club_title := Label.new()
	club_title.text = club_name.to_upper()
	club_title.add_theme_font_size_override("font_size", 27)
	club_title.add_theme_color_override("font_color", Color("#f4f8ff"))
	club_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hero_box.add_child(club_title)
	var subtitle := Label.new()
	subtitle.text = division + "  •  STAGIONE " + str(season) + "/" + str(season + 1) + "  •  GIORNATA " + str(mini(day + 1, fixtures.size()))
	subtitle.add_theme_color_override("font_color", Color("#9db5ce"))
	hero_box.add_child(subtitle)
	if last_season_message != "":
		_label(last_season_message, 17)
	_label("IL TUO CLUB", 18)
	var stats := HBoxContainer.new()
	content.add_child(stats)
	for stat in ["€" + _money(cash) + "\nBILANCIO", str(players.size()) + "\nCALCIATORI", str(_team_rating()) + "\nOVR SQUADRA"]:
		var tile := PanelContainer.new()
		tile.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		stats.add_child(tile)
		var stat_label := Label.new()
		stat_label.text = stat
		stat_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stat_label.add_theme_font_size_override("font_size", 15)
		tile.add_child(stat_label)
	_label("PROSSIMO APPUNTAMENTO", 18)
	if day < fixtures.size():
		var fixture := _find_fixture(club_name)
		if not fixture.is_empty():
			var opponent := str(fixture.away if fixture.home == club_name else fixture.home)
			var home_side: bool = str(fixture.get("home", "")) == club_name
			var fixture_panel := PanelContainer.new()
			content.add_child(fixture_panel)
			var fixture_box := VBoxContainer.new()
			fixture_panel.add_child(fixture_box)
			var versus := Label.new()
			versus.text = ("CASA" if home_side else "TRASFERTA") + "   •   " + ("DERBY" if _is_derby(opponent) else "CAMPIONATO")
			versus.add_theme_color_override("font_color", Color("#ffd36a") if _is_derby(opponent) else Color("#67dce9"))
			fixture_box.add_child(versus)
			var match_title := Label.new()
			match_title.text = fixture.home + "\nVS\n" + fixture.away
			match_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			match_title.add_theme_font_size_override("font_size", 22)
			fixture_box.add_child(match_title)
			_button("ENTRA NEL GIORNO PARTITA  →", _show_matchday_presentation)
		else:
			_label("Turno di riposo: prepara la squadra e recupera energie.")
			_button("AVANZA AL PROSSIMO TURNO", _play_matchday)
	else:
		_label("Campionato terminato.")
		_button("AVANZA ALLA NUOVA STAGIONE",_new_season)
	_label("CLASSIFICA IN PRIMO PIANO", 18)
	var standings: Array = league.duplicate(true)
	standings.sort_custom(func(a, b): return int(a.get("pts", 0)) > int(b.get("pts", 0)) or (int(a.get("pts", 0)) == int(b.get("pts", 0)) and int(a.get("gf", 0)) - int(a.get("ga", 0)) > int(b.get("gf", 0)) - int(b.get("ga", 0))))
	for i in range(mini(5, standings.size())):
		var row: Dictionary = standings[i]
		_label(str(i + 1) + "   " + str(row.get("name", "")) + "     " + str(row.get("pts", 0)) + " pt")
	_label("NOTIZIE DAL CLUB", 18)
	for news in _club_news():
		_label("•  " + news)
	if not match_report.is_empty():
		_button("RIVEDI ULTIMA PARTITA", _show_match_report)
	_button("Salva carriera",_save_game)
	_button("Impostazioni tattiche",_show_tactics)

func _is_derby(opponent: String) -> bool:
	var pair := [club_name.to_lower(), opponent.to_lower()]
	var rivalries := [["milan","inter"],["torino","juventus"],["roma","lazio"],["real madrid","atletico"],["barcelona","espanyol"],["arsenal","tottenham"],["liverpool","everton"],["manchester city","manchester united"],["bayern","1860 münchen"],["hamburg","st. pauli"],["ac nova milano","torino athletic"]]
	for rivalry in rivalries:
		if pair.has(rivalry[0]) and pair.has(rivalry[1]):
			return true
	return false

func _club_news() -> Array:
	var news: Array = []
	news.append("La dirigenza conferma la fiducia: " + str(board_confidence) + "/100.")
	news.append("Il gruppo si allena con focus " + training_focus.to_lower() + ".")
	var top_scorer: Dictionary = {}
	for p in players:
		if top_scorer.is_empty() or int(p.get("goals", 0)) > int(top_scorer.get("goals", 0)):
			top_scorer = p
	if not top_scorer.is_empty() and int(top_scorer.get("goals", 0)) > 0:
		news.append(str(top_scorer.get("name", "")) + " guida i marcatori con " + str(top_scorer.get("goals", 0)) + " gol.")
	news.append("Sponsor attivo: " + str(sponsor_contract.get("name", "Nessuno")) + ".")
	return news

func _show_matchday_presentation() -> void:
	_clear_content()
	var fixture := _find_fixture(club_name)
	if fixture.is_empty():
		_play_matchday()
		return
	var opponent := str(fixture.away if fixture.home == club_name else fixture.home)
	_label("MATCHDAY  •  GIORNATA " + str(day + 1), 16)
	_label("IL GRANDE APPUNTAMENTO", 25)
	_label(fixture.home.to_upper() + "\nVS\n" + fixture.away.to_upper(), 27)
	_label(("🔥  DERBY: LA CITTÀ SI FERMA" if _is_derby(opponent) else "90 MINUTI PER SCRIVERE LA STORIA"), 18)
	_label("Forma squadra: " + str(_team_rating()) + " OVR  •  Modulo: " + formation)
	_label("Mentalità: " + str(tactics.get("mentalita", "Equilibrata")) + "  •  Pressing: " + str(tactics.get("pressing", "Medio")))
	_button("CONFERMA FORMAZIONE E SCENDI IN CAMPO", _play_matchday)
	_button("Rivedi formazione", _show_formation)
	_button("Torna alla dashboard", _show_home)

func _find_fixture(team: String) -> Dictionary:
	if day >= fixtures.size():
		return {}
	for match_data in fixtures[day]:
		if match_data.home == team or match_data.away == team:
			return match_data
	return {}

func _play_matchday() -> void:
	if day >= fixtures.size():
		return
	var club_played := false
	for match_data in fixtures[day]:
		var home: String = match_data.home
		var away: String = match_data.away
		var home_power := _club_power(home)+3
		var away_power := _club_power(away)
		if home == club_name:
			home_power = _club_power(club_name) + 3
		if away == club_name:
			away_power = _club_power(club_name)
		var hg := _goals_for_power(home_power,away_power)
		var ag := _goals_for_power(away_power,home_power)
		_update_result(home,away,hg,ag)
		if home == club_name or away == club_name:
			club_played = true
			var substitutions := _simulate_substitutions()
			match_report = _create_match_report(home, away, hg, ag, substitutions)
			var user_goals := hg if home == club_name else ag
			var user_conceded := ag if home == club_name else hg
			_apply_player_match(user_goals, user_conceded, substitutions)
			_update_board_after_match(user_goals, user_conceded)
			cash += 80000 + hg * 7000 + int(facilities.get("stadium", 1)) * 6000
			cash += int(sponsor_contract.get("weekly", 0))
			cash -= _weekly_wages()
			if hg > ag:
				cash += 45000
	if not club_played:
		cash += int(sponsor_contract.get("weekly", 0))
		cash -= _weekly_wages()
		for p in players:
			p.fitness = mini(100,int(p.fitness)+5)
	for p in players:
		if int(p.get("injury", 0)) > 0:
			p["injury"] = maxi(0, int(p.get("injury", 0)) - 1)
		if int(p.get("suspension", 0)) > 0:
			p["suspension"] = maxi(0, int(p.get("suspension", 0)) - 1)
	day += 1
	_save_game()
	if club_played and not match_report.is_empty():
		_show_match_report()
	else:
		_show_home()

func _goals_for_power(attack: int, defense: int) -> int:
	var chance := clampf(1.25+float(attack-defense)/24.0,0.2,3.4)
	var goals := 0
	for i in range(5):
		if randf() < chance/5.0:
			goals += 1
	return goals

func _update_result(home: String, away: String, hg: int, ag: int) -> void:
	var h := _team_record(home)
	var a := _team_record(away)
	h.p += 1
	a.p += 1
	h.gf += hg
	h.ga += ag
	a.gf += ag
	a.ga += hg
	if hg > ag:
		h.w += 1
		h.pts += 3
		a.l += 1
	elif hg < ag:
		a.w += 1
		a.pts += 3
		h.l += 1
	else:
		h.d += 1
		a.d += 1
		h.pts += 1
		a.pts += 1

func _team_record(team: String) -> Dictionary:
	for row in league:
		if row.name == team:
			return row
	return {}

func _club_power(team: String) -> int:
	if team == club_name:
		var power := _team_rating()
		match str(tactics.get("mentalita", "Equilibrata")):
			"Offensiva": power += 3
			"Difensiva": power -= 1
		match str(tactics.get("pressing", "Medio")):
			"Alto": power += 2
			"Basso": power -= 1
		match str(tactics.get("costruzione", "Mista")):
			"Corta": power += 1
			"Diretta": power += 1
		return clampi(power, 35, 99)
	return randi_range(58,78)

func _team_rating() -> int:
	if players.is_empty():
		return 0
	_ensure_lineup()
	var total := 0
	var count := 0
	for player_id in lineup_ids:
		for p in players:
			if int(p.get("id", -1)) == int(player_id):
				total += int(p.get("rating", 50))
				count += 1
				break
	if count == 0:
		for p in players:
			total += int(p.get("rating", 50))
			count += 1
	return mini(99, int(round(float(total) / max(1, count))) + int(staff.get("coach", 0)) * 2)

func _formation_positions() -> Array:
	match formation:
		"4-2-3-1":
			return ["POR","TD","DC","DC","TS","CDC","CDC","AD","COC","AS","ATT"]
		"4-4-2":
			return ["POR","TD","DC","DC","TS","AD","CC","CC","AS","ATT","ATT"]
		"3-5-2":
			return ["POR","DC","DC","DC","TD","CDC","CC","CC","TS","ATT","ATT"]
		_:
			return ["POR","TD","DC","DC","TS","CDC","CC","CC","AD","AS","ATT"]

func _ensure_lineup() -> void:
	var valid_ids: Array = []
	for p in players:
		valid_ids.append(int(p.get("id", -1)))
	var unique_valid := lineup_ids.size() == 11
	var seen: Array = []
	if unique_valid:
		for player_id in lineup_ids:
			var found := false
			for p in players:
				if int(p.get("id", -1)) == int(player_id):
					found = true
					if int(p.get("injury", 0)) > 0 or int(p.get("suspension", 0)) > 0:
						unique_valid = false
					break
			if not found or seen.has(int(player_id)):
				unique_valid = false
			seen.append(int(player_id))
	if unique_valid:
		return
	lineup_ids.clear()
	var ordered: Array = players.duplicate()
	ordered.sort_custom(func(a, b):
		var a_ok := int(a.get("injury", 0)) == 0 and int(a.get("suspension", 0)) == 0
		var b_ok := int(b.get("injury", 0)) == 0 and int(b.get("suspension", 0)) == 0
		if a_ok != b_ok:
			return a_ok
		return int(a.get("rating", 0)) > int(b.get("rating", 0))
	)
	for p in ordered:
		if lineup_ids.size() >= 11:
			break
		if int(p.get("injury", 0)) == 0 and int(p.get("suspension", 0)) == 0 and not lineup_ids.has(int(p.get("id", -1))):
			lineup_ids.append(int(p.get("id", -1)))
	if lineup_ids.size() < 11:
		for p in ordered:
			if lineup_ids.size() >= 11:
				break
			if not lineup_ids.has(int(p.get("id", -1))):
				lineup_ids.append(int(p.get("id", -1)))

func _show_formation() -> void:
	_clear_content()
	_ensure_lineup()
	_label("FORMAZIONE TITOLARE", 22)
	_label("Scegli il modulo e assegna un calciatore a ogni posizione. La media della squadra e la simulazione useranno gli undici titolari.")
	var modules := OptionButton.new()
	for module in ["4-3-3","4-2-3-1","4-4-2","3-5-2"]:
		modules.add_item(module)
	modules.select(["4-3-3","4-2-3-1","4-4-2","3-5-2"].find(formation))
	modules.item_selected.connect(func(i):
		formation = modules.get_item_text(i)
		_show_formation()
	)
	content.add_child(modules)
	var positions := _formation_positions()
	var pitch = preload("res://scripts/tactical_pitch.gd").new()
	pitch.set_lineup(players, lineup_ids, formation)
	pitch.slots_swapped.connect(Callable(self, "_swap_lineup_slots"))
	content.add_child(pitch)
	for i in range(positions.size()):
		var slot_index := i
		var row := HBoxContainer.new()
		content.add_child(row)
		var position_label := Label.new()
		position_label.text = str(i + 1) + ". " + str(positions[i])
		position_label.custom_minimum_size = Vector2(78, 42)
		row.add_child(position_label)
		var choice := OptionButton.new()
		choice.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		for p in players:
			choice.add_item(str(p.get("name", "Giocatore")) + " • " + str(p.get("rating", 0)) + " OVR")
		var selected_index := 0
		for j in range(players.size()):
			if j < lineup_ids.size() and int(players[j].get("id", -1)) == int(lineup_ids[i]):
				selected_index = j
				break
		if players.size() > 0:
			choice.select(selected_index)
		choice.item_selected.connect(func(option_index):
			_set_lineup_player(slot_index, option_index)
		)
		row.add_child(choice)
	_label("Trascina i giocatori sul campo per scambiare le loro posizioni.")
	_label("Media titolari: " + str(_team_rating()) + " OVR")
	_button("Salva formazione", func(): _save_game(); _show_home())

func _swap_lineup_slots(first_slot: int, second_slot: int) -> void:
	if first_slot < 0 or second_slot < 0 or first_slot >= lineup_ids.size() or second_slot >= lineup_ids.size(): return
	var temp := int(lineup_ids[first_slot])
	lineup_ids[first_slot] = int(lineup_ids[second_slot])
	lineup_ids[second_slot] = temp
	_save_game()
	_show_formation()

func _set_lineup_player(slot_index: int, player_index: int) -> void:
	if slot_index < 0 or slot_index >= 11 or player_index < 0 or player_index >= players.size():
		return
	while lineup_ids.size() < 11:
		lineup_ids.append(-1)
	var chosen_id := int(players[player_index].get("id", -1))
	var previous_slot := lineup_ids.find(chosen_id)
	var old_id := int(lineup_ids[slot_index])
	lineup_ids[slot_index] = chosen_id
	if previous_slot >= 0 and previous_slot != slot_index:
		lineup_ids[previous_slot] = old_id
	_save_game()
	_show_formation()

func _apply_player_match(goals: int, conceded: int, substitutions: Array = []) -> void:
	_ensure_lineup()
	var scorers: Array = []
	var played_ids: Array = lineup_ids.duplicate()
	for sub in substitutions:
		played_ids.erase(int(sub.get("out_id", -1)))
		played_ids.append(int(sub.get("in_id", -1)))
	var fit_players: Array = players.filter(func(p): return int(p.get("injury", 0)) == 0)
	for p in fit_players:
		var is_starter := lineup_ids.has(int(p.get("id", -1)))
		var did_play := played_ids.has(int(p.get("id", -1)))
		if did_play:
			p["apps"] = int(p.get("apps", 0)) + 1
			var match_rating := 6.2 + randf() * 1.5
			if goals > conceded: match_rating += 0.35
			elif goals < conceded: match_rating -= 0.35
			p["last_rating"] = snappedf(clampf(match_rating, 4.5, 9.8), 0.1)
		if is_starter:
			p["fitness"] = maxi(35, int(p.get("fitness", 100)) - randi_range(6, 12))
			if randf() < maxf(0.002, 0.014 - float(staff.get("physio", 0)) * 0.002 - float(facilities.get("medical", 1)) * 0.001):
				p["injury"] = randi_range(2, 5)
			if randf() < 0.025:
				p["yellow"] = int(p.get("yellow", 0)) + 1
				p["yellow_season"] = int(p.get("yellow_season", 0)) + 1
				if int(p["yellow_season"]) > 0 and int(p["yellow_season"]) % 5 == 0:
					p["suspension"] = maxi(int(p.get("suspension", 0)), 2)
			if randf() < 0.003:
				p["red"] = int(p.get("red", 0)) + 1
				p["suspension"] = maxi(int(p.get("suspension", 0)), 3)
			if ["ATT", "AD", "AS", "COC"].has(str(p.get("position", ""))):
				scorers.append(p)
		elif did_play:
			p["fitness"] = maxi(50, int(p.get("fitness", 100)) - randi_range(3, 6))
		else:
			p["fitness"] = mini(100, int(p.get("fitness", 100)) + 3)
	for goal_index in range(goals):
		if scorers.size() > 0:
			var scorer: Dictionary = scorers.pick_random()
			scorer["goals"] = int(scorer.get("goals", 0)) + 1
			if randf() < 0.72 and not fit_players.is_empty():
				var assister: Dictionary = fit_players.pick_random()
				if int(assister.get("id", -1)) != int(scorer.get("id", -2)) and lineup_ids.has(int(assister.get("id", -1))):
					assister["assists"] = int(assister.get("assists", 0)) + 1
	for p in players:
		if goals > conceded:
			p["morale"] = mini(100, int(p.get("morale", 70)) + 3)
		elif goals < conceded:
			p["morale"] = maxi(20, int(p.get("morale", 70)) - 3)

func _show_squad() -> void:
	_clear_content()
	_label("ROSA • GESTIONE CARTE",22)
	_label("Trascina una carta sopra un'altra per scambiare i due giocatori nell'ordine della rosa. Le carte mostrano overall, ruolo, età e forma.")
	_label("Media: "+str(_team_rating())+" • Ingaggi settimanali: €"+_money(_weekly_wages()))
	var real_count := players.filter(func(p): return bool(p.get("real_player", false))).size()
	_label("Dati rosa: " + str(real_count) + " giocatori reali importati • " + str(players.size() - real_count) + " generati")
	var grid := GridContainer.new()
	grid.columns = 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	content.add_child(grid)
	for p in players:
		var card = preload("res://scripts/player_card.gd").new()
		card.setup(p)
		card.swap_requested.connect(_swap_players)
		card.sell_requested.connect(_sell_player)
		card.renew_requested.connect(_renew_player_contract)
		card.detail_requested.connect(_show_player_detail)
		grid.add_child(card)

func _show_player_detail(player_id: int) -> void:
	var player: Dictionary = {}
	for candidate in players:
		if int(candidate.get("id", -1)) == player_id:
			player = candidate
			break
	if player.is_empty():
		return
	_clear_content()
	_label("PLAYER PROFILE  /  DYNASTY SCOUTING", 14)
	var hero := PanelContainer.new()
	content.add_child(hero)
	var hero_row := HBoxContainer.new()
	hero.add_child(hero_row)
	var portrait = preload("res://scripts/player_portrait.gd").new()
	portrait.custom_minimum_size = Vector2(126, 150)
	portrait.seed_value = int(player.get("portrait_seed", player_id))
	hero_row.add_child(portrait)
	var identity := VBoxContainer.new()
	identity.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hero_row.add_child(identity)
	var name_label := Label.new()
	name_label.text = str(player.get("name", "Giocatore"))
	name_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_label.add_theme_font_size_override("font_size", 20)
	identity.add_child(name_label)
	var overall := Label.new()
	overall.text = str(player.get("rating", 0)) + " OVR  •  " + str(player.get("position", ""))
	overall.add_theme_font_size_override("font_size", 23)
	overall.add_theme_color_override("font_color", Color("#67e6f4"))
	identity.add_child(overall)
	identity.add_child(_profile_line("Età", str(player.get("age", 0)) + " anni"))
	identity.add_child(_profile_line("Potenziale", str(player.get("potential", 0)) + " OVR"))
	identity.add_child(_profile_line("Nazionalità", str(player.get("nationality", "Non specificata"))))
	_label("ATTRIBUTI TECNICI E FISICI", 18)
	var rating := int(player.get("rating", 60))
	var potential := int(player.get("potential", rating))
	var position := str(player.get("position", "CC"))
	var attributes := {
		"Velocità": clampi(rating + (8 if position in ["AD","AS","TD","TS"] else 0) - 4, 25, 99),
		"Tiro": clampi(rating + (10 if position in ["ATT","AD","AS"] else -5), 25, 99),
		"Passaggio": clampi(rating + (8 if position in ["CC","COC","CDC"] else -3), 25, 99),
		"Dribbling": clampi(rating + (7 if position in ["AD","AS","COC"] else 0), 25, 99),
		"Difesa": clampi(rating + (12 if position in ["DC","TD","TS","CDC"] else -12), 20, 99),
		"Fisico": clampi(rating + (6 if position in ["DC","ATT"] else 0), 25, 99)
	}
	for attribute in attributes.keys():
		var row := HBoxContainer.new()
		content.add_child(row)
		var caption := Label.new()
		caption.text = attribute
		caption.custom_minimum_size = Vector2(92, 26)
		row.add_child(caption)
		var bar := ProgressBar.new()
		bar.min_value = 0
		bar.max_value = 100
		bar.value = int(attributes[attribute])
		bar.show_percentage = false
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(bar)
		var score := Label.new()
		score.text = str(attributes[attribute])
		score.custom_minimum_size = Vector2(28, 24)
		row.add_child(score)
	_label("PERCORSO DI CRESCITA", 18)
	var chart = preload("res://scripts/player_growth_chart.gd").new()
	chart.setup(rating, potential, int(player.get("age", 22)))
	content.add_child(chart)
	_label("STATISTICHE STAGIONALI", 18)
	_label("Presenze: " + str(player.get("apps", 0)) + "  •  Gol: " + str(player.get("goals", 0)) + "  •  Assist: " + str(player.get("assists", 0)))
	_label("Forma: " + str(player.get("fitness", 0)) + "%  •  Morale: " + str(player.get("morale", 0)) + "%  •  Ultima valutazione: " + str(player.get("last_rating", "—")))
	_label("Valore stimato: €" + _money(int(player.get("value", 0))) + "  •  Ingaggio: €" + _money(int(player.get("wage", 0))) + "/sett.")
	_button("RINNOVA CONTRATTO", func(): _renew_player_contract(player_id))
	_button("TORNA ALLA ROSA", _show_squad)

func _profile_line(caption: String, value: String) -> Label:
	var line := Label.new()
	line.text = caption + ": " + value
	line.add_theme_font_size_override("font_size", 13)
	line.add_theme_color_override("font_color", Color("#b8cce0"))
	return line

func _swap_players(source_id: int, target_id: int) -> void:
	var source_index := -1
	var target_index := -1
	for i in range(players.size()):
		if int(players[i].get("id", -1)) == source_id:
			source_index = i
		elif int(players[i].get("id", -1)) == target_id:
				target_index = i
	if source_index < 0 or target_index < 0:
		return
	var temp: Dictionary = players[source_index]
	players[source_index] = players[target_index]
	players[target_index] = temp
	_save_game()
	_show_squad()

func _sell_player(player_id: int) -> void:
	for i in range(players.size()):
		if int(players[i].id) == player_id:
			var p: Dictionary = players[i]
			cash += int(p.value*0.8)
			wage_budget += int(p.wage)
			players.remove_at(i)
			break
	_save_game()
	_show_squad()

func _show_market() -> void:
	_clear_content()
	_label("MERCATO TRASFERIMENTI",22)
	_label("Cassa: €"+_money(cash)+" • Budget ingaggi: €"+_money(wage_budget))
	var filter := OptionButton.new()
	for option in ["Tutti","Calciatori reali","Giovani U21","Occasioni sotto €2M","Top player OVR 75+"]:
		filter.add_item(option)
	filter.select(["Tutti","Calciatori reali","Giovani U21","Occasioni sotto €2M","Top player OVR 75+"].find(market_filter))
	filter.item_selected.connect(func(i):
		market_filter = filter.get_item_text(i)
		_show_market()
	)
	content.add_child(filter)
	var shown := 0
	for i in range(market.size()):
		var p: Dictionary = market[i]
		var age := int(p.get("age", 30))
		var value := int(p.get("value", 0))
		var rating := int(p.get("rating", 0))
		if market_filter == "Calciatori reali" and not bool(p.get("real_player", false)): continue
		if market_filter == "Giovani U21" and age > 21: continue
		if market_filter == "Occasioni sotto €2M" and value >= 2000000: continue
		if market_filter == "Top player OVR 75+" and rating < 75: continue
		var idx := i
		var label := str(p.get("name", "Giocatore")) + " | " + str(p.get("position", "")) + " | " + str(rating) + " OVR | " + str(age) + " anni | POT " + str(p.get("potential", rating)) + " | €" + _money(value)
		_button(label,func(): _negotiate(idx))
		shown += 1
	if shown == 0:
		_label("Nessun giocatore corrisponde al filtro. Cambia selezione.")

func _negotiate(index: int) -> void:
	if index < 0 or index >= market.size():
		return
	selected_market_player = index
	var p: Dictionary = market[index]
	_clear_content()
	_label("DYNASTY TRANSFER ROOM  /  NEGOZIAZIONE", 14)
	var player_panel := PanelContainer.new()
	content.add_child(player_panel)
	var player_row := HBoxContainer.new()
	player_panel.add_child(player_row)
	var portrait = preload("res://scripts/player_portrait.gd").new()
	portrait.custom_minimum_size = Vector2(112, 132)
	portrait.seed_value = int(p.get("portrait_seed", p.get("id", 1)))
	player_row.add_child(portrait)
	var bio := VBoxContainer.new()
	bio.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_row.add_child(bio)
	var player_name := Label.new()
	player_name.text = str(p.get("name", "Giocatore"))
	player_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	player_name.add_theme_font_size_override("font_size", 20)
	bio.add_child(player_name)
	var ovr := Label.new()
	ovr.text = str(p.position) + "  •  " + str(p.rating) + " OVR"
	ovr.add_theme_font_size_override("font_size", 22)
	ovr.add_theme_color_override("font_color", Color("#67e6f4"))
	bio.add_child(ovr)
	bio.add_child(_profile_line("Età / POT", str(p.age) + " anni / " + str(p.potential)))
	bio.add_child(_profile_line("Club", str(p.get("club", "Club proprietario"))))
	bio.add_child(_profile_line("Ingaggio", "€" + _money(int(p.wage)) + "/sett."))
	_label("FASE 1  •  ACCORDO TRA CLUB", 17)
	_label("Valore richiesto: €"+_money(p.value)+"  •  Definisci il cartellino da offrire.")
	_label("Offerta trasferimento (€)")
	market_fee = SpinBox.new()
	market_fee.min_value = 0
	market_fee.max_value = 50000000
	market_fee.step = 25000
	market_fee.value = p.value
	content.add_child(market_fee)
	_label("FASE 2  •  ACCORDO CON IL CALCIATORE", 17)
	_label("Ingaggio settimanale (€)")
	market_wage = SpinBox.new()
	market_wage.min_value = 500
	market_wage.max_value = 50000
	market_wage.step = 100
	market_wage.value = p.wage
	content.add_child(market_wage)
	_label("Durata contratto (anni)")
	market_years = SpinBox.new()
	market_years.min_value = 1
	market_years.max_value = 5
	market_years.value = 3
	content.add_child(market_years)
	_label("Ruolo promesso")
	market_role = OptionButton.new()
	for role in ROLES:
		market_role.add_item(role)
	market_role.select(1)
	content.add_child(market_role)
	_label("FASE 3  •  RUOLO E PROGETTO SPORTIVO", 17)
	_label("La probabilità di accettazione dipende da offerta, stipendio, ruolo e prestigio della squadra.")
	_button("INVIA OFFERTA UFFICIALE",_submit_offer)
	_button("CHIEDI PRESTITO (1 STAGIONE)",_submit_loan_offer)
	_button("Torna al mercato",_show_market)

func _submit_offer() -> void:
	if selected_market_player < 0 or selected_market_player >= market.size():
		return
	var p: Dictionary = market[selected_market_player]
	var fee := int(market_fee.value)
	var wage := int(market_wage.value)
	if players.size() >= 30:
		_label("Rosa completa: vendi o svincola un giocatore prima di acquistare.")
		return
	if fee > cash or wage > wage_budget:
		_label("Offerta rifiutata: fondi o budget ingaggi insufficienti.")
		return
	var value_ratio := float(fee) / maxf(1.0, float(p.get("value", 1)))
	var wage_ratio := float(wage) / maxf(1.0, float(p.get("wage", 1)))
	var role_bonus := 0.12 if ROLES[market_role.selected] in ["Cruciale","Importante"] else 0.04
	var prestige_bonus := clampf(float(_team_rating() - int(p.get("rating", 60))) / 100.0, -0.12, 0.12)
	var acceptance := clampf(0.18 + (value_ratio - 0.65) * 1.1 + (wage_ratio - 0.75) * 0.55 + role_bonus + prestige_bonus, 0.04, 0.97)
	if randf() > acceptance:
		var counter_fee := int(float(p.get("value", 0)) * 1.08)
		var counter_wage := int(float(p.get("wage", 0)) * 1.08)
		_label("Trattativa fallita. Il club chiede circa €" + _money(counter_fee) + " e il giocatore vuole €" + _money(counter_wage) + "/sett.")
		return
	p.contract = int(market_years.value)
	p.role = ROLES[market_role.selected]
	p.wage = wage
	p.value = maxi(int(p.value),fee)
	p.morale = 80
	p.fitness = 100
	p.injury = 0
	players.append(p.duplicate(true))
	cash -= fee
	wage_budget -= wage
	market.remove_at(selected_market_player)
	selected_market_player = -1
	_save_game()
	_show_market()
	_label("TRASFERIMENTO COMPLETATO: "+p.name+" è un nuovo giocatore!")

func _submit_loan_offer() -> void:
	if selected_market_player < 0 or selected_market_player >= market.size():
		return
	var source: Dictionary = market[selected_market_player]
	var loan_fee := int(source.get("value", 0) * 0.08)
	var loan_wage := int(source.get("wage", 0) * 0.5)
	if cash < loan_fee or wage_budget < loan_wage:
		_label("Prestito non possibile: fondi o budget ingaggi insufficienti.")
		return
	if randf() > 0.82:
		_label("Il club proprietario ha rifiutato il prestito.")
		return
	var loanee: Dictionary = source.duplicate(true)
	loanee["id"] = randi()
	loanee["loan"] = true
	loanee["parent_club"] = str(source.get("club", "Club proprietario"))
	loanee["loan_fee"] = loan_fee
	loanee["contract"] = 1
	loanee["wage"] = loan_wage
	loanee["fitness"] = 100
	loanee["morale"] = 78
	players.append(loanee)
	cash -= loan_fee
	wage_budget -= loan_wage
	market.remove_at(selected_market_player)
	selected_market_player = -1
	_ensure_lineup()
	_save_game()
	_show_market()
	_label("Prestito completato: " + str(loanee.get("name", "Giocatore")) + " arriva per una stagione.")

func _renew_player_contract(player_id: int) -> void:
	for p in players:
		if int(p.get("id", -1)) == player_id:
			var current_wage := int(p.get("wage", 0))
			var new_wage := int(ceil(float(current_wage) * 1.1))
			var increase := new_wage - current_wage
			if increase > wage_budget:
				status_label.text = "Budget ingaggi insufficiente per rinnovare."
				return
			p["contract"] = maxi(2, int(p.get("contract", 0)) + 2)
			p["wage"] = new_wage
			p["morale"] = mini(100, int(p.get("morale", 70)) + 8)
			wage_budget -= increase
			_save_game()
			_show_squad()
			return

func _show_table() -> void:
	_clear_content()
	_label("CLASSIFICA "+division.to_upper(),22)
	var sorted: Array = league.duplicate()
	sorted.sort_custom(func(a,b):
		if int(a.pts) == int(b.pts):
			return int(a.gf)-int(a.ga) > int(b.gf)-int(b.ga)
		return int(a.pts) > int(b.pts)
	)
	for i in range(sorted.size()):
		var r: Dictionary = sorted[i]
		var marker := " ★" if r.name == club_name else ""
		_label(str(i+1)+". "+r.name+marker+"  "+str(r.pts)+" pt | G "+str(r.p)+" V "+str(r.w)+" N "+str(r.d)+" P "+str(r.l)+" DR "+str(r.gf-r.ga))
	_button("Torna alla Home",func(): _show_tab("Home"))

func _show_cups() -> void:
	_clear_content()
	_label("COPPE NAZIONALI & UEFA",22)
	_label("Coppa nazionale: turno "+str(cup_round+1)+" / 3")
	if cup_winner != "":
		_label("Vincitore Coppa: "+cup_winner)
	elif cup_teams.has(club_name):
		_button("GIOCA TURNO DI COPPA",_play_cup_round)
	else:
		_label("La tua squadra è stata eliminata dalla coppa.")
	_label("Competizioni UEFA: "+european_status)
	_button("Apri Champions League / Europa League / Conference", func(): _show_tab("UEFA"))
	_button("Visualizza classifica",func(): _show_tab("Classifica"))

func _play_cup_round() -> void:
	if cup_winner != "" or not cup_teams.has(club_name):
		return
	var next: Array = []
	var user_won := false
	for i in range(0,cup_teams.size(),2):
		var a: String = cup_teams[i]
		var b: String = cup_teams[i+1] if i+1 < cup_teams.size() else "Bye"
		var winner: String
		if b == "Bye":
			winner = a
		elif a == club_name or b == club_name:
			user_won = randf() < clampf(0.5+float(_team_rating()-68)/100.0,0.25,0.8)
			winner = a if (a == club_name and user_won) or (b == club_name and not user_won) else b if a == club_name else a
		else:
			winner = a if randf() > 0.5 else b
		next.append(winner)
	cup_round += 1
	if next.size() == 1:
		cup_winner = str(next[0])
		if cup_winner == club_name:
			cash += 1500000
			qualified_european_comp = "UEFA Europa League"
			european_status = "Qualificato alla UEFA Europa League"
	else:
		cup_teams = next
		if user_won:
			cash += 150000
	_save_game()
	_show_cups()

func _show_club() -> void:
	_clear_content()
	_label("GESTIONE CLUB",22)
	_label(club_name+" • "+country+" • "+division)
	_label("Stagione "+str(season)+" • Turno "+str(day)+"/"+str(fixtures.size()))
	_label("Cassa: €"+_money(cash))
	_label("Budget ingaggi settimanale: €"+_money(wage_budget))
	_label("Stipendi rosa: €"+_money(_weekly_wages())+"/sett.")
	_label("Status UEFA: "+european_status)
	_label("ALLENAMENTO SETTIMANALE", 19)
	var focus := OptionButton.new()
	for item in ["Equilibrio","Tecnica","Fisico","Tattica","Recupero"]:
		focus.add_item(item)
	focus.select(["Equilibrio","Tecnica","Fisico","Tattica","Recupero"].find(training_focus))
	focus.item_selected.connect(func(i): training_focus = focus.get_item_text(i))
	content.add_child(focus)
	_button("Svolgi allenamento (€25.000)", _train_squad)
	_button("Apri formazione", _show_formation)
	_button("Gestione società, sponsor e strutture", func(): _show_tab("Società"))
	_button("Salva partita",_save_game)
	_button("Carica partita",_load_game)
	_button("Nuova stagione",_new_season)

func _train_squad() -> void:
	if cash < 25000:
		_label("Fondi insufficienti per l'allenamento.")
		return
	cash -= 25000
	for p in players:
		match training_focus:
			"Tecnica":
				if int(p.get("age", 30)) < 30:
					p.rating = mini(int(p.get("potential", 90)), int(p.get("rating", 50)) + 1 + int(staff.get("coach", 0)) + int(int(facilities.get("training", 1)) / 3))
			"Fisico":
				p.fitness = mini(100, int(p.get("fitness", 70)) + 12 + int(facilities.get("training", 1)))
			"Tattica":
				p.morale = mini(100, int(p.get("morale", 70)) + 5)
			"Recupero":
				p.fitness = mini(100, int(p.get("fitness", 70)) + 20)
				p.injury = maxi(0, int(p.get("injury", 0)) - 1)
			_:
				p.fitness = mini(100, int(p.get("fitness", 70)) + 6)
				p.morale = mini(100, int(p.get("morale", 70)) + 2)
	_save_game()
	_show_club()



func _initialise_pyramid() -> void:
	if not pyramid_state.is_empty():
		return
	var old_division := division
	for div in DIVISIONS.get(country, []):
		division = str(div)
		var names: Array = []
		if division == old_division and not league.is_empty():
			for row in league:
				names.append(str(row.get("name", "")))
		else:
			names = _league_team_names()
		if division == old_division and not names.has(club_name):
			if names.size() > 0: names.pop_back()
			names.append(club_name)
		pyramid_state[country + "|" + division] = names
	division = old_division

func _simulate_ai_table(teams: Array) -> Array:
	var table: Array = []
	for team in teams:
		var strength := 55 + absi(hash(str(team) + str(season))) % 27
		var points := clampi(25 + strength + randi_range(-18, 18), 20, 90)
		table.append({"name":str(team),"pts":points,"gf":randi_range(25,75),"ga":randi_range(25,70)})
	table.sort_custom(func(a, b):
		if int(a.get("pts", 0)) == int(b.get("pts", 0)):
			return int(a.get("gf", 0)) - int(a.get("ga", 0)) > int(b.get("gf", 0)) - int(b.get("ga", 0))
		return int(a.get("pts", 0)) > int(b.get("pts", 0))
	)
	return table

func _playoff_winner(table: Array) -> String:
	if table.size() < 5:
		return str(table[0].get("name", "")) if not table.is_empty() else ""
	var semi_a := str(table[1].get("name", ""))
	var semi_b := str(table[4].get("name", ""))
	var semi_c := str(table[2].get("name", ""))
	var semi_d := str(table[3].get("name", ""))
	var winner_a := _playoff_match_winner(semi_a, semi_b)
	var winner_b := _playoff_match_winner(semi_c, semi_d)
	return _playoff_match_winner(winner_a, winner_b)

func _playoff_match_winner(a: String, b: String) -> String:
	var a_power := _club_power(a)
	var b_power := _club_power(b)
	var chance := clampf(0.5 + float(a_power - b_power) / 120.0, 0.2, 0.8)
	return a if randf() < chance else b

func _finish_season_and_move_club() -> void:
	if league.is_empty() or day < fixtures.size():
		last_season_message = "Completa tutte le giornate prima di chiudere la stagione."
		return
	_initialise_pyramid()
	var divisions: Array = DIVISIONS.get(country, [])
	var original_division := division
	var original_index := divisions.find(original_division)
	var current_key := country + "|" + original_division
	var current_table: Array = league.duplicate()
	current_table.sort_custom(func(a, b):
		if int(a.get("pts", 0)) == int(b.get("pts", 0)):
			var gd_a := int(a.get("gf", 0)) - int(a.get("ga", 0))
			var gd_b := int(b.get("gf", 0)) - int(b.get("ga", 0))
			if gd_a == gd_b: return int(a.get("gf", 0)) > int(b.get("gf", 0))
			return gd_a > gd_b
		return int(a.get("pts", 0)) > int(b.get("pts", 0))
	)
	var position := -1
	for i in range(current_table.size()):
		if str(current_table[i].get("name", "")) == club_name:
			position = i
			break
	if position >= 0:
		season_history.append({"season":season,"division":original_division,"position":position + 1,"teams":current_table.size(),"points":int(current_table[position].get("pts", 0))})
		if season_history.size() > 12: season_history.pop_front()
	var rankings: Dictionary = {}
	for div in divisions:
		var key := country + "|" + str(div)
		var teams: Array = pyramid_state.get(key, [])
		if key == current_key:
			rankings[key] = current_table
		else:
			rankings[key] = _simulate_ai_table(teams)
	var promoted: Dictionary = {}
	var relegated: Dictionary = {}
	for i in range(divisions.size()):
		var key := country + "|" + str(divisions[i])
		var table: Array = rankings.get(key, [])
		if table.is_empty(): continue
		if i < divisions.size() - 1:
			var playoff := _playoff_winner(table)
			var up: Array = [str(table[0].get("name", ""))]
			if playoff != "" and not up.has(playoff): up.append(playoff)
			promoted[key] = up
		if i > 0:
			var down: Array = []
			for j in range(maxi(0, table.size() - 2), table.size()):
				down.append(str(table[j].get("name", "")))
			relegated[key] = down
	var new_state: Dictionary = {}
	for i in range(divisions.size()):
		var key := country + "|" + str(divisions[i])
		var clubs: Array = pyramid_state.get(key, []).duplicate()
		for team in promoted.get(key, []): clubs.erase(team)
		for team in relegated.get(key, []): clubs.erase(team)
		if i > 0:
			var lower_key := country + "|" + str(divisions[i - 1])
			for team in promoted.get(lower_key, []):
				if not clubs.has(team): clubs.append(team)
		if i < divisions.size() - 1:
			var upper_key := country + "|" + str(divisions[i + 1])
			for team in relegated.get(upper_key, []):
				if not clubs.has(team): clubs.append(team)
		new_state[key] = clubs
	pyramid_state = new_state
	var new_division := original_division
	for div in divisions:
		if pyramid_state.get(country + "|" + str(div), []).has(club_name):
			new_division = str(div)
			break
	if new_division != original_division:
		if divisions.find(new_division) > original_index:
			cash += 1500000
			last_season_message = "PROMOZIONE! " + club_name + " sale in " + new_division + "."
		else:
			cash = maxi(0, cash - 300000)
			last_season_message = "RETROCESSIONE: " + club_name + " scende in " + new_division + "."
		division = new_division
	else:
		last_season_message = "Stagione conclusa: " + str(position + 1) + "° posto in " + original_division + "."
	qualified_european_comp = ""
	if original_index == divisions.size() - 1 and position >= 0:
		if position == 0:
			qualified_european_comp = "UEFA Champions League"
		elif position <= 2:
			qualified_european_comp = "UEFA Europa League"
		elif position <= 4:
			qualified_european_comp = "UEFA Conference League"
	if cup_winner == club_name and qualified_european_comp == "":
		qualified_european_comp = "UEFA Europa League"
	european_status = "Qualificato: " + qualified_european_comp if qualified_european_comp != "" else "Non qualificato"

func _new_season() -> void:
	if day < fixtures.size():
		_label("Devi completare il campionato prima di avviare una nuova stagione.")
		return
	var award_player: Dictionary = {}
	var top_scorer: Dictionary = {}
	for candidate in players:
		if award_player.is_empty() or float(candidate.get("last_rating", 0.0)) > float(award_player.get("last_rating", 0.0)):
			award_player = candidate
		if top_scorer.is_empty() or int(candidate.get("goals", 0)) > int(top_scorer.get("goals", 0)):
			top_scorer = candidate
	var awards_text := "🏆 PREMI DI FINE STAGIONE"
	if not award_player.is_empty():
		awards_text += "\\nMVP: " + str(award_player.get("name", "")) + "  •  " + str(award_player.get("last_rating", 0)) + "/10"
	if not top_scorer.is_empty():
		awards_text += "\\nCapocannoniere: " + str(top_scorer.get("name", "")) + "  •  " + str(top_scorer.get("goals", 0)) + " gol"
	_finish_season_and_move_club()
	last_season_message += "\\n" + awards_text
	season += 1
	day = 0
	var expired_contracts: Array = []
	for i in range(players.size() - 1, -1, -1):
		var p: Dictionary = players[i]
		if bool(p.get("loan", false)):
			wage_budget += int(p.get("wage", 0))
			players.remove_at(i)
			continue
		p["age"] = int(p.get("age", 20)) + 1
		p["contract"] = maxi(0, int(p.get("contract", 0)) - 1)
		p["fitness"] = 100
		p["injury"] = 0
		p["suspension"] = 0
		p["yellow_season"] = 0
		if int(p.get("contract", 0)) == 0:
			expired_contracts.append(str(p.get("name", "Giocatore")))
			wage_budget += int(p.get("wage", 0))
			players.remove_at(i)
		elif int(p.get("age", 20)) < 30 and int(p.get("rating", 50)) < int(p.get("potential", 90)):
			p["rating"] = mini(int(p.get("potential", 90)), int(p.get("rating", 50)) + randi_range(0, 2))
	_generate_league()
	_generate_youth_intake()
	_build_european_competitions()
	board_objective = {"type":"points","target":35,"progress":0,"reward":600000,"label":"Raggiungi 35 punti in campionato"}
	cup_round = 0
	cup_teams = [club_name]+CLUBS.slice(0,7)
	cup_winner = ""
	european_status = "In UEFA: " + qualified_european_comp if qualified_european_comp != "" else "Non qualificato"
	_generate_market()
	cash += 1000000
	_ensure_lineup()
	_save_game()
	_show_home()
	if expired_contracts.size() > 0:
		status_label.text = "Contratti scaduti: " + ", ".join(expired_contracts) + ". Ingaggi liberati."

func _show_tactics() -> void:
	_clear_content()
	_label("TATTICHE",22)
	_add_option("Mentalità",["Difensiva","Equilibrata","Offensiva"],"mentalita")
	_add_option("Pressing",["Basso","Medio","Alto"],"pressing")
	_add_option("Costruzione",["Corta","Mista","Diretta"],"costruzione")
	_add_option("Linea difensiva",["Bassa","Media","Alta"],"linea")
	_add_option("Piano sostituzioni",["Anticipate","Equilibrate","Tardive"],"sostituzioni")
	_button("Salva tattiche",func(): _save_game(); _show_home())

func _add_option(caption: String, options: Array, key: String) -> void:
	_label(caption)
	var opt := OptionButton.new()
	for value in options:
		opt.add_item(value)
	for i in range(options.size()):
		if options[i] == str(tactics[key]):
			opt.select(i)
	opt.item_selected.connect(func(i): tactics[key] = options[i])
	content.add_child(opt)


func _generate_youth_intake() -> void:
	youth_players.clear()
	var academy_level := int(staff.get("academy", 0))
	for i in range(4 + academy_level):
		var prospect: Dictionary = _make_player(i)
		prospect["id"] = randi()
		prospect["age"] = randi_range(16, 18)
		prospect["rating"] = randi_range(42 + academy_level * 2, 58 + academy_level * 2)
		prospect["potential"] = randi_range(72 + academy_level, 88 + academy_level * 2)
		prospect["wage"] = randi_range(250, 650)
		prospect["value"] = int(prospect["potential"] * prospect["potential"] * 500)
		prospect["morale"] = randi_range(60, 82)
		prospect["fitness"] = 100
		prospect["contract"] = 3
		prospect["youth"] = true
		youth_players.append(prospect)

func _show_youth() -> void:
	_clear_content()
	_label("SETTORE GIOVANILE", 22)
	_label("Osserva i prospetti, valuta il potenziale e promuovi i talenti in prima squadra. L'accademia migliora la qualità e il numero dei nuovi arrivi.")
	_label("Livello accademia: " + str(staff.get("academy", 0)) + " • Prospetti disponibili: " + str(youth_players.size()))
	_button("Migliora accademia (€" + _money(300000 * (int(staff.get("academy", 0)) + 1)) + ")", func(): _upgrade_staff("academy"))
	for i in range(youth_players.size()):
		var p: Dictionary = youth_players[i]
		_label(str(p.get("name", "Prospetto")) + " • " + str(p.get("age", 17)) + " anni • " + str(p.get("position", "CC")) + " • " + str(p.get("rating", 45)) + " OVR / " + str(p.get("potential", 80)) + " POT")
		var index := i
		_button("Promuovi in prima squadra", func(): _sign_youth(index))
	if youth_players.is_empty():
		_label("Nessun prospetto disponibile. La prossima selezione arriverà a inizio stagione.")

func _sign_youth(index: int) -> void:
	if index < 0 or index >= youth_players.size():
		return
	if players.size() >= 30:
		_label("Rosa completa: vendi o svincola un giocatore prima di promuovere un giovane.")
		return
	var prospect: Dictionary = youth_players[index].duplicate(true)
	prospect.erase("youth")
	prospect["apps"] = 0
	prospect["goals"] = 0
	prospect["assists"] = 0
	prospect["yellow"] = 0
	prospect["yellow_season"] = 0
	prospect["red"] = 0
	prospect["suspension"] = 0
	prospect["injury"] = 0
	prospect["role"] = "Promessa"
	players.append(prospect)
	youth_players.remove_at(index)
	_ensure_lineup()
	_save_game()
	_show_youth()
	_label("Promosso: " + str(prospect.get("name", "Giocatore")) + " entra in prima squadra.")

func _show_staff() -> void:
	_clear_content()
	_label("STAFF TECNICO", 22)
	_label("Assumi specialisti per migliorare prestazioni, scouting, prevenzione infortuni e crescita dei giovani.")
	var descriptions := {
		"coach":"Allenatore: bonus alla forza della squadra e agli allenamenti",
		"scout":"Responsabile scouting: mercato più ricco e prospetti migliori",
		"physio":"Preparatore atletico: riduce il rischio di infortunio",
		"academy":"Direttore settore giovanile: più giovani e potenziale superiore"
	}
	for role in ["coach", "scout", "physio", "academy"]:
		_label(str(descriptions[role]) + " • Livello " + str(staff.get(role, 0)))
		var role_key: String = role
		_button("Migliora (" + _money(150000 * (int(staff.get(role_key, 0)) + 1)) + " €)", func(): _upgrade_staff(role_key))
	_button("Torna alla gestione club", func(): _show_tab("Club"))

func _upgrade_staff(role: String) -> void:
	if not staff.has(role):
		return
	var level := int(staff.get(role, 0))
	if level >= 5:
		_label("Questo reparto ha già raggiunto il livello massimo.")
		return
	var cost := 300000 * (level + 1) if role == "academy" else 150000 * (level + 1)
	if cash < cost:
		_label("Fondi insufficienti: servono €" + _money(cost) + ".")
		return
	cash -= cost
	staff[role] = level + 1
	if role == "academy":
		var current_prospects: Array = youth_players.duplicate(true)
		_generate_youth_intake()
		youth_players.append_array(current_prospects)
	_save_game()
	if selected_tab == "Giovanili":
		_show_youth()
	else:
		_show_staff()

func _show_stats() -> void:
	_clear_content()
	_label("STATISTICHE STAGIONALI", 22)
	_label("Capocannonieri della tua squadra, assist, presenze e disciplina.")
	var sorted_players: Array = players.duplicate()
	sorted_players.sort_custom(func(a, b): return int(a.get("goals", 0)) > int(b.get("goals", 0)))
	_label("MARCATORI", 18)
	for i in range(mini(10, sorted_players.size())):
		var p: Dictionary = sorted_players[i]
		_label(str(i + 1) + ". " + str(p.get("name", "Giocatore")) + " — " + str(p.get("goals", 0)) + " gol • " + str(p.get("apps", 0)) + " pres. • " + str(p.get("assists", 0)) + " assist")
	_label("STORICO CAMPIONATI", 18)
	for record in season_history:
		_label(str(record.get("season", "")) + " • " + str(record.get("division", "")) + " • Posizione " + str(record.get("position", "-")) + "/" + str(record.get("teams", "")) + " • " + str(record.get("points", 0)) + " pt")
	_label("DISCIPLINA E DISPONIBILITÀ", 18)
	for p in players:
		if int(p.get("yellow", 0)) > 0 or int(p.get("red", 0)) > 0 or int(p.get("injury", 0)) > 0 or int(p.get("suspension", 0)) > 0:
			_label(str(p.get("name", "Giocatore")) + " • Gialli " + str(p.get("yellow", 0)) + " • Rossi " + str(p.get("red", 0)) + " • Infortunio " + str(p.get("injury", 0)) + " turni • Squalifica " + str(p.get("suspension", 0)) + " turni")
	_button("Aggiorna statistiche", func(): _save_game(); _show_stats())

func _weekly_wages() -> int:
	var total := 0
	for p in players:
		total += int(p.wage)
	return total

func _money(value: int) -> String:
	return str(value)

func _save_game() -> void:
	var data := {"youth_players":youth_players,"staff":staff,"season_history":season_history,"club_name":club_name,"manager_name":manager_name,"career_difficulty":career_difficulty,"starting_budget_mode":starting_budget_mode,"country":country,"division":division,"season":season,"day":day,"cash":cash,"wage_budget":wage_budget,"players":players,"league":league,"fixtures":fixtures,"market":market,"cup_round":cup_round,"cup_teams":cup_teams,"cup_winner":cup_winner,"european_status":european_status,"tactics":tactics,"formation":formation,"lineup_ids":lineup_ids,"training_focus":training_focus,"last_season_message":last_season_message,"pyramid_state":pyramid_state,"sponsor_contract":sponsor_contract,"facilities":facilities,"board_objective":board_objective,"board_confidence":board_confidence,"match_report":match_report,"european_competitions":european_competitions,"qualified_european_comp":qualified_european_comp}
	var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		if is_instance_valid(status_label):
			status_label.text = "Carriera salvata sul dispositivo."


func _repair_saved_player_ids() -> void:
	var used: Dictionary = {}
	var lineup_changed := false
	for collection_index in range(3):
		var collection: Array = players if collection_index == 0 else market if collection_index == 1 else youth_players
		for p in collection:
			var player_id := int(p.get("id", -1))
			if used.has(player_id):
				var replacement_id: int = randi()
				while used.has(replacement_id): replacement_id = randi()
				p["id"] = replacement_id
				p["portrait_seed"] = replacement_id
				player_id = replacement_id
				if collection_index == 0: lineup_changed = true
			used[player_id] = true
	if lineup_changed:
		lineup_ids.clear()

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_show_setup()
		return
	navigation.visible = true
	var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	club_name = str(d.get("club_name","Dynasty FC"))
	manager_name = str(d.get("manager_name", "Manager"))
	career_difficulty = str(d.get("career_difficulty", "Normale"))
	starting_budget_mode = str(d.get("starting_budget_mode", "Standard"))
	country = str(d.get("country","Italia"))
	division = str(d.get("division","Serie C"))
	season = int(d.get("season",2026))
	day = int(d.get("day",0))
	cash = int(d.get("cash",2500000))
	wage_budget = int(d.get("wage_budget",65000))
	players = d.get("players",[])
	youth_players = d.get("youth_players", [])
	staff = d.get("staff", {"coach":0,"scout":0,"physio":0,"academy":0})
	season_history = d.get("season_history", [])
	league = d.get("league",[])
	fixtures = d.get("fixtures",[])
	market = d.get("market",[])
	cup_round = int(d.get("cup_round",0))
	cup_teams = d.get("cup_teams",[])
	cup_winner = str(d.get("cup_winner",""))
	european_status = str(d.get("european_status","Non qualificato"))
	var loaded_tactics: Dictionary = d.get("tactics", tactics)
	var default_tactics := {"mentalita":"Equilibrata","pressing":"Medio","costruzione":"Mista","linea":"Media","sostituzioni":"Equilibrate"}
	for tactic_key in default_tactics.keys():
		if not loaded_tactics.has(tactic_key): loaded_tactics[tactic_key] = default_tactics[tactic_key]
	tactics = loaded_tactics
	formation = str(d.get("formation", "4-3-3"))
	lineup_ids = d.get("lineup_ids", [])
	_repair_saved_player_ids()
	training_focus = str(d.get("training_focus", "Equilibrio"))
	last_season_message = str(d.get("last_season_message", ""))
	pyramid_state = d.get("pyramid_state", {})
	sponsor_contract = d.get("sponsor_contract", {})
	facilities = d.get("facilities", facilities)
	board_objective = d.get("board_objective", {})
	board_confidence = int(d.get("board_confidence", 75))
	match_report = d.get("match_report", {})
	european_competitions = d.get("european_competitions", {})
	qualified_european_comp = str(d.get("qualified_european_comp", ""))
	_ensure_lineup()
	# Migrazione automatica delle vecchie carriere con calendario fisso da 16 club.
	if league.size() == 16 or fixtures.size() == 30:
		day = 0
		_generate_league()
		_save_game()
	_show_tab("Home")
	status_label.text = "Carriera caricata."

func _simulate_substitutions() -> Array:
	var result: Array = []
	if players.size() <= 11:
		return result
	var starters: Array = []
	var bench: Array = []
	for p in players:
		if lineup_ids.has(int(p.get("id", -1))):
			starters.append(p)
		elif int(p.get("injury", 0)) == 0 and int(p.get("suspension", 0)) == 0:
			bench.append(p)
	starters.sort_custom(func(a, b): return int(a.get("fitness", 100)) < int(b.get("fitness", 100)))
	bench.sort_custom(func(a, b): return int(a.get("rating", 0)) > int(b.get("rating", 0)))
	var count := mini(3, mini(starters.size(), bench.size()))
	var timing: Array = [60, 70, 80]
	match str(tactics.get("sostituzioni", "Equilibrate")):
		"Anticipate": timing = [50, 60, 70]
		"Tardive": timing = [70, 78, 85]
	for i in range(count):
		var outgoing: Dictionary = starters[i]
		var incoming: Dictionary = bench[i]
		result.append({"minute":int(timing[i]) + randi_range(0, 3),"out_id":int(outgoing.get("id", -1)),"in_id":int(incoming.get("id", -1)),"out_name":str(outgoing.get("name", "Giocatore")),"in_name":str(incoming.get("name", "Giocatore"))})
	return result

func _create_match_report(home: String, away: String, home_goals: int, away_goals: int, substitutions: Array) -> Dictionary:
	var events: Array = []
	var home_attackers: Array = []
	var away_attackers: Array = []
	for p in players:
		if ["ATT","AD","AS","COC"].has(str(p.get("position", ""))):
			home_attackers.append(p)
	for i in range(home_goals + away_goals):
		var minute := randi_range(2, 90)
		var is_home := i < home_goals
		var scorer_name := "Attaccante"
		var candidates: Array = []
		var user_scores_at_home := home == club_name
		if is_home == user_scores_at_home: candidates = home_attackers
		if candidates.size() > 0:
			scorer_name = str(candidates.pick_random().get("name", "Attaccante"))
		else:
			scorer_name = FIRST.pick_random() + " " + LAST.pick_random()
		var team_name := home if is_home else away
		events.append({"minute":minute,"text":"GOL! " + team_name + " — " + scorer_name + " (" + str(minute) + "′)","type":"goal"})
	for minute in range(1, 91):
		var commentary: String = ["Azione manovrata a centrocampo","La squadra prova ad allargare il gioco","Pressione sul portatore di palla","Possesso palla e ricerca degli spazi","Lancio in profondità, difesa attenta","Duello aereo nella zona centrale","La squadra guadagna metri","Cross dalla fascia, respinta della difesa"].pick_random()
		events.append({"minute":minute,"text":str(minute) + "′ — " + commentary,"type":"commentary"})
	for sub in substitutions:
		events.append({"minute":int(sub.get("minute", 60)),"text":"Sostituzione " + club_name + ": " + str(sub.get("in_name", "")) + " per " + str(sub.get("out_name", "")),"type":"sub"})
	for i in range(randi_range(1, 3)):
		var minute := randi_range(8, 88)
		events.append({"minute":minute,"text":"Cartellino giallo — " + (home if i % 2 == 0 else away) + " (" + str(minute) + "′)","type":"card"})
	events.append({"minute":1,"text":"1′ — Calcio d'inizio","type":"start"})
	events.append({"minute":45,"text":"45′ — Fine primo tempo","type":"break"})
	events.append({"minute":90,"text":"90′ — Triplice fischio","type":"end"})
	events.sort_custom(func(a, b): return int(a.get("minute", 0)) < int(b.get("minute", 0)))
	var played_ids: Array = lineup_ids.duplicate()
	for sub in substitutions:
		played_ids.erase(int(sub.get("out_id", -1)))
		played_ids.append(int(sub.get("in_id", -1)))
	return {"home":home,"away":away,"home_goals":home_goals,"away_goals":away_goals,"events":events,"substitutions":substitutions,"played_ids":played_ids,"date_label":"Giornata " + str(day + 1)}

func _show_match_report() -> void:
	if match_report.is_empty():
		_show_home()
		return
	_clear_content()
	var home_goals := int(match_report.get("home_goals", 0))
	var away_goals := int(match_report.get("away_goals", 0))
	var opponent := str(match_report.get("away", "") if str(match_report.get("home", "")) == club_name else match_report.get("home", ""))
	var score_panel := PanelContainer.new()
	content.add_child(score_panel)
	var score_box := VBoxContainer.new()
	score_panel.add_child(score_box)
	var match_tag := Label.new()
	match_tag.text = "FULL TIME  •  " + ("DERBY" if _is_derby(opponent) else str(match_report.get("date_label", "MATCHDAY")))
	match_tag.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	match_tag.add_theme_color_override("font_color", Color("#ffd36a") if _is_derby(opponent) else Color("#67dce9"))
	score_box.add_child(match_tag)
	var score := Label.new()
	score.text = str(match_report.get("home", "")) + "\n" + str(home_goals) + "   —   " + str(away_goals) + "\n" + str(match_report.get("away", ""))
	score.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	score.add_theme_font_size_override("font_size", 25)
	score_box.add_child(score)
	var visual = preload("res://scripts/match_visualizer.gd").new()
	visual.setup(match_report)
	content.add_child(visual)
	_label("AZIONI E CRONACA", 19)
	var events: Array = match_report.get("events", [])
	var important := 0
	for event in events:
		if str(event.get("type", "")) in ["goal", "sub", "card", "break", "end", "start"]:
			var event_type := str(event.get("type", ""))
			var prefix := "⚽" if event_type == "goal" else "🔁" if event_type == "sub" else "🟨" if event_type == "card" else "⏱"
			_label(prefix + "  " + str(event.get("minute", 0)) + "′  " + str(event.get("text", "")))
			important += 1
	if important == 0:
		_label("Partita equilibrata, poche occasioni decisive.")
	_label("VALUTAZIONI GIOCATORI", 19)
	var rated: Array = []
	for p in players:
		if match_report.get("played_ids", []).has(int(p.get("id", -1))):
			rated.append(p)
	rated.sort_custom(func(a, b): return float(a.get("last_rating", 6.0)) > float(b.get("last_rating", 6.0)))
	for p in rated:
		var rating := float(p.get("last_rating", 6.0))
		_label(str(p.get("name", "")) + "   " + str(p.get("position", "")) + "   " + str(rating) + "/10")
	_button("Torna alla carriera", _show_home)
	_button("Rivedi formazione", _show_formation)

func _initialise_club_business() -> void:
	sponsor_contract = {"name":"Sponsor cittadino","weekly":35000,"bonus":350000,"target":20,"goal":"Raggiungi 20 punti","active":true}
	facilities = {"training":1,"stadium":1,"medical":1,"academy":1}
	board_confidence = 75
	board_objective = {"type":"points","target":35,"progress":0,"reward":600000,"label":"Raggiungi 35 punti in campionato"}

func _update_board_after_match(goals: int, conceded: int) -> void:
	if goals > conceded:
		board_objective["progress"] = int(board_objective.get("progress", 0)) + 3
	elif goals == conceded:
		board_objective["progress"] = int(board_objective.get("progress", 0)) + 1
	if int(board_objective.get("progress", 0)) >= int(board_objective.get("target", 35)):
		if not bool(board_objective.get("completed", false)):
			cash += int(board_objective.get("reward", 0))
			board_confidence = mini(100, board_confidence + 12)
			board_objective["completed"] = true
			board_objective["label"] = "Obiettivo completato! Premio incassato."
	else:
		if goals < conceded:
			board_confidence = maxi(10, board_confidence - 1)
		elif goals > conceded:
			board_confidence = mini(100, board_confidence + 1)

func _show_society() -> void:
	_clear_content()
	_label("DIREZIONE E GESTIONE SOCIETARIA", 22)
	_label("Fiducia della dirigenza: " + str(board_confidence) + "/100")
	_label("Obiettivo: " + str(board_objective.get("label", "Nessun obiettivo")) + " • " + str(board_objective.get("progress", 0)) + "/" + str(board_objective.get("target", 0)) + " punti")
	_label("Premio obiettivo: €" + _money(int(board_objective.get("reward", 0))))
	_label("SPONSOR PRINCIPALE", 18)
	_label(str(sponsor_contract.get("name", "Nessuno")) + " • €" + _money(int(sponsor_contract.get("weekly", 0))) + " a settimana • Bonus €" + _money(int(sponsor_contract.get("bonus", 0))))
	_button("Negozia nuovo sponsor", _show_sponsor_offers)
	_label("STRUTTURE DEL CLUB", 18)
	var facility_names := {"training":"Centro allenamento","stadium":"Stadio","medical":"Centro medico","academy":"Accademia giovanile"}
	for key in ["training","stadium","medical","academy"]:
		var level := int(facilities.get(key, 1))
		_label(str(facility_names[key]) + " • Livello " + str(level) + "/5")
		var facility_key: String = key
		_button("Migliora " + str(facility_names[key]) + " (€" + _money(250000 * level * level) + ")", func(): _upgrade_facility(facility_key))
	_button("Torna al club", func(): _show_tab("Club"))

func _show_sponsor_offers() -> void:
	_clear_content()
	_label("PROPOSTE SPONSOR", 22)
	var offers := [
		{"name":"Local Sport Group","weekly":52000,"bonus":250000,"target":25},
		{"name":"Dynasty Energy","weekly":78000,"bonus":650000,"target":40},
		{"name":"Global Football Partners","weekly":115000,"bonus":1200000,"target":55}
	]
	for offer in offers:
		var contract: Dictionary = offer
		_label(str(contract.name) + " • €" + _money(int(contract.weekly)) + "/sett. • Bonus €" + _money(int(contract.bonus)) + " • Obiettivo " + str(contract.target) + " punti")
		_button("Firma con " + str(contract.name), func(): _sign_sponsor(contract))
	_button("Annulla", _show_society)

func _sign_sponsor(contract: Dictionary) -> void:
	sponsor_contract = {"name":str(contract.get("name","Sponsor")),"weekly":int(contract.get("weekly",0)),"bonus":int(contract.get("bonus",0)),"target":int(contract.get("target",0)),"active":true}
	board_objective = {"type":"points","target":int(contract.get("target",0)),"progress":0,"reward":int(contract.get("bonus",0)),"label":"Obiettivo sponsor: " + str(contract.get("target",0)) + " punti"}
	_save_game()
	_show_society()

func _upgrade_facility(key: String) -> void:
	if not facilities.has(key):
		return
	var level := int(facilities.get(key, 1))
	if level >= 5:
		_label("Struttura già al livello massimo.")
		return
	var cost := 250000 * level * level
	if cash < cost:
		_label("Fondi insufficienti: servono €" + _money(cost))
		return
	cash -= cost
	facilities[key] = level + 1
	if key == "academy":
		staff["academy"] = maxi(int(staff.get("academy", 0)), level + 1)
		_generate_youth_intake()
	_save_game()
	_show_society()


func _make_european_competition(title: String, teams: Array) -> Dictionary:
	var chosen: Array = teams.slice(0, 8)
	var groups := [chosen.slice(0, 4), chosen.slice(4, 8)]
	var tables: Dictionary = {}
	for team in chosen:
		tables[str(team)] = {"name":str(team),"p":0,"w":0,"d":0,"l":0,"gf":0,"ga":0,"pts":0}
	return {"name":title,"teams":chosen,"groups":groups,"tables":tables,"phase":"groups","round":0,"semi_pairs":[],"finalists":[],"winner":"","history":[]}

func _build_european_competitions() -> void:
	var pool: Array = []
	var old_country := country
	var old_division := division
	for c in COUNTRIES:
		country = str(c)
		var options: Array = DIVISIONS.get(country, [])
		if options.is_empty(): continue
		division = str(options[options.size() - 1])
		for team in _league_team_names():
			if not pool.has(team): pool.append(team)
	country = old_country
	division = old_division
	pool.shuffle()
	var target := qualified_european_comp
	var comp_names := ["UEFA Champions League","UEFA Europa League","UEFA Conference League"]
	european_competitions.clear()
	for name in comp_names:
		var teams: Array = []
		if name == target:
			teams.append(club_name)
		while teams.size() < 8 and pool.size() > 0:
			var next_team: String = str(pool.pop_front())
			if not teams.has(next_team) and next_team != club_name:
				teams.append(next_team)
		while teams.size() < 8:
			var filler: String = "Continental FC " + str(teams.size() + 1) + " " + name.replace("UEFA ", "")
			if not teams.has(filler): teams.append(filler)
		european_competitions[name] = _make_european_competition(name, teams)

func _european_match(a: String, b: String, comp: Dictionary) -> Dictionary:
	var a_power := _club_power(a)
	var b_power := _club_power(b)
	var hg := _goals_for_power(a_power + 2, b_power)
	var ag := _goals_for_power(b_power, a_power + 2)
	var tables: Dictionary = comp.get("tables", {})
	var home: Dictionary = tables.get(a, {})
	var away: Dictionary = tables.get(b, {})
	if str(comp.get("phase", "groups")) == "groups" and not home.is_empty() and not away.is_empty():
		home["p"] = int(home.get("p", 0)) + 1
		away["p"] = int(away.get("p", 0)) + 1
		home["gf"] = int(home.get("gf", 0)) + hg
		home["ga"] = int(home.get("ga", 0)) + ag
		away["gf"] = int(away.get("gf", 0)) + ag
		away["ga"] = int(away.get("ga", 0)) + hg
		if hg > ag:
			home["w"] = int(home.get("w", 0)) + 1
			home["pts"] = int(home.get("pts", 0)) + 3
			away["l"] = int(away.get("l", 0)) + 1
		elif hg < ag:
			away["w"] = int(away.get("w", 0)) + 1
			away["pts"] = int(away.get("pts", 0)) + 3
			home["l"] = int(home.get("l", 0)) + 1
		else:
			home["d"] = int(home.get("d", 0)) + 1
			away["d"] = int(away.get("d", 0)) + 1
			home["pts"] = int(home.get("pts", 0)) + 1
			away["pts"] = int(away.get("pts", 0)) + 1
	if a == club_name or b == club_name:
		var subs := _simulate_substitutions()
		match_report = _create_match_report(a, b, hg, ag, subs)
		var user_goals := hg if a == club_name else ag
		var user_conceded := ag if a == club_name else hg
		_apply_player_match(user_goals, user_conceded, subs)
	return {"home":a,"away":b,"hg":hg,"ag":ag}

func _group_standings(group: Array, comp: Dictionary) -> Array:
	var tables: Dictionary = comp.get("tables", {})
	var ranked: Array = []
	for team in group:
		ranked.append(tables.get(str(team), {"name":str(team),"pts":0,"gf":0,"ga":0}))
	ranked.sort_custom(func(a, b):
		if int(a.get("pts", 0)) == int(b.get("pts", 0)):
			var gd_a := int(a.get("gf", 0)) - int(a.get("ga", 0))
			var gd_b := int(b.get("gf", 0)) - int(b.get("ga", 0))
			if gd_a == gd_b: return int(a.get("gf", 0)) > int(b.get("gf", 0))
			return gd_a > gd_b
		return int(a.get("pts", 0)) > int(b.get("pts", 0))
	)
	return ranked

func _play_european_round(key: String) -> void:
	if not european_competitions.has(key): return
	match_report.clear()
	var comp: Dictionary = european_competitions[key]
	var phase := str(comp.get("phase", "groups"))
	if phase == "groups":
		var round_index := int(comp.get("round", 0))
		var pairings := [[[0,1],[2,3]],[[0,2],[1,3]],[[0,3],[1,2]]]
		var groups: Array = comp.get("groups", [])
		for group in groups:
			if round_index >= pairings.size(): continue
			for pair in pairings[round_index]:
				var a := str(group[int(pair[0])])
				var b := str(group[int(pair[1])])
				var result := _european_match(a, b, comp)
				comp["history"].append({"phase":"groups","round":round_index + 1,"home":a,"away":b,"hg":result.hg,"ag":result.ag})
		comp["round"] = round_index + 1
		if int(comp["round"]) >= 3:
			var semi: Array = []
			for group_index in range(groups.size()):
				var table := _group_standings(groups[group_index], comp)
				semi.append(str(table[0].get("name", "")))
				semi.append(str(table[1].get("name", "")))
			comp["semi_pairs"] = [[semi[0], semi[3]], [semi[2], semi[1]]]
			comp["phase"] = "semi"
	elif phase == "semi":
		var pairs: Array = comp.get("semi_pairs", [])
		var finalists: Array = []
		for pair in pairs:
			var a := str(pair[0])
			var b := str(pair[1])
			var result := _european_match(a, b, comp)
			var winner := a if int(result.hg) > int(result.ag) else b if int(result.ag) > int(result.hg) else _playoff_match_winner(a, b)
			finalists.append(winner)
			comp["history"].append({"phase":"semi","home":a,"away":b,"hg":result.hg,"ag":result.ag,"winner":winner})
		comp["finalists"] = finalists
		comp["phase"] = "final"
	elif phase == "final":
		var finalists: Array = comp.get("finalists", [])
		if finalists.size() >= 2:
			var a := str(finalists[0])
			var b := str(finalists[1])
			var result := _european_match(a, b, comp)
			var winner := a if int(result.hg) > int(result.ag) else b if int(result.ag) > int(result.hg) else _playoff_match_winner(a, b)
			comp["winner"] = winner
			comp["phase"] = "done"
			comp["history"].append({"phase":"final","home":a,"away":b,"hg":result.hg,"ag":result.ag,"winner":winner})
			if winner == club_name:
				cash += 12000000 if key == "UEFA Champions League" else 7000000 if key == "UEFA Europa League" else 4000000
				board_confidence = mini(100, board_confidence + 20)
				european_status = "CAMPIONE D'EUROPA: " + key
	_save_game()
	if not match_report.is_empty() and (match_report.get("home", "") == club_name or match_report.get("away", "") == club_name):
		_show_match_report()
	else:
		_show_uefa()

func _show_uefa() -> void:
	_clear_content()
	_label("COMPETIZIONI UEFA", 23)
	_label("Champions League, Europa League e Conference League. Ogni competizione ha due gruppi da quattro, semifinali e finale.")
	_label("Tua qualificazione: " + (qualified_european_comp if qualified_european_comp != "" else "Non qualificato questa stagione"))
	for key in ["UEFA Champions League","UEFA Europa League","UEFA Conference League"]:
		if not european_competitions.has(key): continue
		var comp: Dictionary = european_competitions[key]
		_label(str(key), 19)
		_label("Fase: " + str(comp.get("phase", "groups")).to_upper() + " • Turno gruppi " + str(comp.get("round", 0)) + "/3")
		if str(comp.get("winner", "")) != "":
			_label("Vincitore: " + str(comp.get("winner", "")))
		for group_index in range(comp.get("groups", []).size()):
			_label("GRUPPO " + ("A" if group_index == 0 else "B"), 16)
			for team in _group_standings(comp.groups[group_index], comp):
				_label(str(team.get("name", "")) + " • " + str(team.get("pts", 0)) + " pt • GF " + str(team.get("gf", 0)) + " GS " + str(team.get("ga", 0)))
		if str(comp.get("phase", "")) != "done":
			var comp_key: String = key
			var action := "Gioca prossimo turno" if str(comp.get("phase", "")) == "groups" else "Gioca " + str(comp.get("phase", ""))
			_button(action + " — " + key, func(): _play_european_round(comp_key))
	_button("Torna alle coppe", func(): _show_tab("Coppe"))

