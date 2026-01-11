# NFL Quarterback Analysis - 2025 Season

Advanced statistical analysis of NFL quarterback performance using play-by-play data from the 2025 season.

**Built with [Claude Code](https://claude.ai/code)** | **Build Time:** ~2 hours | **Analysis Runtime:** ~2-3 minutes

## Overview

This project analyzes 46 starting quarterbacks (100+ attempts) using advanced metrics including:
- **EPA (Expected Points Added)** - Value added per play
- **CPOE (Completion % Over Expected)** - Difficulty-adjusted accuracy
- **Success Rate** - Play-to-play effectiveness
- **Deep Ball Metrics** - Performance on 20+ yard throws
- **Air Yards** - Downfield aggression

## Key Findings

### Top Performers
1. **Drake Maye (NE)** - 0.298 EPA/play, #1 in all efficiency metrics
2. **Jordan Love (GB)** - 0.239 EPA/play, strong second season
3. **Matthew Stafford (LA)** - 0.227 EPA/play, elite volume deep-ball passer

### Notable Insights
- Drake Maye leads the NFL with historic 50% deep ball completion rate
- Matthew Stafford dominates deep passing with 1,257 yards on 90 attempts (#1)
- Average EPA per play: -0.007 (slightly negative league-wide)
- Deep ball completion average: 35% (elite QBs exceed 43%)

## Quick Start

See [QUICKSTART.md](QUICKSTART.md) for a 5-minute guide to running the analysis.

## Project Structure

```
NFL_R/
├── scripts/                      # R analysis scripts
│   ├── analyze_qbs.R            # ⭐ Main analysis script (start here)
│   ├── maye_analysis.R          # Drake Maye deep dive
│   ├── stafford_analysis.R      # Matthew Stafford analysis
│   └── generate_report.R        # HTML report generator
├── output/                       # Generated data and reports
│   ├── qb_stats_2025.csv        # Complete QB statistics (CSV)
│   └── QB_Report_2025.html      # 📊 Interactive HTML report
├── plots/                        # Generated visualizations (8 PNG files)
│   ├── 01_top_qbs_epa.png
│   ├── 02_comp_vs_epa.png
│   ├── 03_success_vs_cpoe.png
│   ├── 04-08_*.png              # Individual QB analysis plots
├── docs/                         # Documentation and presentations
│   ├── QB_Analysis_2025.md      # 📄 Full written analysis
│   ├── slides.md                # Slidev presentation
│   └── package.json             # Slidev dependencies
├── README.md                     # This file
├── QUICKSTART.md                 # ⚡ Quick start guide
├── LICENSE                       # MIT License
└── .gitignore                    # Git ignore rules
```

## Installation

### Prerequisites
- R (version 4.0+)
- RStudio (recommended)

### Required R Packages
```r
install.packages("pacman")
pacman::p_load(dplyr, ggplot2, tidyr, nflreadr)
```

## Usage

### Run Complete Analysis
```r
source("scripts/analyze_qbs.R")
```

This will:
1. Load 2025 NFL play-by-play data
2. Calculate QB statistics for all qualifying players
3. Generate 5 visualizations in the `plots/` directory
4. Export data to `output/qb_stats_2025.csv`
5. Print summary statistics to console

### View Results

**HTML Report**: Open `output/QB_Report_2025.html` in any browser for an interactive report with embedded visualizations.

**Markdown Summary**: Read `docs/QB_Analysis_2025.md` for the complete written analysis.

**Presentation**: Use Slidev to view `docs/slides.md`:
```bash
cd docs
npm install
npm run dev
```

## Data Source

Data is sourced from the [nflreadr](https://nflreadr.nflverse.com/) R package, which provides official NFL play-by-play data.

## Metrics Explained

### EPA (Expected Points Added)
Measures the value a play adds relative to the expected outcome. Positive EPA indicates above-average performance.

### CPOE (Completion Percentage Over Expected)
Accounts for throw difficulty (distance, pressure, coverage). Shows QB accuracy independent of scheme.

### Success Rate
Binary measure: percentage of plays that maintain or improve down-and-distance situation.

### Air Yards
Distance the ball travels in the air from line of scrimmage to target. Measures downfield aggression.

### Deep Ball Stats
Performance on throws with 20+ air yards. Elite QBs complete 43%+ of deep attempts.

## Key Visualizations

1. **Top 15 QBs by EPA** - Bar chart ranking efficiency leaders
2. **Completion % vs EPA** - Scatter plot showing accuracy doesn't always equal efficiency
3. **Success Rate vs CPOE** - Four-quadrant analysis of QBs
4. **Air Yards vs EPA** - Aggression vs efficiency trade-offs
5. **Deep Ball Performance** - Volume vs accuracy on deep throws

## Analysis Highlights

### Drake Maye - Most Efficient QB
- **#1 EPA/play (0.298)** - 25% better than #2
- **#1 Success Rate (54.4%)** - 10.3% above league average
- **50% deep ball completion** - Historic accuracy on high volume
- **#1 among young QBs** - 3.3x better EPA than 2nd-best rookie/sophomore

### Matthew Stafford - Deep Ball King
- **#1 in deep yards (1,257)** - 164 yards ahead of #2
- **90 deep attempts** - Most aggressive downfield passer
- **43.3% deep completion** - Elite accuracy on volume
- **#3 EPA/play (0.227)** - Maintains efficiency despite aggression

## Contributing

This is an analysis project. Feel free to fork and extend the analysis with additional metrics or seasons.

## License

MIT License - Feel free to use and modify for your own analysis.

## Author

Created using R, nflreadr, dplyr, and ggplot2.

## Acknowledgments

- [nflverse](https://www.nflverse.com/) for the excellent nflreadr package
- NFL for publicly available play-by-play data
- R community for statistical tools

## Contact

For questions or suggestions, please open an issue on GitHub.

---

**Last Updated**: January 2026
**Season Analyzed**: 2025 NFL Regular Season
**QBs Analyzed**: 46 (minimum 100 attempts)
