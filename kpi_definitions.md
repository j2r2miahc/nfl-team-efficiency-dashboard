# KPI Definitions

Main question: **Which NFL teams are truly efficient, and which teams' records don't match how well they play?**

All rates are per play or per game (not totals), because teams run different numbers of plays and have played different numbers of games.

## Core efficiency — how well a team plays

| KPI | Definition | Why it matters |
|---|---|---|
| **Offensive EPA/play** | Average Expected Points Added per offensive play (pass or run) | Best single measure of offensive quality. Judges each play in context: a 3-yard gain on 3rd & 2 is a success; on 3rd & 10 it's a failure. |
| **Defensive EPA/play allowed** | Average EPA of opponents' plays against the team (lower = better) | The same idea for defense. |
| **Net EPA/play** | Offensive EPA/play − defensive EPA/play allowed | One number for overall team strength. |
| **Success rate** | % of plays with EPA > 0 | Consistency. EPA rewards big plays; success rate shows how *often* a team moves forward. |
| **Pass vs. run EPA/play** | EPA/play split by play type, vs. league average | Shows *where* an offense gets its value. |

**EPA example:** 1st & 10 at your own 25 is worth about +1.0 expected points. A 20-yard completion to your own 45 makes it about +2.3, so that play's EPA is about +1.3.

## Situational — where games swing

| KPI | Definition | Why it matters / caveat |
|---|---|---|
| **3rd-down conversion %** | 3rd-down conversions ÷ 3rd-down attempts | Sustaining drives. Noisier than early-down EPA, since good early-down teams face easier 3rd downs. |
| **Red zone TD %** | Drives reaching the opponent's 20 that end in a TD ÷ all such drives | Turning drives into 7 points instead of 3. Small samples (~3 trips per game). |
| **Turnover margin per game** | (Takeaways − giveaways) ÷ games | Huge impact on games, but partly luck (fumble recoveries are close to a coin flip). |

## Results — what the record says

| KPI | Definition | Why it matters |
|---|---|---|
| **Win %** | Wins ÷ games (ties = 0.5) | The record side of the question. |
| **Point differential per game** | (Points for − points against) ÷ games | Predicts future wins better than the record does. |
| **Pythagorean expected wins** | Games × PF^2.37 ÷ (PF^2.37 + PA^2.37) | Wins a team "should" have based on its scoring. |
| **Win Gap** | Actual wins − expected wins | Positive = more wins than the scoring supports (often close-game luck). Negative = fewer. |
| **Record verdict** | Win Gap ≥ +1 → Overperforming; ≤ −1 → Underperforming; otherwise As expected | A plain-language label. "Overperforming" means lucky, not bad. |

## Display features (not KPIs)

- **League ranks** (1–32) for offensive, defensive, and net EPA, plus win %.
- **Rolling 4-week Net EPA** to smooth noisy single-week values into a trend.
- **Garbage-time toggle:** optionally excludes plays where the offense's win probability is below 10% or above 90%.
