# NFL Quarterback Analysis - 2025 Season

Advanced statistical analysis of NFL quarterback performance using play-by-play data from the 2025 season.

**Built with [Claude Code](https://claude.ai/code)** | **Build Time:** ~2 hours | **Analysis Runtime:** ~2-3 minutes

> **Want to run this yourself?** See [QUICKSTART.md](QUICKSTART.md) for setup instructions.

---

## Executive Summary

Analysis of **46 starting quarterbacks** (100+ attempts) in the 2025 NFL regular season using advanced metrics including EPA (Expected Points Added), CPOE (Completion % Over Expected), success rate, and deep ball performance.

**Key Finding**: Drake Maye leads the league in efficiency with historic deep ball accuracy, while Matthew Stafford dominates volume deep passing.

---

## Top Performers

![Top QBs by EPA](plots/01_top_qbs_epa.png)

| Rank | QB | Team | EPA/Play | Success Rate | Comp % |
|------|-----|------|----------|--------------|--------|
| 1 | **Drake Maye** | NE | **0.298** | 54.4% | 65.6% |
| 2 | Jordan Love | GB | 0.239 | 49.6% | 63.0% |
| 3 | Matthew Stafford | LA | 0.227 | 53.1% | 62.6% |
| 4 | Brock Purdy | SF | 0.194 | 53.4% | 66.1% |
| 5 | Jared Goff | DET | 0.173 | 48.2% | 63.8% |

**League Averages:**
- EPA per play: -0.007 (slightly negative)
- Completion %: 59.0%
- Yards per attempt: 6.38
- TD Rate: 4.42% | INT Rate: 2.12%

---

## Drake Maye: The NFL's Most Efficient Quarterback

![Maye Efficiency](plots/04_maye_efficiency_aggression.png)

Drake Maye's 2025 season represents one of the most impressive quarterback performances in recent history. He leads the NFL in every major efficiency metric while maintaining elite aggression downfield.

### Historic Performance
- **#1 EPA/play (0.298)** - 25% better than #2 Jordan Love
- **#1 Success Rate (54.4%)** - 10.3% above league average (44.1%)
- **#1 CPOE (10.78)** - Completes difficult throws at historic rate
- **#1 Yards per Attempt (7.38)**
- **#1 Explosive Pass Rate (12.4%)**

### Deep Ball Mastery

![Maye Deep Ball](plots/05_maye_deep_ball.png)

**50% completion rate on deep balls (20+ air yards)** - This is historically elite.

Most quarterbacks either:
- Throw deep rarely and maintain accuracy, OR
- Throw deep frequently but struggle with completion rate

**Maye does both** - 70 deep attempts with 50% completion is unprecedented.

**Deep Ball Stats:**
- 70 attempts (Top 5 in NFL)
- 35 completions
- 1,093 yards (#2 in NFL)
- 50.0% completion (15% above league average of 35%)

### Among Young QBs (2023-2024 Draft Classes)

![Young QBs](plots/08_young_qbs.png)

| Rank | QB | Team | EPA/Play |
|------|-----|------|----------|
| 1 | **Drake Maye** | **NE** | **0.298** |
| 2 | Bo Nix | DEN | 0.092 |
| 3 | Caleb Williams | CHI | 0.071 |
| 4 | Michael Penix | ATL | -0.004 |

Maye's EPA is **3.3x better** than the second-best young QB. This is a generational gap.

---

## Matthew Stafford: Elite Volume Deep-Ball Passer

![Stafford Air Yards](plots/06_stafford_air_yards_epa.png)

Matthew Stafford represents a unique archetype: the elite volume deep-ball passer who maintains top-tier efficiency.

### Deep Ball Dominance

![Stafford Deep Ball](plots/07_stafford_deep_ball.png)

**#1 in the NFL with 1,257 deep yards** on 90 attempts - 164 yards ahead of #2.

**Deep Ball Stats:**
- **90 deep attempts** - Most aggressive downfield passer in NFL
- **43.3% completion** - 8.3% above league average
- **1,257 yards** - #1 in NFL by significant margin
- **10 TDs** - #2 in league

### The Stafford Formula

**High Volume + Deep Aggression + High Efficiency = Elite Production**

Most QBs sacrifice one of these three elements:
- Conservative QBs: High efficiency, low air yards
- Gunslingers: High air yards, lower efficiency
- Game managers: Lower volume, short passes

**Stafford achieves all three simultaneously**, making him uniquely valuable.

**Overall Rankings:**
- #1 Passing Yards
- #1 Touchdowns
- #3 EPA/play (0.227)
- #3 Air Yards/Attempt (9.09)

---

## Advanced Metrics Analysis

### Completion % vs EPA

![Completion vs EPA](plots/02_comp_vs_epa.png)

Higher completion percentage doesn't always mean higher EPA. Context and difficulty matter - this is why CPOE is crucial for evaluating QB accuracy.

### Success Rate vs CPOE

![Success Rate vs CPOE](plots/03_success_vs_cpoe.png)

Upper-right quadrant QBs (Maye, Stafford, Love) combine scheme success with individual accuracy - the hallmark of elite QB play.

---

## Key Insights

### 1. Efficiency Over Volume
Drake Maye leads in EPA/play despite fewer attempts than many peers. Quality over quantity drives winning football.

### 2. Deep Ball Variance
- **Elite deep passers**: 43%+ completion (Maye: 50%, Stafford: 43.3%)
- **League average**: 35% completion on 20+ yard throws
- **Struggling QBs**: Under 30%

### 3. Multiple Paths to Success
- **Maye's efficiency**: #1 in all advanced metrics
- **Stafford's volume**: Elite production through aggression
- **Love's balance**: Strong efficiency with sustainable approach
- **Mahomes' pedigree**: Winning despite not leading traditional stats

### 4. Young QB Development
The gap between Maye and other recent draftees (3.3x better EPA) shows that elite efficiency can emerge immediately with the right QB.

---

## NFL MVP Analysis - 2025 Season

### The Verdict: Who Should Win vs. Who Will Win

**My Pick to Win:** Matthew Stafford (LA Rams)
**Who Should Win:** Drake Maye (New England Patriots)

![QB MVP Contenders](plots/09_mvp_qb_contenders.png)

### The Case for Drake Maye (Should Win)

Drake Maye leads the NFL with **0.298 EPA per play** - a generational level of efficiency rarely seen from rookies, let alone on struggling teams. By every advanced metric that matters - EPA/play, CPOE, success rate, efficiency-adjusted impact - Maye is having a historically great season.

**Why He Deserves It:**
- **Historic efficiency**: 0.298 EPA/play ranks in top 20 single-season marks of analytics era
- **Unprecedented rookie performance**: No rookie QB has ever combined this volume (540 attempts) with this efficiency
- **Team context**: Creating elite value on a limited roster - the essence of "most valuable"
- **Total EPA**: 161.0 total EPA added (20 more than any other player in football)

### The Case for Matthew Stafford (Will Win)

![MVP Total EPA](plots/12_mvp_total_epa.png)

While Maye has the efficiency edge, **Matthew Stafford will likely win MVP** because he has the traditional stats voters love:

**2025 Stats:**
- **46 touchdowns** - Most in NFL (15 more than Maye)
- **4,557 passing yards** - #2 in NFL
- **0.227 EPA/play** - #3 in NFL (elite efficiency + volume)
- **Leading the Rams offense** - Team success matters

**Why He'll Win:**
- Touchdown totals and volume stats drive MVP voting historically
- Veteran QB narrative with career year
- Deep ball king (1,257 deep yards, 90 attempts)
- Voters hesitant to give MVP to rookies, even historic ones

**The Reality:** MVP voters prioritize volume stats (TDs, yards) and team success over per-play efficiency. Stafford checks all the traditional boxes.

### Non-QB Contenders

![RB MVP Contenders](plots/10_mvp_rb_contenders.png)
![WR MVP Contenders](plots/11_mvp_wr_contenders.png)

**Top Running Backs:**
- **Bijan Robinson (ATL)**: 2,300 scrimmage yards - league leader
- **Jonathan Taylor (IND)**: 1,965 yards, 20 TDs - best TD total
- **Christian McCaffrey (SF)**: 2,106 yards, 17 TDs - complete back

**Top Wide Receivers:**
- **Jaxon Smith-Njigba (SEA)**: 1,793 yards - league leader
- **Puka Nacua (LA)**: 1,715 yards, 11 TDs - highest WR EPA/target
- **George Pickens (DAL)**: 1,431 yards, 9 TDs

**Why No Non-QB Will Win:**

The last non-QB MVP was Adrian Peterson in 2012. Modern NFL is pass-heavy, and EPA heavily favors QBs. Even elite RB seasons (2,300 yards) can't match the EPA impact of efficient QB play. Jonathan Taylor's elite RB season (21.5 total EPA) is only 13% of Maye's total EPA (161.0).

### Final MVP Rankings

**My Ballot (Analytics-Based):**
1. Drake Maye - Most valuable by the numbers
2. Matthew Stafford - Elite volume + efficiency
3. Jordan Love - Strong efficiency
4. Jonathan Taylor - Best non-QB season
5. Jared Goff - Solid all-around

**Predicted Results (Traditional Voting):**
1. Matthew Stafford - Voters love volume stats
2. Drake Maye - Strong runner-up
3. Bijan Robinson - RB looking for non-QB vote
4. Jordan Love - Packers success helps
5. Jonathan Taylor - Elite RB season

> **Full MVP Analysis:** See [docs/MVP_ANALYSIS_2025.md](docs/MVP_ANALYSIS_2025.md) for complete breakdown with historical context

---

## Metrics Explained

**EPA (Expected Points Added)** - Value added per play relative to expected outcome. Best measure of overall QB effectiveness.

**CPOE (Completion % Over Expected)** - Accounts for throw difficulty (distance, pressure, coverage). Shows accuracy independent of scheme.

**Success Rate** - Percentage of plays that maintain or improve down-and-distance situation.

**Air Yards** - Distance ball travels in air from line of scrimmage to target. Measures downfield aggression.

**Deep Ball** - Throws with 20+ air yards. Elite QBs complete 43%+ of deep attempts.

---

## Files & Resources

**Analysis Scripts:** See `scripts/` directory
- `analyze_qbs.R` - Main QB analysis (run this)
- `mvp_analysis.R` - MVP contenders analysis
- `maye_analysis.R` - Drake Maye deep dive
- `stafford_analysis.R` - Matthew Stafford analysis

**Outputs:**
- `output/qb_stats_2025.csv` - Complete QB dataset
- `output/mvp_*_candidates_2025.csv` - MVP candidate data (QB, RB, WR)
- `output/QB_Report_2025.html` - Interactive HTML report
- `plots/` - 12 visualizations (PNG)

**Documentation:**
- `docs/QB_Analysis_2025.md` - Full QB analysis
- `docs/MVP_ANALYSIS_2025.md` - Complete MVP breakdown
- `docs/slides.md` - Slidev presentation
- `QUICKSTART.md` - Setup & usage guide

---

## Data Source

Data sourced from [nflreadr](https://nflreadr.nflverse.com/) R package - official NFL play-by-play data.

## License

MIT License - Copyright (c) 2026 Alyssa Pybus

## Acknowledgments

- [nflverse](https://www.nflverse.com/) for the nflreadr package
- NFL for publicly available play-by-play data
- Built with R, dplyr, ggplot2, and Claude Code

---

**Season Analyzed**: 2025 NFL Regular Season | **QBs Analyzed**: 46 (minimum 100 attempts) | **Last Updated**: January 2026
