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
var tactics := {"mentalita":"Equilibrata","pressing":"Medio","costruzione":"Mista","linea":"Media"}
var formation := "4-3-3"
var lineup_ids: Array = []
var training_focus := "Equilibrio"
var youth_players: Array = []
var staff := {"coach":0,"scout":0,"physio":0,"academy":0}
var season_history: Array = []
var last_season_message := ""
var selected_tab := "Home"
var root: VBoxContainer
var content: VBoxContainer
var status_label: Label
var setup_name: LineEdit
var setup_country: OptionButton
var setup_division: OptionButton
var market_fee: SpinBox
var market_wage: SpinBox
var market_years: SpinBox
var market_role: OptionButton
var selected_market_player := -1
var ui_built := false

func _ready() -> void:
	randomize()
	_build_shell()
	if FileAccess.file_exists(SAVE_PATH):
		_add_button("Carica carriera salvata", _load_game)
		_add_button("Nuova carriera", _show_setup)
	else:
		_show_setup()

func _build_shell() -> void:
	for child in get_children():
		child.queue_free()
	var bg := ColorRect.new()
	bg.color = Color("#091321")
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	root = VBoxContainer.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_theme_constant_override("separation", 8)
	add_child(root)
	var title := Label.new()
	title.text = "⚽ FOOTBALL CAREER: DYNASTY"
	title.add_theme_font_size_override("font_size", 25)
	title.add_theme_color_override("font_color", Color("#8ce5ff"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	root.add_child(title)
	status_label = Label.new()
	status_label.text = "La tua carriera calcistica"
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	root.add_child(status_label)
	var nav := GridContainer.new()
	nav.columns = 3
	root.add_child(nav)
	for tab in ["Home","Rosa","Formazione","Mercato","Classifica","Coppe","Club","Giovanili","Staff","Statistiche"]:
		var b := Button.new()
		b.text = tab
		b.custom_minimum_size = Vector2(0, 44)
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		b.pressed.connect(func(): _show_tab(tab))
		nav.add_child(b)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.add_child(scroll)
	content = VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	ui_built = true

func _clear_content() -> void:
	for child in content.get_children():
		child.queue_free()

func _label(text_value: String, size := 16) -> Label:
	var l := Label.new()
	l.text = text_value
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.add_theme_font_size_override("font_size", size)
	content.add_child(l)
	return l

func _button(text_value: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text_value
	b.custom_minimum_size = Vector2(0, 48)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.pressed.connect(callback)
	content.add_child(b)
	return b

func _add_button(text_value: String, callback: Callable) -> void:
	_button(text_value, callback)

func _show_setup() -> void:
	_clear_content()
	_label("CREA IL TUO CLUB", 23)
	_label("Nome della squadra")
	setup_name = LineEdit.new()
	setup_name.placeholder_text = "Es. AC Nova Milano"
	setup_name.text = "AC Nova Milano"
	content.add_child(setup_name)
	_label("Paese")
	setup_country = OptionButton.new()
	for c in COUNTRIES:
		setup_country.add_item(c)
	setup_country.item_selected.connect(_country_changed)
	content.add_child(setup_country)
	_label("Divisione")
	setup_division = OptionButton.new()
	content.add_child(setup_division)
	_country_changed(0)
	_button("INIZIA LA CARRIERA", _new_career)
	_label("Rosa, avversari e giocatori di mercato generati proceduralmente. Ogni carriera è diversa.")

func _country_changed(index: int) -> void:
	if not is_instance_valid(setup_country) or not is_instance_valid(setup_division):
		return
	country = COUNTRIES[index]
	setup_division.clear()
	for d in DIVISIONS[country]:
		setup_division.add_item(d)
	setup_division.select(DIVISIONS[country].size() - 1)

func _new_career() -> void:
	club_name = setup_name.text.strip_edges()
	if club_name.is_empty():
		club_name = "Dynasty FC"
	country = COUNTRIES[setup_country.selected]
	division = setup_division.get_item_text(setup_division.selected)
	season = 2026
	day = 0
	cash = 2500000
	wage_budget = 65000
	players.clear()
	for i in range(22):
		players.append(_make_player(i))
	_ensure_lineup()
	_generate_league()
	staff = {"coach":0,"scout":0,"physio":0,"academy":0}
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

func _make_player(index: int) -> Dictionary:
	var pos: String = POSITIONS[index % POSITIONS.size()]
	var rating := randi_range(54, 76)
	var age := randi_range(17, 34)
	return {"id":randi(),"portrait_seed":randi(),"name":FIRST.pick_random()+" "+LAST.pick_random(),"position":pos,"age":age,"rating":rating,"potential":mini(92,rating+randi_range(2,20)),"wage":randi_range(900,4200),"value":rating*rating*1200,"morale":randi_range(65,90),"fitness":randi_range(82,100),"injury":0,"contract":randi_range(1,4),"role":ROLES.pick_random(),"goals":0,"assists":0,"apps":0,"yellow":0,"red":0}

func _league_team_names() -> Array:
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
		"Italia": known = ["Albinoleffe","Alcione Milano","Arzignano Valchiampo","Atalanta U23","Brescia","Caldiero Terme","Cavese","Cittadella","Crotone","Foggia","Giana Erminio","Gubbio","Latina","Lecco","Lumezzane","Novara","Perugia","Pescara","Pro Patria","Pro Vercelli","Renate","Rimini","Ternana","Triestina","Trapani","Virtus Verona"]
		"Inghilterra": known = ["Birmingham City","Blackburn Rovers","Blackpool","Bolton Wanderers","Bradford City","Cardiff City","Charlton Athletic","Huddersfield Town","Leicester City","Middlesbrough","Millwall","Norwich City","Oxford United","Portsmouth","Preston North End","Queens Park Rangers","Reading","Sheffield United","Sheffield Wednesday","Stoke City","Swansea City","Watford","West Bromwich Albion","Wrexham"]
		"Spagna": known = ["Albacete","Almería","Burgos CF","Cádiz CF","CD Castellón","CD Leganés","CD Mirandés","Córdoba CF","Eibar","FC Andorra","Granada CF","Huesca","Las Palmas","Real Oviedo","Real Zaragoza","Sporting Gijón","Tenerife","Valladolid"]
		"Francia": known = ["Amiens SC","AS Saint-Étienne","Clermont Foot","EA Guingamp","FC Annecy","FC Metz","Grenoble Foot 38","Montpellier HSC","Pau FC","Red Star FC","SC Bastia","Stade Lavallois","USL Dunkerque"]
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
	for i in range(24 + int(staff.get("scout", 0)) * 3):
		var p := _make_player(i)
		if int(staff.get("scout", 0)) > 0:
			p["rating"] = mini(88, int(p["rating"]) + randi_range(0, int(staff.get("scout", 0)) * 2))
			p["potential"] = mini(94, int(p["potential"]) + int(staff.get("scout", 0)))
		p["value"] = int(p["rating"] * p["rating"] * 1450)
		p["wage"] = randi_range(700,5000)
		p["club"] = CLUBS.pick_random()
		market.append(p)

func _show_tab(tab: String) -> void:
	selected_tab = tab
	if not ui_built:
		return
	match tab:
		"Home": _show_home()
		"Rosa": _show_squad()
		"Formazione": _show_formation()
		"Mercato": _show_market()
		"Classifica": _show_table()
		"Coppe": _show_cups()
		"Club": _show_club()
		"Giovanili": _show_youth()
		"Staff": _show_staff()
		"Statistiche": _show_stats()

func _show_home() -> void:
	_clear_content()
	_label(club_name+" • "+division+" "+str(season),22)
	if last_season_message != "":
		_label(last_season_message, 17)
	_label("Turno "+str(day+1)+" / "+str(fixtures.size())+" • "+str(league.size())+" squadre")
	_label("Cassa: €"+_money(cash)+" • Budget ingaggi settimanale: €"+_money(wage_budget))
	_label("Rosa: "+str(players.size())+" calciatori • Media: "+str(_team_rating()))
	_label("Mentalità: "+tactics.mentalita+" | Pressing: "+tactics.pressing+" | Costruzione: "+tactics.costruzione)
	if day < fixtures.size():
		var fixture := _find_fixture(club_name)
		if not fixture.is_empty():
			_label("PROSSIMA PARTITA",20)
			_label(fixture.home+" vs "+fixture.away,24)
		else:
			_label("TURNO DI RIPOSO: la tua squadra non ha una partita in questo turno.",20)
		_button("GIOCA PROSSIMO TURNO",_play_matchday)
	else:
		_label("Campionato terminato.")
		_button("AVANZA ALLA NUOVA STAGIONE",_new_season)
	_button("Salva carriera",_save_game)
	_button("Impostazioni tattiche",_show_tactics)

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
			home_power = _team_rating()+3
		if away == club_name:
			away_power = _team_rating()
		var hg := _goals_for_power(home_power,away_power)
		var ag := _goals_for_power(away_power,home_power)
		_update_result(home,away,hg,ag)
		if home == club_name or away == club_name:
			club_played = true
			_apply_player_match(hg,ag)
			cash += 80000+hg*7000
			cash -= _weekly_wages()
			if hg > ag:
				cash += 45000
	if not club_played:
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
		return _team_rating()
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
		if int(p.get("injury", 0)) == 0 and int(p.get("suspension", 0)) == 0:
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
	_label("Media titolari: " + str(_team_rating()) + " OVR")
	_button("Salva formazione", func(): _save_game(); _show_home())

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

func _apply_player_match(goals: int, conceded: int) -> void:
	_ensure_lineup()
	var scorers: Array = []
	var fit_players: Array = players.filter(func(p): return int(p.get("injury", 0)) == 0)
	for p in fit_players:
		var is_starter := lineup_ids.has(int(p.get("id", -1)))
		if is_starter:
			p["apps"] = int(p.get("apps", 0)) + 1
			p["fitness"] = maxi(35, int(p.get("fitness", 100)) - randi_range(6, 12))
			if randf() < maxf(0.004, 0.014 - float(staff.get("physio", 0)) * 0.002):
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
		grid.add_child(card)

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
	for i in range(market.size()):
		var p: Dictionary = market[i]
		var idx := i
		_button(p.name+" | "+p.position+" | "+str(p.rating)+" OVR | €"+_money(p.value),func(): _negotiate(idx))

func _negotiate(index: int) -> void:
	if index < 0 or index >= market.size():
		return
	selected_market_player = index
	var p: Dictionary = market[index]
	_clear_content()
	_label("TRATTATIVA: "+p.name,22)
	_label(p.position+" • "+str(p.age)+" anni • "+str(p.rating)+" OVR • Potenziale "+str(p.potential))
	_label("Valore richiesto: €"+_money(p.value)+" • Ingaggio: €"+_money(p.wage)+"/sett.")
	_label("Offerta trasferimento (€)")
	market_fee = SpinBox.new()
	market_fee.min_value = 0
	market_fee.max_value = 50000000
	market_fee.step = 25000
	market_fee.value = p.value
	content.add_child(market_fee)
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
	content.add_child(market_role)
	_button("INVIA OFFERTA",_submit_offer)
	_button("CHIEDI PRESTITO (1 STAGIONE)",_submit_loan_offer)
	_button("Torna al mercato",_show_market)

func _submit_offer() -> void:
	if selected_market_player < 0 or selected_market_player >= market.size():
		return
	var p: Dictionary = market[selected_market_player]
	var fee := int(market_fee.value)
	var wage := int(market_wage.value)
	if fee > cash or wage > wage_budget:
		_label("Offerta rifiutata: fondi o budget ingaggi insufficienti.")
		return
	if fee < int(p.value*0.78) or wage < int(p.wage*0.85):
		_label("Offerta rifiutata. Prova ad aumentare cifra o ingaggio.")
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
			european_status = "Qualificato alla UEFA Conference League"
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
					p.rating = mini(int(p.get("potential", 90)), int(p.get("rating", 50)) + 1 + int(staff.get("coach", 0)))
			"Fisico":
				p.fitness = mini(100, int(p.get("fitness", 70)) + 12)
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


func _finish_season_and_move_club() -> void:
	if league.is_empty():
		return
	var sorted: Array = league.duplicate()
	sorted.sort_custom(func(a, b):
		if int(a.get("pts", 0)) == int(b.get("pts", 0)):
			var gd_a := int(a.get("gf", 0)) - int(a.get("ga", 0))
			var gd_b := int(b.get("gf", 0)) - int(b.get("ga", 0))
			if gd_a == gd_b:
				return int(a.get("gf", 0)) > int(b.get("gf", 0))
			return gd_a > gd_b
		return int(a.get("pts", 0)) > int(b.get("pts", 0))
	)
	var position := -1
	for i in range(sorted.size()):
		if str(sorted[i].get("name", "")) == club_name:
			position = i
			break
	if position >= 0:
		season_history.append({"season":season,"division":division,"position":position + 1,"teams":sorted.size(),"points":int(sorted[position].get("pts", 0))})
		if season_history.size() > 12:
			season_history.pop_front()
	var divisions: Array = DIVISIONS.get(country, [])
	var current_index := divisions.find(division)
	if current_index < 0 or position < 0:
		return
	if position == 0 and current_index < divisions.size() - 1:
		division = str(divisions[current_index + 1])
		cash += 1500000
		last_season_message = "Promozione conquistata: " + division
	elif position >= sorted.size() - 3 and current_index > 0:
		division = str(divisions[current_index - 1])
		cash = maxi(0, cash - 300000)
		last_season_message = "Retrocessione: nuova divisione " + division
	else:
		last_season_message = "Stagione conclusa: permanenza in " + division

func _new_season() -> void:
	_finish_season_and_move_club()
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
	cup_round = 0
	cup_teams = [club_name]+CLUBS.slice(0,7)
	cup_winner = ""
	european_status = "Non qualificato"
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
		_generate_youth_intake()
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
	var data := {"youth_players":youth_players,"staff":staff,"season_history":season_history,"club_name":club_name,"country":country,"division":division,"season":season,"day":day,"cash":cash,"wage_budget":wage_budget,"players":players,"league":league,"fixtures":fixtures,"market":market,"cup_round":cup_round,"cup_teams":cup_teams,"cup_winner":cup_winner,"european_status":european_status,"tactics":tactics,"formation":formation,"lineup_ids":lineup_ids,"training_focus":training_focus,"last_season_message":last_season_message}
	var file := FileAccess.open(SAVE_PATH,FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		if is_instance_valid(status_label):
			status_label.text = "Carriera salvata sul dispositivo."

func _load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_show_setup()
		return
	var file := FileAccess.open(SAVE_PATH,FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var d: Dictionary = parsed
	club_name = str(d.get("club_name","Dynasty FC"))
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
	tactics = d.get("tactics",tactics)
	formation = str(d.get("formation", "4-3-3"))
	lineup_ids = d.get("lineup_ids", [])
	training_focus = str(d.get("training_focus", "Equilibrio"))
	last_season_message = str(d.get("last_season_message", ""))
	_ensure_lineup()
	# Migrazione automatica delle vecchie carriere con calendario fisso da 16 club.
	if league.size() == 16 or fixtures.size() == 30:
		day = 0
		_generate_league()
		_save_game()
	_show_tab("Home")
	status_label.text = "Carriera caricata."
