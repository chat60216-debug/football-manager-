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
	# Training regression: development is gradual, weekly-limited and persistent.
	var training_candidate: Dictionary = {}
	for squad_player in game.players:
		if int(squad_player.get("age", 30)) < 29 and int(squad_player.get("rating", 50)) < int(squad_player.get("potential", 90)):
			training_candidate = squad_player
			break
	if training_candidate.is_empty():
		_fail("no eligible young player was available for the training regression")
		return
	var training_player_id := int(training_candidate.get("id", -1))
	training_candidate["training_xp"] = 90.0
	var training_rating_before := int(training_candidate.get("rating", 0))
	game.training_focus = "Tecnica"
	game.training_last_day = -1
	game.training_last_season = -1
	game.training_sessions = 0
	game.cash = 100000
	game._show_tab("Allenamento")
	await process_frame
	if game.selected_tab != "Allenamento":
		_fail("dedicated training centre did not open from navigation")
		return
	game._show_tab("Tattiche")
	await process_frame
	if game.selected_tab != "Tattiche":
		_fail("dedicated tactics screen did not open from navigation")
		return
	game._show_tab("Allenamento")
	await process_frame
	game._train_squad()
	var trained_player: Dictionary = {}
	for squad_player in game.players:
		if int(squad_player.get("id", -2)) == training_player_id:
			trained_player = squad_player
			break
	if trained_player.is_empty() or int(trained_player.get("rating", 0)) != training_rating_before + 1:
		_fail("technical training did not convert accumulated progress into one overall point")
		return
	if float(trained_player.get("training_xp", 0.0)) >= 100.0 or int(game.training_sessions) != 1 or int(game.training_last_day) != int(game.day):
		_fail("training progress or weekly session tracking is invalid")
		return
	var cash_after_training := int(game.cash)
	game._train_squad()
	if int(game.cash) != cash_after_training or int(game.training_sessions) != 1:
		_fail("training could be repeated multiple times in the same matchweek")
		return
	# Keep the later facility-upgrade regression independent from training costs.
	game.cash = 1000000
	var season_before_early_rollover := int(game.season)
	game._new_season()
	if int(game.season) != season_before_early_rollover:
		_fail("career advanced to a new season before the league was completed")
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
	if game._position_fit_penalty("POR", "ATT") < 50:
		_fail("goalkeeper role mismatch did not receive a strong tactical penalty")
		return
	var team_rating_before: int = game._team_rating()
	var original_fitness: Dictionary = {}
	for squad_player in game.players:
		var squad_id := int(squad_player.get("id", -1))
		if game.lineup_ids.has(squad_id):
			original_fitness[squad_id] = int(squad_player.get("fitness", 100))
			squad_player["fitness"] = 0
	var weakened_rating: int = game._team_rating()
	for squad_player in game.players:
		var squad_id := int(squad_player.get("id", -1))
		if original_fitness.has(squad_id):
			squad_player["fitness"] = int(original_fitness[squad_id])
	if weakened_rating >= team_rating_before:
		_fail("team strength did not react to low fitness")
		return
	if real_count < 11:
		_fail("real 2026/27 player squad was not imported")
		return
	game._show_squad()
	await process_frame
	var rendered_cards := 0
	for content_child in game.content.get_children():
		if content_child is GridContainer:
			rendered_cards = content_child.get_child_count()
	if rendered_cards != game.players.size():
		_fail("squad screen did not render a complete player card for every squad member")
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
	var market_sample: Dictionary = game.market[0]
	var market_name_query := str(market_sample.get("name", "")).substr(0, 3).to_lower()
	if not game._market_search_matches(market_sample, market_name_query):
		_fail("transfer market search did not match a player's name")
		return
	if game._market_search_matches(market_sample, "__no_such_dynasty_player__"):
		_fail("transfer market search returned a false positive")
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
	if int(saved_data.get("training_sessions", 0)) != 1 or int(saved_data.get("training_last_day", -1)) != int(game.day):
		_fail("training session history was not persisted in the career save")
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
	var match_stats: Dictionary = game.match_report.get("stats", {})
	if match_stats.is_empty():
		_fail("match report did not include match statistics")
		return
	if int(match_stats.get("home_possession", 0)) + int(match_stats.get("away_possession", 0)) != 100:
		_fail("match possession statistics did not total 100 percent")
		return
	if int(match_stats.get("home_shots", 0)) < int(game.match_report.get("home_goals", 0)) or int(match_stats.get("away_shots", 0)) < int(game.match_report.get("away_goals", 0)):
		_fail("match shot statistics were lower than the goals scored")
		return
	if int(match_stats.get("home_shots_target", 0)) > int(match_stats.get("home_shots", 0)) or int(match_stats.get("away_shots_target", 0)) > int(match_stats.get("away_shots", 0)):
		_fail("shots on target exceeded total shots")
		return
	var saved_user_fixture_result := false
	for recorded_result in game.match_results:
		if int(recorded_result.get("season", -1)) == game.season and int(recorded_result.get("day", -1)) == 0 and (str(recorded_result.get("home", "")) == game.club_name or str(recorded_result.get("away", "")) == game.club_name):
			saved_user_fixture_result = true
			break
	if not saved_user_fixture_result:
		_fail("league match result was not stored for the season calendar")
		return
	var recent_results: Array = game._last_results_for_club(5)
	if recent_results.is_empty() or str(recent_results[0].get("home", "")) != game.club_name and str(recent_results[0].get("away", "")) != game.club_name:
		_fail("career dashboard did not retrieve the latest result for the user's club")
		return
	if game.match_report.get("events", []).size() < 90:
		_fail("match timeline is not minute-by-minute")
		return
	var user_goal_events := 0
	for event in game.match_report.get("events", []):
		if str(event.get("type", "")) == "goal" and str(event.get("team", "")) == game.club_name:
			user_goal_events += 1
			var scorer_id := int(event.get("scorer_id", -1))
			if scorer_id < 0:
				_fail("match commentary did not assign a player identity to a user-team goal")
				return
			if game.players.filter(func(p): return int(p.get("id", -2)) == scorer_id).is_empty():
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
	var visualizer_node: Control = null
	for content_child in game.content.get_children():
		if content_child.get_script() == load("res://scripts/match_visualizer.gd"):
			visualizer_node = content_child
			break
	if visualizer_node == null:
		_fail("match visualizer did not load with the match report")
		return
	visualizer_node.call("setup", {"home": "Home Test", "away": "Away Test", "events": [{"type": "goal", "team": "Home Test"}]})
	visualizer_node.call("_process", 0.2)
	if float(visualizer_node.get("ball_position").x) <= 0.5:
		_fail("home goal did not animate the ball toward the away goal")
		return
	visualizer_node.call("setup", {"home": "Home Test", "away": "Away Test", "events": [{"type": "goal", "team": "Away Test"}]})
	visualizer_node.call("_process", 0.2)
	if float(visualizer_node.get("ball_position").x) >= 0.5:
		_fail("away goal did not animate the ball toward the home goal")
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
