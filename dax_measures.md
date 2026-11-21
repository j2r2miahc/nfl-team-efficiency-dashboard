# DAX Measures

All measures from the NFL Team Efficiency Dashboard semantic model, grouped by display folder.

**Model summary:** fact tables `plays` (one row per scrimmage play) and `team_games` (one row per team per game); dimension tables `teams` and `games`; disconnected table `Play Filter` for the garbage-time toggle. `plays[posteam] → teams[team_abbr]` is the active relationship (offense); `plays[defteam] → teams[team_abbr]` is inactive (defense) and used via `USERELATIONSHIP`.

---

## Garbage-time toggle (calculated table)

```dax
Play Filter =
DATATABLE(
    "Mode", STRING,
    {
        { "All plays" },
        { "Exclude garbage time" }
    }
)
```
Disconnected table used as a slicer. Measures read the selection with `SELECTEDVALUE`.

---

## Efficiency (table: plays)

```dax
Plays =
VAR Mode = SELECTEDVALUE( 'Play Filter'[Mode], "All plays" )
RETURN
    IF(
        Mode = "Exclude garbage time",
        CALCULATE( COUNTROWS( plays ), plays[wp] >= 0.10 && plays[wp] <= 0.90 ),
        COUNTROWS( plays )
    )
```

```dax
EPA per Play =
VAR Mode = SELECTEDVALUE( 'Play Filter'[Mode], "All plays" )
RETURN
    IF(
        Mode = "Exclude garbage time",
        CALCULATE( AVERAGE( plays[epa] ), plays[wp] >= 0.10 && plays[wp] <= 0.90 ),
        AVERAGE( plays[epa] )
    )
```

```dax
Success Rate =
VAR Mode = SELECTEDVALUE( 'Play Filter'[Mode], "All plays" )
RETURN
    IF(
        Mode = "Exclude garbage time",
        CALCULATE( AVERAGE( plays[success] ), plays[wp] >= 0.10 && plays[wp] <= 0.90 ),
        AVERAGE( plays[success] )
    )
```

```dax
Def EPA per Play =
CALCULATE(
    [EPA per Play],
    USERELATIONSHIP( plays[defteam], teams[team_abbr] )
)
```

```dax
Net EPA per Play = [EPA per Play] - [Def EPA per Play]
```

---

## Record (table: team_games)

```dax
Games = COUNTROWS( team_games )
```

```dax
Wins = SUM( team_games[win] )
```
Ties are stored as 0.5 in `team_games[win]`.

```dax
Win % = DIVIDE( [Wins], [Games] )
```

```dax
Point Diff per Game = DIVIDE( SUM( team_games[point_diff] ), [Games] )
```

```dax
Pythag Win % =
VAR PointsFor     = SUM( team_games[points_for] )
VAR PointsAgainst = SUM( team_games[points_against] )
RETURN
    DIVIDE(
        PointsFor ^ 2.37,
        PointsFor ^ 2.37 + PointsAgainst ^ 2.37
    )
```

```dax
Expected Wins = [Pythag Win %] * [Games]
```

```dax
Win Gap = [Wins] - [Expected Wins]
```

---

## Situational (table: plays)

```dax
3rd Down Conv % =
VAR Converted = SUM( plays[third_down_converted] )
VAR Failed    = SUM( plays[third_down_failed] )
RETURN
    DIVIDE( Converted, Converted + Failed )
```

```dax
Red Zone Trips =
COUNTROWS(
    SUMMARIZE(
        FILTER( plays, plays[drive_inside20] = 1 ),
        plays[game_id],
        plays[fixed_drive]
    )
)
```
Collapses plays into unique drives (`game_id` + `fixed_drive`), since drive numbers restart every game.

```dax
Red Zone TDs =
COUNTROWS(
    SUMMARIZE(
        FILTER(
            plays,
            plays[drive_inside20] = 1
                && plays[fixed_drive_result] = "Touchdown"
        ),
        plays[game_id],
        plays[fixed_drive]
    )
)
```

```dax
Red Zone TD % = DIVIDE( [Red Zone TDs], [Red Zone Trips] )
```

```dax
Giveaways = SUM( plays[interception] ) + SUM( plays[fumble_lost] )
```

```dax
Takeaways =
CALCULATE(
    [Giveaways],
    USERELATIONSHIP( plays[defteam], teams[team_abbr] )
)
```

```dax
Turnover Margin per Game = DIVIDE( [Takeaways] - [Giveaways], [Games] )
```

---

## Rank & Trend (table: plays)

```dax
Off EPA Rank =
IF(
    HASONEVALUE( teams[team_abbr] ),
    RANKX( ALL( teams ), [EPA per Play], , DESC )
)
```

```dax
Def EPA Rank =
IF(
    HASONEVALUE( teams[team_abbr] ),
    RANKX( ALL( teams ), [Def EPA per Play], , ASC )
)
```
`ASC` because lower EPA allowed is better for a defense.

```dax
Net EPA Rank =
IF(
    HASONEVALUE( teams[team_abbr] ),
    RANKX( ALL( teams ), [Net EPA per Play], , DESC )
)
```

```dax
Win % Rank =
IF(
    HASONEVALUE( teams[team_abbr] ),
    RANKX( ALL( teams ), [Win %], , DESC )
)
```
`ALL( teams )` (not `ALL( teams[team_abbr] )`) so ranks stay correct when a visual groups by any `teams` column, such as team name.

```dax
Rolling 4 Wk Net EPA =
VAR CurrentWeek    = MAX( games[week] )
VAR LastPlayedWeek = CALCULATE( MAX( plays[week] ), ALL( plays ) )
RETURN
    IF(
        CurrentWeek <= LastPlayedWeek,
        CALCULATE(
            [Net EPA per Play],
            FILTER(
                ALL( games[week] ),
                games[week] > CurrentWeek - 4
                    && games[week] <= CurrentWeek
            )
        )
    )
```
Returns blank for weeks that haven't been played yet, so trend lines don't extend into the future.

---

## Display (cards and labels)

```dax
Record =
VAR W = CALCULATE( COUNTROWS( team_games ), team_games[win] = 1 ) + 0
VAR T = CALCULATE( COUNTROWS( team_games ), team_games[win] = 0.5 ) + 0
VAR L = [Games] - W - T
RETURN
    W & "–" & L & IF( T > 0, "–" & T )
```

```dax
Net EPA Display =
FORMAT( [Net EPA per Play], "+0.000;-0.000" ) & "   #" & [Net EPA Rank] & " of 32"
```

```dax
Off EPA Display =
FORMAT( [EPA per Play], "+0.000;-0.000" ) & "   #" & [Off EPA Rank] & " of 32"
```

```dax
Def EPA Display =
FORMAT( [Def EPA per Play], "+0.000;-0.000" ) & "   #" & [Def EPA Rank] & " of 32"
```

```dax
League EPA per Play = CALCULATE( [EPA per Play], ALL( teams ) )
```

```dax
Record Verdict =
SWITCH(
    TRUE(),
    [Win Gap] >= 1,  "Overperforming",
    [Win Gap] <= -1, "Underperforming",
    "As expected"
)
```
