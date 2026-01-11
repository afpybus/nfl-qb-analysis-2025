# Quick Start Guide

Get started with the NFL QB Analysis in 3 simple steps.

## Step 1: Install Dependencies

```r
# Install pacman if you don't have it
install.packages("pacman")

# Install required packages
pacman::p_load(dplyr, ggplot2, tidyr, nflreadr)
```

## Step 2: Run the Analysis

```r
# From R or RStudio
source("scripts/analyze_qbs.R")
```

This will:
- Download 2025 NFL play-by-play data
- Calculate statistics for 46 QBs
- Generate 5 visualizations
- Export data to CSV
- Print summary statistics

**Expected runtime**: 2-3 minutes

## Step 3: View Results

### Option A: HTML Report (Recommended)
Open `output/QB_Report_2025.html` in your browser for the full interactive report.

### Option B: Read the Analysis
Open `docs/QB_Analysis_2025.md` for the complete written analysis.

### Option C: View the Presentation
```bash
cd docs
npm install
npm run dev
```
Then open http://localhost:3030

## What You'll Get

### Generated Files

**In `output/`:**
- `qb_stats_2025.csv` - Complete QB statistics
- `QB_Report_2025.html` - Interactive HTML report

**In `plots/`:**
- `01_top_qbs_epa.png` - Top 15 QBs by efficiency
- `02_comp_vs_epa.png` - Completion % vs EPA scatter
- `03_success_vs_cpoe.png` - Success rate quadrant analysis
- `04_air_yards_epa.png` - Aggression vs efficiency
- `05_deep_ball.png` - Deep ball performance

## Customization

### Analyze Different Season
Edit `scripts/analyze_qbs.R`:
```r
SEASON <- 2024  # Change to desired year
```

### Change Minimum Attempts
```r
MIN_ATTEMPTS <- 200  # Increase for smaller sample
```

### Modify Visualizations
All plotting functions are in `create_plots()` function - easy to customize colors, labels, and styles.

## Troubleshooting

**Error: Package not found**
```r
install.packages("packagename")
```

**Error: Data download failed**
- Check internet connection
- nflreadr data is hosted by NFL - may have temporary outages

**Plots not generating**
- Ensure `plots/` directory exists
- Check write permissions

## Next Steps

1. Explore individual QB scripts in `scripts/`:
   - `maye_analysis.R` - Drake Maye deep dive
   - `stafford_analysis.R` - Matthew Stafford analysis

2. Modify visualizations to focus on specific QBs or metrics

3. Compare multiple seasons by running analysis for different years

## Need Help?

- Check the full [README.md](README.md) for detailed information
- Review the code comments in `scripts/analyze_qbs.R`
- Open an issue on GitHub

---

**Time to first results**: ~5 minutes
**Total project understanding**: ~15 minutes with report review
