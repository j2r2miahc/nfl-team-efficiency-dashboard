# =============================================================
# 01_download_data.R
# NFL Team Efficiency Dashboard — Step 2
# Downloads 2026 NFL data from nflverse and exports 3 CSVs
# for Power BI: plays (fact), games (dimension), teams (dimension)
# =============================================================

# Run this line ONCE to install the packages, then comment it out
# install.packages(c("nflreadr", "dplyr", "readr"))

library(nflreadr)   # downloads nflverse data
library(dplyr)      # filter / select / data wrangling
library(readr)      # fast, clean CSV export

SEASON <- 2026      # change this one number to rebuild for another season


# ---- 1. Play-by-play -> FACT table (one row per play) ----------
pbp_raw <- load_pbp(SEASON)

plays <- pbp_raw |>
  filter(season_type == "REG") |>          # regular season only
  select(
    # keys: link each play to a game and to teams
    game_id, play_id, season, week, game_date,
    posteam, defteam, home_team, away_team,
    # game situation
    qtr, down, ydstogo, yardline_100, wp,
    # drive info (needed for red zone TD %)
    fixed_drive, fixed_drive_result, drive_inside20,
    # what happened on the play
    play_type, pass, rush, epa, success, first_down,
    third_down_converted, third_down_failed,
    touchdown, td_team, interception, fumble_lost,
    qb_kneel, qb_spike, penalty,
    desc                                    # text description, great for spot-checking
  )


# ---- 2. Schedule -> GAMES dimension (one row per game) ---------
games <- load_schedules(SEASON) |>
  filter(game_type == "REG") |>
  select(game_id, season, week, gameday,
         home_team, away_team, home_score, away_score,
         result, overtime)
# Note: games not played yet have blank scores. We keep them so the
# dashboard works after each weekly refresh, and filter them in Power BI.


# ---- 3. Teams -> TEAMS dimension (one row per team) ------------
teams <- load_teams(current = TRUE) |>      # current = TRUE: 32 teams, no old OAK/SD/STL
  select(team_abbr, team_name, team_nick,
         team_conf, team_division,
         team_color, team_color2, team_logo_espn)


# ---- 4. Sanity checks (always look before you export) ---------
glimpse(plays)
cat("Plays:", nrow(plays),
    "| Games with plays:", n_distinct(plays$game_id),
    "| Through week:", max(plays$week), "\n")
cat("Games on schedule:", nrow(games), "| Teams:", nrow(teams), "\n")

# Every team abbreviation in plays must exist in teams (this matters in Step 4)
setdiff(unique(na.omit(plays$posteam)), teams$team_abbr)   # want: character(0)


# ---- 5. Export to CSV -----------------------------------------
dir.create("data", showWarnings = FALSE)
write_csv(plays, "data/plays.csv", na = "")   # na = "" -> Power BI reads blanks as null
write_csv(games, "data/games.csv", na = "")
write_csv(teams, "data/teams.csv", na = "")

cat("Done! CSVs saved in the data/ folder.\n")