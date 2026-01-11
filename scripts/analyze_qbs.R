#!/usr/bin/env Rscript
# NFL QB Analysis - 2025 Season
# Main analysis script

# Load packages
pacman::p_load(dplyr, ggplot2, tidyr, nflreadr)

# Configuration
SEASON <- 2025
MIN_ATTEMPTS <- 100
OUTPUT_DIR <- "output"
PLOTS_DIR <- "plots"

# Create output directories
dir.create(OUTPUT_DIR, showWarnings = FALSE)
dir.create(PLOTS_DIR, showWarnings = FALSE)

cat("Loading NFL data for", SEASON, "season...\n")

# Load data
pbp_data <- nflreadr::load_pbp(seasons = SEASON)
team_data <- nflreadr::load_teams()

# Helper functions
get_team_colors <- function(team_data) {
  select(team_data, values = team_color, breaks = team_abbr)
}

scale_fill_teams <- function(color_df) {
  scale_fill_manual(breaks = color_df$breaks, values = color_df$values)
}

scale_color_teams <- function(color_df) {
  scale_color_manual(breaks = color_df$breaks, values = color_df$values)
}

# Calculate QB statistics
calculate_qb_stats <- function(pbp_data, min_attempts = MIN_ATTEMPTS) {
  pbp_data %>%
    filter(season_type == "REG", !is.na(passer_player_id)) %>%
    group_by(passer_player_id, passer_player_name, posteam) %>%
    summarise(
      # Basic stats
      attempts = n(),
      completions = sum(complete_pass, na.rm = TRUE),
      yards = sum(passing_yards, na.rm = TRUE),
      touchdowns = sum(touchdown == 1 & pass_attempt == 1, na.rm = TRUE),
      interceptions = sum(interception, na.rm = TRUE),

      # Advanced metrics
      epa_per_play = mean(epa, na.rm = TRUE),
      success_rate = mean(success, na.rm = TRUE),
      cpoe = mean(cpoe, na.rm = TRUE),
      air_yards_per_att = mean(air_yards, na.rm = TRUE),
      yac_per_comp = sum(yards_after_catch, na.rm = TRUE) / sum(complete_pass, na.rm = TRUE),

      # Situational
      third_down_success = sum(success[down == 3], na.rm = TRUE) / sum(down == 3, na.rm = TRUE),

      # Deep ball (20+ air yards)
      deep_att = sum(air_yards >= 20, na.rm = TRUE),
      deep_comp = sum(complete_pass[air_yards >= 20], na.rm = TRUE),
      deep_yards = sum(passing_yards[air_yards >= 20], na.rm = TRUE),
      deep_td = sum(touchdown[air_yards >= 20], na.rm = TRUE),

      # Explosive plays
      explosive_passes = sum(passing_yards >= 20, na.rm = TRUE),

      .groups = "drop"
    ) %>%
    filter(attempts >= min_attempts) %>%
    mutate(
      completion_pct = (completions / attempts) * 100,
      yards_per_attempt = yards / attempts,
      deep_comp_pct = (deep_comp / deep_att) * 100,
      td_int_ratio = touchdowns / pmax(interceptions, 1),
      explosive_rate = (explosive_passes / attempts) * 100
    )
}

# Generate visualizations
create_plots <- function(qb_stats, team_colors, output_dir = PLOTS_DIR) {

  # 1. Top QBs by EPA
  p1 <- ggplot(head(qb_stats %>% arrange(desc(epa_per_play)), 15),
               aes(x = reorder(passer_player_name, epa_per_play), y = epa_per_play, fill = posteam)) +
    geom_col() +
    coord_flip() +
    scale_fill_teams(team_colors) +
    theme_minimal() +
    labs(title = "Top 15 QBs by EPA per Play - 2025 Season", x = "", y = "EPA per Play") +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14), legend.position = "none")

  ggsave(file.path(output_dir, "01_top_qbs_epa.png"), p1, width = 10, height = 8, dpi = 300)

  # 2. Completion % vs EPA
  p2 <- ggplot(qb_stats, aes(x = completion_pct, y = epa_per_play, color = posteam)) +
    geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.3) +
    geom_point(size = 3, alpha = 0.7) +
    geom_text(data = filter(qb_stats, epa_per_play > 0.15 | completion_pct > 67),
              aes(label = passer_player_name), hjust = -0.1, size = 3, show.legend = FALSE) +
    scale_color_teams(team_colors) +
    scale_x_continuous(expand = expansion(mult = c(0.05, 0.15))) +
    scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
    theme_minimal() +
    labs(title = "Completion % vs EPA per Play", x = "Completion %", y = "EPA per Play") +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          legend.position = "none",
          plot.margin = margin(10, 20, 10, 10))

  ggsave(file.path(output_dir, "02_comp_vs_epa.png"), p2, width = 10, height = 8, dpi = 300)

  # 3. Success Rate vs CPOE
  p3 <- ggplot(qb_stats, aes(x = cpoe * 100, y = success_rate * 100, color = posteam)) +
    geom_hline(yintercept = mean(qb_stats$success_rate * 100), linetype = "dashed", alpha = 0.5) +
    geom_vline(xintercept = mean(qb_stats$cpoe * 100, na.rm = TRUE), linetype = "dashed", alpha = 0.5) +
    geom_point(size = 3, alpha = 0.7) +
    geom_text(data = filter(qb_stats, success_rate > 0.50 | cpoe > 5),
              aes(label = passer_player_name), hjust = -0.1, size = 3, show.legend = FALSE) +
    scale_color_teams(team_colors) +
    scale_x_continuous(expand = expansion(mult = c(0.1, 0.15))) +
    scale_y_continuous(expand = expansion(mult = c(0.05, 0.1))) +
    theme_minimal() +
    labs(title = "Success Rate vs CPOE", x = "CPOE (%)", y = "Success Rate (%)") +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          legend.position = "none",
          plot.margin = margin(10, 20, 10, 10))

  ggsave(file.path(output_dir, "03_success_vs_cpoe.png"), p3, width = 10, height = 8, dpi = 300)

  # 4. Air Yards vs EPA
  p4 <- ggplot(qb_stats, aes(x = air_yards_per_att, y = epa_per_play, color = posteam)) +
    geom_hline(yintercept = mean(qb_stats$epa_per_play), linetype = "dashed", alpha = 0.5) +
    geom_vline(xintercept = mean(qb_stats$air_yards_per_att), linetype = "dashed", alpha = 0.5) +
    geom_point(size = 3, alpha = 0.7) +
    geom_text(data = filter(qb_stats, epa_per_play > 0.20 | air_yards_per_att > 9),
              aes(label = passer_player_name), hjust = -0.1, size = 3, show.legend = FALSE) +
    scale_color_teams(team_colors) +
    scale_x_continuous(expand = expansion(mult = c(0.05, 0.15))) +
    scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
    theme_minimal() +
    labs(title = "Air Yards vs EPA - Efficiency + Aggression", x = "Air Yards per Attempt", y = "EPA per Play") +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          legend.position = "none",
          plot.margin = margin(10, 20, 10, 10))

  ggsave(file.path(output_dir, "04_air_yards_epa.png"), p4, width = 10, height = 8, dpi = 300)

  # 5. Deep Ball Analysis
  qb_deep <- qb_stats %>% filter(deep_att >= 20)
  p5 <- ggplot(qb_deep, aes(x = deep_att, y = deep_comp_pct, color = posteam, size = deep_yards)) +
    geom_hline(yintercept = mean(qb_deep$deep_comp_pct, na.rm = TRUE), linetype = "dashed", alpha = 0.5) +
    geom_point(alpha = 0.7) +
    geom_text(data = filter(qb_deep, deep_comp_pct > 45 | deep_att > 80),
              aes(label = passer_player_name), hjust = -0.1, size = 3, show.legend = FALSE) +
    scale_color_teams(team_colors) +
    scale_x_continuous(expand = expansion(mult = c(0.05, 0.15))) +
    scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
    theme_minimal() +
    labs(title = "Deep Ball Performance (20+ yards)", subtitle = "Size = Total Deep Yards",
         x = "Deep Attempts", y = "Deep Completion %", size = "Deep Yards") +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          plot.subtitle = element_text(hjust = 0.5),
          plot.margin = margin(10, 20, 10, 10))

  ggsave(file.path(output_dir, "05_deep_ball.png"), p5, width = 10, height = 8, dpi = 300)

  cat("Generated 5 visualizations in", output_dir, "\n")
}

# Print summary statistics
print_summary <- function(qb_stats) {
  cat("\n=== QB ANALYSIS SUMMARY ===\n")
  cat(sprintf("Total QBs analyzed: %d\n", nrow(qb_stats)))
  cat(sprintf("Average EPA per play: %.3f\n", mean(qb_stats$epa_per_play)))
  cat(sprintf("Average completion %%: %.1f%%\n", mean(qb_stats$completion_pct)))
  cat(sprintf("Average yards per attempt: %.2f\n", mean(qb_stats$yards_per_attempt)))

  cat("\n=== TOP 10 QBs BY EPA ===\n")
  print(qb_stats %>%
          arrange(desc(epa_per_play)) %>%
          select(passer_player_name, posteam, epa_per_play, success_rate, completion_pct) %>%
          head(10))

  cat("\n=== TOP 5 DEEP BALL LEADERS ===\n")
  print(qb_stats %>%
          arrange(desc(deep_yards)) %>%
          select(passer_player_name, posteam, deep_att, deep_yards, deep_comp_pct) %>%
          head(5))
}

# Main execution
main <- function() {
  cat("\n=== NFL QB Analysis", SEASON, "===\n\n")

  # Calculate stats
  qb_stats <- calculate_qb_stats(pbp_data)
  qb_stats <- qb_stats %>% left_join(team_data, by = c("posteam" = "team_abbr"))

  # Get team colors
  team_colors <- get_team_colors(team_data)

  # Generate plots
  create_plots(qb_stats, team_colors)

  # Print summary
  print_summary(qb_stats)

  # Export data
  output_file <- file.path(OUTPUT_DIR, "qb_stats_2025.csv")
  write.csv(qb_stats, output_file, row.names = FALSE)
  cat("\nData exported to", output_file, "\n")

  cat("\n=== Analysis Complete ===\n")

  return(qb_stats)
}

# Run analysis
if (!interactive()) {
  qb_stats <- main()
}
