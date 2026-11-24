# FOOTBALL CAREER: DYNASTY

Football management career game for Android, built with Godot 4.4.1.

## Implemented gameplay

- New career setup with country, division and real club selection where data is available.
- Season 2026/27 club lists for the selectable leagues. Serie C uses the current three 20-team groups; the selected club determines its group.
- Embedded real squad database generated from OpenFootballBase: 2026/27 squads for 10 competitions (Premier League, Championship, La Liga, Segunda, Serie A, Serie B, Bundesliga, 2. Bundesliga, Ligue 1 and Ligue 2).
- Current imported dataset: 198 clubs and 5,732 player-squad entries. Real player names, positions and nationalities are imported. The refreshed database also includes verified ages for 4,870 of the 5,732 player-squad entries (birth date known to day); ages without a precise birth date are simulated. Ratings, potential, wages and market value are simulated by the game.
- Where the upstream dataset does not publish complete squads (Serie C, English League One/Two and French Ligue 3), the game uses verified club lists and generated players, visibly labelled as generated.
- Every player card has a unique generated avatar. These are stylized avatars, not photographs or likenesses of real footballers.
- Full season fixture generation, league standings, matchday simulation and season history.
- Headless regression smoke test runs before every Android export, covering real squad import, match reports, UEFA progression, tactical lineup swaps, facility upgrades and promotion.
- User-club and AI-club promotion/relegation within the selected country's pyramid, with generic end-of-season promotion playoffs.
- Playable national cup prototype and playable UEFA Champions League, Europa League and Conference League simulations. UEFA competitions use two groups of four, semifinals and a final; qualification is based on domestic results or the cup.
- Match report with a 1–90 minute commentary timeline, goals, cards, substitutions and player ratings. Substitution timing can be set to early, balanced or late.
- Interactive tactical pitch: drag a player marker to another position to swap the two starters; formation and lineup are saved.
- Tactical instructions influence team strength.
- Transfer market mixes imported real players from the bundled database with generated prospects; filters cover real players, U21 players, bargains and high-rated players. Offers use fee, wage, role and club prestige.
- Loans, contract renewals, contract expiry and weekly wage accounting.
- Youth academy, generated prospects, player promotion and staff upgrades.
- Club management: sponsor contracts, board objectives, confidence and upgradeable training, stadium, medical and academy facilities.
- Player statistics, fitness, morale, injuries, suspensions and local save/load.

## Real data coverage and attribution

The bundled roster file is built by `scripts/import_openfootballbase.py` from the latest OpenFootballBase-Data release:
- https://github.com/florentfougeres/OpenFootballBase-Data
- Squads are based on Wikipedia (CC BY-SA 4.0) and Wikidata (CC0). The upstream release includes source page and revision metadata.
- The roster refresh workflow runs weekly and can also be started manually from GitHub Actions.
- The upstream dataset does not provide complete squads for every selectable third-tier competition. The game never labels generated players as real players.
- Player portraits are generated illustrations; no player photos or club marks are bundled.

## Current limitations / next development

- The match engine is a career simulation, not a live-data or physically simulated football engine. Minute commentary is generated from match events.
- Promotion/playoff rules are generic and not yet an exact reproduction of every country's regulations.
- Full real-player rosters are currently available for the 10 imported top/second-tier competitions only. Lower-tier players remain generated until a suitable open and verifiable roster source is available.
- Real-player ages, attributes, contracts, salaries, market values, injuries and historical statistics are not included in the imported source and are simulated.
- UEFA competitions are game simulations with simplified qualification and tournament formats, not a full UEFA coefficient/registration model.
- Generated player portraits are not realistic photos.

## Run locally

Open the repository folder in Godot 4.4.1 and press Play.

## Android

GitHub Actions exports a debug APK. A successful workflow run verifies the export, but installation and gameplay still need to be tested on a physical Android device.

Package: `com.chat60216.footballdynasty`
