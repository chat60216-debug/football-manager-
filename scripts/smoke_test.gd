extends SceneTree

func _initialize() -> void:
	call_deferred("_run_smoke_test")

func _fail(message: String) -> void:
	push_error("DYNASTY SMOKE TEST FAILED: " + message)
	quit(1)

func _run_smoke_test() -> void:
	var packed := load("res://scenes/main.tscn") as PackedScene
	if packed == null:
		_fail("main scene could not be loaded")
		return
	var game = packed.instantiate()
	root.add_child(game)
	await process_frame
	if game.setup_real_club == null or game.setup_division == null:
		_fail("career setup did not initialize")
		return
	game.setup_country.select(0)
	game._country_changed(0)
	game.setup_division.select(1)
	game._update_setup_real_clubs()
	if game.setup_real_club.get_item_count() < 2:
		_fail("real club selector has no imported Serie B clubs")
		return
	game.setup_real_club.select(1)
	game._continue_to_career_settings()
	if game.setup_difficulty == null or game.setup_budget == null:
		_fail("career settings did not appear after club selection")
		return
	game.setup_difficulty.select(1)
	game.setup_budget.select(1)
	game.observed_players = [{"id": -999, "scouting_status": "In osservazione"}]
	game._new_career()
	if not game.observed_players.is_empty():
		_fail("starting a new career retained scouting targets from the previous career")
		return
	await process_frame
	if game.players.size() < 11:
		_fail("career squad has fewer than 11 players")
		return
	var ai_power_first: int = game._club_power("Regression FC")
	var ai_power_second: int = game._club_power("Regression FC")
	if ai_power_first != ai_power_second:
		_fail("AI club strength changed between calculations in the same season")
		return
	var season_probe := {"goals": 7, "assists": 4, "apps": 18, "yellow": 3, "yellow_season": 3, "red": 1, "last_rating": 8.4}
	game._reset_player_season_stats(season_probe)
	if int(season_probe.get("goals", -1)) != 0 or int(season_probe.get("apps", -1)) != 0 or int(season_probe.get("yellow", -1)) != 0 or float(season_probe.get("last_rating", -1.0)) != 0.0:
		_fail("season statistics were not reset correctly")
		return
	game.youth_players = [{"id": 987654321, "name": "Youth Regression", "age": 16, "rating": 50, "potential": 80}]
	game._advance_youth_season()
	if game.youth_players.size() != 1 or int(game.youth_players[0].get("age", 0)) != 17:
		_fail("youth prospects did not age and persist into the next season")
		return
	var real_count: int = game.players.filter(func(p): return bool(p.get("real_player", false))).size()
	var goalkeeper_candidates: Array = game.players.filter(func(p): return str(p.get("position", "")) == "POR")
	if not goalkeeper_candidates.is_empty():
		var starting_goalkeeper: Dictionary = {}
		for squad_player in game.players:
			if int(squad_player.get("id", -1)) == int(game.lineup_ids[0]):
				starting_goalkeeper = squad_player
				break
		if str(starting_goalkeeper.get("position", "")) != "POR":
			_fail("automatic lineup did not place a goalkeeper in the goalkeeper slot")
			return
	var team_rating_before: int = game._team_rating()
	var outfield_id := int(game.lineup_ids[10])
	for squad_player in game.players:
		if int(squad_player.get("id", -1)) == outfield_id:
			var saved_position := str(squad_player.get("position", ""))
			var saved_fitness := int(squad_player.get("fitness", 100))
			squad_player["position"] = "POR"
			squad_player["fitness"] = 20
			var weakened_rating: int = game._team_rating()
			squad_player["position"] = saved_position
			squad_player["fitness"] = saved_fitness
			if weakened_rating >= team_rating_before:
				_fail("team strength did not react to poor role fit and low fitness")
				return
			break
	if real_count < 11:
		_fail("real 2026/27 player squad was not imported")
		return
	if game.pyramid_state.size() != 3:
		_fail("Italian league pyramid did not initialize")
		return
	var original_country: String = game.country
	var original_division: String = game.division
	for test_country in game.COUNTRIES:
		game.country = str(test_country)
		for test_division in game.DIVISIONS[game.country]:
			game.division = str(test_division)
			var club_names: Array = game._league_team_names()
			var expected_count := 20
			if game.division in ["League One","League Two","Championship"]: expected_count = 24
			elif game.division == "Liga 2": expected_count = 22
			elif game.division in ["Ligue 3","Ligue 2","Ligue 1","Bundesliga 2","Bundesliga 1"]: expected_count = 18
			if club_names.size() != expected_count:
				_fail("incorrect 2026/27 club count for " + game.country + " " + game.division + ": " + str(club_names.size()))
				return
			var unique_names: Array = []
			for club in club_names:
				if unique_names.has(club):
					_fail("duplicate clubs in " + game.country + " " + game.division)
					return
				unique_names.append(club)
	game.country = original_country
	game.division = original_division
	if game.european_competitions.size() != 3:
		_fail("UEFA competitions did not initialize")
		return
	var real_market_count: int = game.market.filter(func(p): return bool(p.get("real_player", false))).size()
	if real_market_count == 0:
		_fail("transfer market did not include real imported players")
		return
	# Scouting regression: assignment, duplicate protection, report countdown and persistence.
	if game.market.is_empty():
		_fail("transfer market is empty; scouting cannot be tested")
		return
	game.observed_players.clear()
	var scouted_id := int(game.market[0].get("id", -1))
	game._observe_market_player(0)
	if game.observed_players.size() != 1 or int(game.observed_players[0].get("id", -2)) != scouted_id:
		_fail("scouting assignment did not add the selected player")
		return
	game._observe_market_player(0)
	if game.observed_players.size() != 1:
		_fail("scouting allowed duplicate assignments for the same player")
		return
	for _tick in range(3):
		game._advance_scouting_reports()
	if str(game.observed_players[0].get("scouting_status", "")) != "Report completo" or not bool(game.observed_players[0].get("scouting_report", false)):
		_fail("scouting report did not complete after its expected countdown")
		return
	game._save_game()
	var save_file := FileAccess.open("user://dynasty_save.json", FileAccess.READ)
	if save_file == null:
		_fail("career save could not be opened after scouting")
		return
	var saved_data = JSON.parse_string(save_file.get_as_text())
	if typeof(saved_data) != TYPE_DICTIONARY or saved_data.get("observed_players", []).size() != 1:
		_fail("scouting shortlist was not persisted in the career save")
		return
	if not FileAccess.file_exists("user://dynasty_save.json.bak"):
		_fail("automatic career save backup was not created")
		return
	var damaged_save := FileAccess.open("user://dynasty_save.json", FileAccess.WRITE)
	if damaged_save == null:
		_fail("could not prepare save recovery regression test")
		return
	damaged_save.store_string("{ damaged json")
	damaged_save.close()
	game._load_game()
	if game.players.size() < 11 or game.observed_players.size() != 1:
		_fail("career save did not recover from the backup after JSON corruption")
		return
	game._remove_observed_player(scouted_id)
	if not game.observed_players.is_empty():
		_fail("scouting shortlist removal did not work")
		return
	game._show_formation()
	await process_frame
	var pitch_node: Control = null
	for child in game.content.get_children():
		if child.get_script() == load("res://scripts/tactical_pitch.gd"):
			pitch_node = child
			break
	if pitch_node == null:
		_fail("interactive tactical pitch did not load")
		return
	var lineup_before: Array = game.lineup_ids.duplicate()
	if pitch_node.slots_swapped.get_connections().is_empty():
		_fail("tactical pitch swap signal is not connected")
		return
	pitch_node.slots_swapped.emit(0, 1)
	await process_frame
	if int(game.lineup_ids[0]) != int(lineup_before[1]) or int(game.lineup_ids[1]) != int(lineup_before[0]):
		_fail("tactical pitch drag signal did not update the lineup")
		return
	game._show_society()
	var training_level := int(game.facilities.get("training", 1))
	game._upgrade_facility("training")
	if int(game.facilities.get("training", 1)) != training_level + 1:
		_fail("club facility upgrade did not apply")
		return
	game._play_matchday()
	await process_frame
	if game.match_report.is_empty():
		_fail("league match did not create a report")
		return
	if game.match_report.get("events", []).size() < 90:
		_fail("match timeline is not minute-by-minute")
		return
	var user_goal_events := 0
	for event in game.match_report.get("events", []):
		if str(event.get("type", "")) == "goal" and str(event.get("team", "")) == game.club_name:
			user_goal_events += 1
			var scorer_id := int(event.get("scorer_id", -1))
			if scorer_id != -1 and game.players.filter(func(p): return int(p.get("id", -2)) == scorer_id).is_empty():
				_fail("match commentary referenced a scorer outside the active squad")
				return
	var squad_goal_total := 0
	for player in game.players:
		squad_goal_total += int(player.get("goals", 0))
	if squad_goal_total != user_goal_events:
		_fail("player goal statistics did not match the match commentary")
		return
	game._show_match_report()
	await process_frame
	if game.content.get_child_count() < 90:
		_fail("match report UI did not display the full minute-by-minute timeline")
		return
	for _round in range(3):
		game._play_european_round("UEFA Champions League")
	for _round in range(3):
		if str(game.european_competitions["UEFA Champions League"].get("phase", "")) == "done":
			break
		game._play_european_round("UEFA Champions League")
	if str(game.european_competitions["UEFA Champions League"].get("phase", "")) != "done":
		_fail("UEFA competition did not reach a final and winner")
		return
	game.day = game.fixtures.size()
	for row in game.league:
		row["pts"] = 0
		if str(row.get("name", "")) == game.club_name:
			row["pts"] = 100
	game._finish_season_and_move_club()
	if game.division != "Serie A":
		_fail("automatic promotion from Serie B to Serie A failed")
		return
	if not game.pyramid_state.get("Italia|Serie A", []).has(game.club_name):
		_fail("promoted club was not moved into the higher division")
		return
	game._save_game()
	print("DYNASTY SMOKE TEST PASSED: real squad, league, match report, UEFA and promotion.")
	quit(0)
