#!/usr/bin/env python3
"""Build a compact Godot roster database from the latest OpenFootballBase release.

Source: OpenFootballBase-Data (Wikipedia CC BY-SA 4.0 + Wikidata CC0).
Only the selected 2026/27 men's squads for the game's supported leagues are exported.
"""
import json
from pathlib import Path
import duckdb

ROOT = Path(__file__).resolve().parents[1]
DATA = ROOT / "data"
SEASON = "2026/27"
COMPETITIONS = {
    "ENG-PL": ("Inghilterra", "Premier League"),
    "ENG-CH": ("Inghilterra", "Championship"),
    "ESP-LL": ("Spagna", "Liga 1"),
    "ESP-SD": ("Spagna", "Liga 2"),
    "ITA-SA": ("Italia", "Serie A"),
    "ITA-SB": ("Italia", "Serie B"),
    "DEU-BL": ("Germania", "Bundesliga 1"),
    "DEU-B2": ("Germania", "Bundesliga 2"),
    "FRA-L1": ("Francia", "Ligue 1"),
    "FRA-L2": ("Francia", "Ligue 2"),
}
def clean(v):
    return None if v is None else str(v).strip()

def main():
    squad_files = list((DATA / "squad").glob("2026-27*.parquet"))
    club_files = list((DATA / "club_season").glob("2026-27*.parquet"))
    if not squad_files or not club_files:
        raise SystemExit("OpenFootballBase 2026/27 parquet partitions not found")
    con = duckdb.connect()
    squad_path = str(DATA / "squad" / "2026-27*.parquet").replace("\\", "/")
    clubs_path = str(DATA / "club_season" / "2026-27*.parquet").replace("\\", "/")
    codes = ",".join("'" + c + "'" for c in COMPETITIONS)
    rows = con.execute(f"""
        SELECT s.competition, s.club, s.player, s.player_qid,
               s.shirt_number, s.position, s.nationality
        FROM read_parquet('{squad_path}') s
        WHERE s.season = '{SEASON}' AND s.competition IN ({codes})
        ORDER BY s.competition, s.club, s.shirt_number NULLS LAST, s.player
    """).fetchall()
    club_rows = con.execute(f"""
        SELECT competition, club FROM read_parquet('{clubs_path}')
        WHERE season = '{SEASON}' AND competition IN ({codes})
        ORDER BY competition, club
    """).fetchall()
    output = {
        "season": SEASON,
        "generated_at": __import__("datetime").datetime.now(__import__("datetime").timezone.utc).isoformat(),
        "source": "OpenFootballBase-Data release; Wikipedia CC BY-SA 4.0 / Wikidata CC0",
        "source_url": "https://github.com/florentfougeres/OpenFootballBase-Data",
        "competitions": {}
    }
    for code, (country, division) in COMPETITIONS.items():
        output["competitions"][code] = {
            "country": country, "division": division, "clubs": {}
        }
    for code, club in club_rows:
        if code in output["competitions"]:
            output["competitions"][code]["clubs"].setdefault(club, {"players": []})
    for code, club, player, qid, shirt, pos, nationality in rows:
        if code not in output["competitions"] or not clean(player):
            continue
        entry = output["competitions"][code]["clubs"].setdefault(club, {"players": []})
        entry["players"].append({
            "name": clean(player), "qid": clean(qid),
            "number": int(shirt) if shirt is not None else 0,
            "position": clean(pos) or "",
            "nationality": clean(nationality) or ""
        })
    for comp in output["competitions"].values():
        comp["club_count"] = len(comp["clubs"])
        comp["player_count"] = sum(len(c["players"]) for c in comp["clubs"].values())
    DATA.mkdir(exist_ok=True)
    out = DATA / "real_rosters.json"
    out.write_text(json.dumps(output, ensure_ascii=False, separators=(",", ":")), encoding="utf-8")
    print(f"Wrote {out}: {sum(c['club_count'] for c in output['competitions'].values())} clubs, "
          f"{sum(c['player_count'] for c in output['competitions'].values())} player entries")
    con.close()

if __name__ == "__main__":
    main()
