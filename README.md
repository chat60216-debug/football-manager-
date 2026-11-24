# FOOTBALL CAREER: DYNASTY

Mobile-first 2D football management prototype built with Godot 4.4.1.

## Current implemented systems
- New club creation and country/division selection.
- Embedded club-name lists for selected 2026/27 divisions; some lower divisions still use partial/generated opponent lists.
- Custom club added to the selected league rather than replacing an existing club.
- Dynamic double round-robin fixture generator with bye rounds for odd participant counts.
- Matchday simulation, league table, player fitness/morale/injuries, club finances.
- Procedurally generated fictional squad and transfer market.
- Transfer offers with fee, wage, contract duration and promised role; player sales.
- Tactical settings that modify match strength, national cup prototype and local save/load.
- User-club promotion/relegation based on final league position, with season history and financial rewards or penalties.
- Contract expiry at season end and weekly wage payments deducted from club cash.
- Youth academy with generated prospects, promotion to the first team and academy upgrades.
- Staff upgrades for coaching, scouting, fitness/medical support and youth development; coach and scout levels affect gameplay.
- Player statistics for goals, assists, appearances, cards, injuries and suspensions.
- Lineup validation prevents duplicate starters and replaces unavailable players when possible.
- Squad card UI: each player is shown as a card with overall rating, position, age and fitness. Drag a card onto another card to swap their order in the squad; card includes a sale action. The order is saved locally.

## Not yet complete
This repository is not yet a full commercial-grade football manager. The following systems still need implementation and testing:
- Complete and season-accurate club databases for every selectable division (including all Serie C groups, LaLiga 2 and Ligue 3).
- Real-world player database, licensed portraits, badges and accurate player attributes. Current players are fictional and generated.
- A proper formation/pitch lineup with position-aware drag-and-drop between starting XI and bench (the current card swap changes squad order only).
- AI club promotion/relegation, playoffs and cross-division movement for every team (currently only the user club moves automatically).
- Complete national cup formats and UEFA Champions League, Europa League and Conference League seasons with qualification, fixtures and prize money.
- More complete transfer AI, staff contracts, sponsorship, board objectives and a complete financial model.
- Detailed match engine with minute-by-minute commentary, match ratings, substitutions and multi-season balance testing.
- Automated gameplay regression tests and installation testing on physical devices.

## Run
Open this folder in Godot 4.4.1 and press Play.

## Android
GitHub Actions is configured to export a debug APK. A successful workflow run and device test are required before an APK can be called verified.

Package: com.chat60216.footballdynasty
