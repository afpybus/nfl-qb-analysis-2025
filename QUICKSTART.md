# Quick Start Guide

Get the NFL QB Analysis running in 5 minutes.

## Prerequisites

- **R** (version 4.0+) - [Download here](https://www.r-project.org/)
- **RStudio** (recommended) - [Download here](https://posit.co/download/rstudio-desktop/)

## Installation & Setup

### Step 1: Install R Packages

Open R or RStudio and run:

```r
# Install pacman package manager
install.packages("pacman")

# Install all required packages
pacman::p_load(dplyr, ggplot2, tidyr, nflreadr)
```

### Step 2: Clone or Download Repository

```bash
# Using git
git clone https://github.com/afpybus/nfl-qb-analysis-2025.git
cd nfl-qb-analysis-2025

# OR download ZIP from GitHub and extract
```

## Running the Analysis

### Quick Run (Recommended)

```r
# From R or RStudio, navigate to project directory then:
source("scripts/analyze_qbs.R")
```

**What happens:**
1. Downloads 2025 NFL play-by-play data from nflreadr
2. Calculates stats for 46 qualifying quarterbacks
3. Generates 5 core visualizations
4. Exports data to `output/qb_stats_2025.csv`
5. Prints summary statistics to console

**Runtime:** 2-3 minutes (mostly data download time)

### Individual Analyses

For deeper dives on specific players:

```r
# Drake Maye analysis
source("scripts/maye_analysis.R")

# Matthew Stafford analysis
source("scripts/stafford_analysis.R")

# Generate HTML report
source("scripts/generate_report.R")
```

## Viewing Results

### Option 1: HTML Report (Best Experience)

Open `output/QB_Report_2025.html` in any web browser for the full interactive report with embedded visualizations.

### Option 2: Explore Data

- **CSV Data:** `output/qb_stats_2025.csv` - Open in Excel, R, or Python
- **Visualizations:** `plots/*.png` - 8 high-resolution charts
- **Written Analysis:** `docs/QB_Analysis_2025.md` - Complete markdown writeup

### Option 3: Slidev Presentation

```bash
cd docs
npm install
npm run dev
```

Open http://localhost:3030 in your browser for the interactive slide presentation.

## Generated Files

After running the analysis:

```
output/
├── qb_stats_2025.csv          # Complete dataset
└── QB_Report_2025.html        # Interactive report

plots/
├── 01_top_qbs_epa.png         # Top 15 by efficiency
├── 02_comp_vs_epa.png         # Completion vs EPA
├── 03_success_vs_cpoe.png     # Success vs accuracy
├── 04_maye_efficiency_aggression.png
├── 05_maye_deep_ball.png
├── 06_stafford_air_yards_epa.png
├── 07_stafford_deep_ball.png
└── 08_young_qbs.png
```

## Customization

### Analyze Different Season

Edit `scripts/analyze_qbs.R` line 6:

```r
SEASON <- 2024  # Change to any year with available data
```

### Adjust QB Threshold

Edit `scripts/analyze_qbs.R` line 7:

```r
MIN_ATTEMPTS <- 200  # Increase for smaller sample of QBs
```

### Modify Visualizations

All plotting code is in the `create_plots()` function in `analyze_qbs.R`. Easy to customize:
- Colors (uses NFL team colors by default)
- Labels and titles
- Plot types and layouts
- Which QBs to highlight

### Add New Metrics

The `calculate_qb_stats()` function in `analyze_qbs.R` contains all metric calculations. Add new metrics by:

1. Adding calculation in the `summarise()` block
2. Optionally creating new visualizations in `create_plots()`

## Troubleshooting

### Package Installation Errors

```r
# If pacman fails, install packages individually:
install.packages(c("dplyr", "ggplot2", "tidyr", "nflreadr"))
```

### Data Download Issues

**Error:** "Cannot download NFL data"
- Check internet connection
- nflreadr data is hosted by nflverse - may have temporary outages
- Try again in a few minutes

### Permission Errors

**Error:** "Cannot write to output/plots directory"
- Ensure you have write permissions in project directory
- On Windows, run RStudio as administrator if needed

### Missing Visualizations

If plots don't generate:
```r
# Check that directories exist
dir.create("plots", showWarnings = FALSE)
dir.create("output", showWarnings = FALSE)
```

## Project Structure

```
NFL_R/
├── scripts/           # R analysis code
│   ├── analyze_qbs.R            # Main script ⭐ START HERE
│   ├── maye_analysis.R          # Drake Maye deep dive
│   ├── stafford_analysis.R      # Stafford analysis
│   └── generate_report.R        # HTML report generator
├── output/            # Generated data & reports
├── plots/             # Generated visualizations
├── docs/              # Documentation
└── README.md          # Main project README
```

## Next Steps

1. **Explore the data:** Open `qb_stats_2025.csv` in your tool of choice
2. **Read the analysis:** Check out `docs/QB_Analysis_2025.md`
3. **Customize:** Modify scripts to focus on your favorite QBs
4. **Compare seasons:** Change `SEASON` variable and run again
5. **Extend:** Add new metrics or visualizations

## Advanced Usage

### Batch Process Multiple Seasons

```r
seasons <- 2020:2025
for (season in seasons) {
  SEASON <- season
  source("scripts/analyze_qbs.R")
  # Rename output files to include year
}
```

### Filter by Team

```r
# After loading qb_stats, filter by team
patriots_qbs <- qb_stats %>% filter(posteam == "NE")
```

### Custom Visualizations

```r
# Load the data
qb_stats <- read.csv("output/qb_stats_2025.csv")

# Create your own plots with ggplot2
library(ggplot2)
ggplot(qb_stats, aes(x = attempts, y = touchdowns)) +
  geom_point() +
  geom_smooth(method = "lm")
```

## Data Source

All data comes from [nflreadr](https://nflreadr.nflverse.com/), which provides official NFL play-by-play data. The data is freely available and maintained by the nflverse community.

**Available seasons:** 1999-present (depending on data availability)

## Getting Help

- **Documentation:** See main [README.md](README.md)
- **Code Comments:** All scripts have inline documentation
- **GitHub Issues:** Report bugs or request features
- **nflreadr Docs:** https://nflreadr.nflverse.com/

---

**Time to setup:** ~3 minutes
**Time to first results:** ~5 minutes total
**Time to understand project:** ~15 minutes with report review
