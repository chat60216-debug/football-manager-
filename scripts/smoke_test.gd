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
	if game.european_competitions.size() != 3:
		_fail("UEFA competitions did not initialize")
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
