# Power Query (M) Cleaning Steps

Three CSVs exported by `R/01_download_data.R` (`plays.csv`, `games.csv`, `teams.csv`) are loaded into Power Query with data type detection based on the entire data set.

## `plays`
- Loaded from `plays.csv` (26,071 rows, 33 columns through Week 10).
- **Filtered to scrimmage plays:** `play_type` = `pass` or `run` → 18,328 rows.
  ```m
  Table.SelectRows(#"Changed column type", each ([play_type] = "pass" or [play_type] = "run"))
  ```
  This removes kickoffs, punts, field goals, extra points, `no_play` (penalties), QB kneels, spikes, and non-play rows (timeouts, end of quarter).

## `teams`
- Loaded from `teams.csv`. The header row initially loaded as data (33 rows); fixed with **Use first row as headers** → 32 rows.

## `games`
- Loaded from `games.csv` (all 272 regular-season games, including unplayed games with blank scores so the model works after each weekly refresh).

## `team_games` (reference of `games`)
Reshapes the schedule from one row per game (home team's view) into one row per team per game, which makes win %, point differential, and Pythagorean wins simple to calculate. Built with **Reference** (not Duplicate) so it stays linked to `games`.

```m
let
    // 1. Start from the games query, keep only games that have been played
    Source = games,
    Played = Table.SelectRows(Source, each [home_score] <> null),

    // 2. HOME version: the home team is "team"
    Home = Table.SelectColumns(Played, {"game_id", "season", "week", "gameday",
                                        "home_team", "away_team", "home_score", "away_score"}),
    HomeRenamed = Table.RenameColumns(Home, {
        {"home_team", "team"}, {"away_team", "opponent"},
        {"home_score", "points_for"}, {"away_score", "points_against"}}),
    HomeFlag = Table.AddColumn(HomeRenamed, "is_home", each 1, Int64.Type),

    // 3. AWAY version: the away team is "team"
    Away = Table.SelectColumns(Played, {"game_id", "season", "week", "gameday",
                                        "home_team", "away_team", "home_score", "away_score"}),
    AwayRenamed = Table.RenameColumns(Away, {
        {"away_team", "team"}, {"home_team", "opponent"},
        {"away_score", "points_for"}, {"home_score", "points_against"}}),
    AwayFlag = Table.AddColumn(AwayRenamed, "is_home", each 0, Int64.Type),

    // 4. Stack the two versions on top of each other
    Combined = Table.Combine({HomeFlag, AwayFlag}),

    // 5. Add the result columns
    AddDiff = Table.AddColumn(Combined, "point_diff",
                  each [points_for] - [points_against], Int64.Type),
    AddWin  = Table.AddColumn(AddDiff, "win",
                  each if [points_for] > [points_against] then 1
                       else if [points_for] = [points_against] then 0.5
                       else 0, type number),

    // 6. Make sure the score columns are whole numbers
    Typed = Table.TransformColumnTypes(AddWin, {
        {"points_for", Int64.Type}, {"points_against", Int64.Type}})
in
    Typed
```
Result: 298 rows (149 played games × 2 teams).

## Validation checks
- Header and row counts checked after each load.
- Every `posteam` code in `plays` matches a `team_abbr` in `teams` (checked in R with `setdiff()`).
- Core measures (EPA/play, success rate, Net EPA, record, Pythagorean wins, situational stats) were cross-checked against an independent Python calculation on the same data — exact match.
