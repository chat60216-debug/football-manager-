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
	game._new_career()
	await process_frame
	if game.players.size() < 11:
		_fail("career squad has fewer than 11 players")
		return
	var real_count: int = game.players.filter(func(p): return bool(p.get("real_player", false))).size()
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
