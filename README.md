# FOOTBALL CAREER: DYNASTY

Mobile-first 2D football management game built with Godot 4.4.1.

## Current playable foundation
- Create a custom club and choose one of five countries and a division.
- Add the created club to the selected league; it does not replace an existing club.
- Generate a double round-robin calendar from the participant count.
- Even participant count: 2 × (N - 1) rounds. Odd participant count: 2 × N rounds, with one bye per club in each half-season.
- League table, match simulation, squad fitness, morale, injuries and finances.
- Procedural player squad, transfers, negotiations, sales, tactical choices and local save/load.
- Basic national cup knockout mode.

## 2026/27 club data currently included
Verified participant lists are embedded for:
- Italy: Serie A and Serie B.
- England: Premier League, Championship, League One and League Two.
- Spain: LaLiga.
- France: Ligue 1 and Ligue 2.
- Germany: Bundesliga and 2. Bundesliga.

Some selectable lower divisions still use a partial club pool completed with generated placeholder opponents. In particular, Serie C is represented as a single 20-club group in this prototype; the real competition has multiple groups and needs its full group-specific database and promotion/playoff rules before it can be considered accurate. LaLiga 2 and Ligue 3 also need their complete season-specific club lists.

All player names and player attributes are currently fictional/procedurally generated. Real player data, crests and photos are not included.

## Run
Open this folder in Godot 4.4.1 and press Play.

## Android
GitHub Actions is configured to export a debug APK as an artifact.

Package: com.chat60216.footballdynasty

The Android build must complete successfully in GitHub Actions before an APK can be considered verified.
