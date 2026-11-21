# NFL Team Efficiency Dashboard (2026)

**Which NFL teams are truly efficient — and which teams' records don't match how well they play?**

A 4-page Power BI dashboard built on 18,000+ plays of 2026 NFL play-by-play data from [nflverse](https://github.com/nflverse). It compares how well teams actually play (EPA per play) with their win-loss records (Pythagorean expected wins) to separate legitimately good teams from lucky ones.

📄 **[View the full dashboard (PDF)](docs/NFL_Team_Efficiency_Dashboard.pdf)**

![League Overview](images/page1_league_overview.png)

---

## Key findings (through Week 10)

- **Jacksonville is the most efficient team in the NFL — and its 7–2 record is legit.** #1 in Net EPA/play (+0.279) with the league's best point differential (+13.9/game). Its passing offense produces 0.306 EPA/play vs. a league average of 0.023, and its 4-week rolling efficiency has climbed all season.
- **Denver's 7–2 record hides a league-average team.** Denver ranks 16th in Net EPA (−0.006) and its scoring supports only ~4.8 expected wins — the largest Win Gap in the league (+2.2). Its strengths are luck-prone (turnover margin +0.67/game, 63% red zone TD rate), while its most stable indicator is the worst in the NFL (32.7% on 3rd down).
- **Tampa Bay is unlucky, but not a hidden contender.** Despite a 3–6 record, Tampa Bay has outscored opponents (+2.7/game) and should have ~5.2 wins. But when garbage-time plays are excluded, it falls from 11th to 16th in efficiency — its elite defensive numbers were inflated by opponents passing desperately from behind. Verdict: an average team with a bad record.
- **"Overperforming" doesn't mean bad.** San Francisco and Buffalo both have more wins than their scoring predicts, but they rank 1st and 7th in efficiency. They're genuinely good teams that have also won extra close games.
- **Small samples mislead.** Philadelphia converts 72.7% of red zone trips into touchdowns (3rd best), but on only 22 trips — tied for the fewest — while ranking 31st in overall efficiency. Two field goals instead of touchdowns would make them average.

---

## Dashboard pages

| Page | Question it answers |
|---|---|
| **1. League Overview** | Who's efficient, and are they offense-led or defense-led? (quadrant scatter + ranked table) |
| **2. Team Deep Dive** | How good is one team, is it trending up or down, and where does its offense get its value? |
| **3. Situational** | Who wins the moments that swing games (3rd down, red zone, turnovers) — and how much is noise? |
| **4. Record vs. Efficiency** | Whose record doesn't match how they play? (Win Gap, verdicts, efficiency rank vs. record rank) |

A **"Plays included" toggle** lets viewers exclude garbage time (plays where either team's win probability is above 90%) to check whether a team's numbers hold up in competitive situations.

| | |
|---|---|
| ![Team Deep Dive](images/page2_team_deep_dive.png) | ![Situational](images/page3_situational.png) |
| ![Record vs. Efficiency](images/page4_record_vs_efficiency.png) | |

---

## Key metrics

| Metric | What it measures |
|---|---|
| **EPA/play** | Expected Points Added: how much each play changed a team's expected points, given down, distance, and field position |
| **Success rate** | % of plays with positive EPA (consistency) |
| **Net EPA/play** | Offensive EPA/play − defensive EPA/play allowed (overall team strength) |
| **Pythagorean expected wins** | Wins a team "should" have based on points scored and allowed (exponent 2.37) |
| **Win Gap** | Actual wins − expected wins (positive = lucky, negative = unlucky) |

Full definitions: [docs/kpi_definitions.md](docs/kpi_definitions.md)

---

## How it was built

```
nflverse (nflreadr in R)  →  CSVs  →  Power Query (cleaning)  →  Star schema  →  DAX measures  →  4 report pages
```

1. **Data extraction (R):** [`R/01_download_data.R`](R/01_download_data.R) pulls 2026 regular-season play-by-play, schedules, and team info with `nflreadr`, trims 372 columns to the 33 needed, validates that every team code matches across tables, and exports three CSVs.
2. **Cleaning (Power Query / M):** filtered to scrimmage plays (passes and runs — removing special teams, penalties, kneel-downs, and spikes), and reshaped the schedule from one row per game into one row per team per game. Details: [docs/power_query.md](docs/power_query.md)
3. **Data model:** star schema with two fact tables (`plays`, `team_games`) and two dimensions (`teams`, `games`). Because every play involves both an offense and a defense, `plays[posteam]` has an active relationship to `teams` and `plays[defteam]` an inactive one, switched on in DAX with `USERELATIONSHIP`.
4. **DAX:** 30 measures across efficiency, record, situational stats, league ranks, and rolling trends, organized into display folders. All core measures were validated against an independent Python calculation. Full code: [docs/dax_measures.md](docs/dax_measures.md)
5. **Report:** 4 pages designed around one question each, built in the Power BI service.

**Tools:** R (nflreadr, dplyr, readr) · Power BI (Power Query/M, DAX, data modeling) · Python (validation)

---

## Methodology decisions

- **Scrimmage plays only.** Kneel-downs have negative EPA and are mostly run by teams that are winning, so including them would penalize good teams.
- **Garbage time is a toggle, not a hard filter.** Removing plays permanently is a hidden decision; a toggle lets viewers see how much it matters (and it changed my conclusion about Tampa Bay).
- **Per-play and per-game rates, not totals,** because teams run different numbers of plays and have played different numbers of games.
- **Record verdict threshold of ±1 win** between actual and expected wins — a simple, explainable cutoff for "overperforming" or "underperforming."

## Limitations

- **Small samples:** 8–10 games per team, and only ~3 red zone trips per game. Rankings will shift as the season continues.
- **Turnover margin** counts scrimmage plays only, so rare special-teams fumbles are excluded.
- **The rolling trend** covers 4 *weeks*, not 4 *games*, so windows that include a bye week contain 3 games.
- **QB scrambles** are classified as runs in the pass vs. run split (nflverse `play_type`).
- **EPA** comes from the nflverse expected points model and inherits its assumptions.

## How to refresh

1. Run `R/01_download_data.R` to download the latest weeks.
2. Replace the three CSVs in the OneDrive folder the Power BI semantic model reads from.
3. Refresh the semantic model in the Power BI service. All measures, ranks, and verdicts update automatically.

---

**Author:** [Your name] · [LinkedIn] · Data: [nflverse](https://github.com/nflverse) via [nflreadr](https://nflreadr.nflverse.com/)
