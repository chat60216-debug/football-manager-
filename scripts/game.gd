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
	for tab in ["Home","Rosa","Mercato","Classifica","Coppe","Club"]:
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
	_generate_league()
	_generate_market()
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
	return {"id":randi(),"name":FIRST.pick_random()+" "+LAST.pick_random(),"position":pos,"age":age,"rating":rating,"potential":mini(92,rating+randi_range(2,20)),"wage":randi_range(900,4200),"value":rating*rating*1200,"morale":randi_range(65,90),"fitness":randi_range(82,100),"injury":0,"contract":randi_range(1,4),"role":ROLES.pick_random(),"goals":0,"assists":0,"apps":0,"yellow":0,"red":0}

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
	while known.size() < target:
		var generated := "FC " + LAST[known.size() % LAST.size()]
		if not known.has(generated):
			known.append(generated)
	return known

func _generate_league() -> void:
	league.clear()
	var names: Array = _league_team_names()
	if not names.has(club_name):
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
	for i in range(24):
		var p := _make_player(i)
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
		"Mercato": _show_market()
		"Classifica": _show_table()
		"Coppe": _show_cups()
		"Club": _show_club()

func _show_home() -> void:
	_clear_content()
	_label(club_name+" • "+division+" "+str(season),22)
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
			wage_budget -= _weekly_wages()
			if hg > ag:
				cash += 45000
	if not club_played:
		wage_budget -= _weekly_wages()
		for p in players:
			p.fitness = mini(100,int(p.fitness)+5)
	for p in players:
		if int(p.injury) > 0:
			p.injury = maxi(0,int(p.injury)-1)
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
	var total := 0
	for p in players:
		total += int(p.rating)
	return int(round(float(total)/players.size()))

func _apply_player_match(goals: int, conceded: int) -> void:
	var fit_players: Array = players.filter(func(p): return int(p.injury)==0)
	for p in fit_players:
		p.apps += 1
		p.fitness = maxi(35,int(p.fitness)-randi_range(5,11))
		if randf() < 0.012:
			p.injury = randi_range(1,5)
		if ["ATT","AD","AS"].has(p.position) and goals > 0 and randf() < 0.22:
			p.goals += 1
		if randf() < 0.015:
			p.yellow += 1
	for p in players:
		if goals > conceded:
			p.morale = mini(100,int(p.morale)+3)
		elif goals < conceded:
			p.morale = maxi(20,int(p.morale)-3)

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
	_button("Salva partita",_save_game)
	_button("Carica partita",_load_game)
	_button("Nuova stagione",_new_season)

func _new_season() -> void:
	season += 1
	day = 0
	for p in players:
		p.contract = maxi(0,int(p.contract)-1)
		p.fitness = 100
		p.injury = 0
		if int(p.contract) == 0:
			p.morale = maxi(20,int(p.morale)-12)
		elif int(p.age) < 30 and int(p.rating) < int(p.potential):
			p.rating = mini(int(p.potential),int(p.rating)+randi_range(0,2))
	_generate_league()
	cup_round = 0
	cup_teams = [club_name]+CLUBS.slice(0,7)
	cup_winner = ""
	european_status = "Non qualificato"
	_generate_market()
	cash += 1000000
	_save_game()
	_show_home()

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

func _weekly_wages() -> int:
	var total := 0
	for p in players:
		total += int(p.wage)
	return total

func _money(value: int) -> String:
	return str(value)

func _save_game() -> void:
	var data := {"club_name":club_name,"country":country,"division":division,"season":season,"day":day,"cash":cash,"wage_budget":wage_budget,"players":players,"league":league,"fixtures":fixtures,"market":market,"cup_round":cup_round,"cup_teams":cup_teams,"cup_winner":cup_winner,"european_status":european_status,"tactics":tactics}
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
	league = d.get("league",[])
	fixtures = d.get("fixtures",[])
	market = d.get("market",[])
	cup_round = int(d.get("cup_round",0))
	cup_teams = d.get("cup_teams",[])
	cup_winner = str(d.get("cup_winner",""))
	european_status = str(d.get("european_status","Non qualificato"))
	tactics = d.get("tactics",tactics)
	# Migrazione automatica delle vecchie carriere con calendario fisso da 16 club.
	if league.size() == 16 or fixtures.size() == 30:
		day = 0
		_generate_league()
		_save_game()
	_show_tab("Home")
	status_label.text = "Carriera caricata."
