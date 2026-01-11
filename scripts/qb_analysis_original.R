# NFL Quarterback Performance Analysis - 2025 Season
# Using nflreadr package

pacman::p_load(dplyr, ggplot2, forcats, tidyr, nflreadr)

# Load data
player_data <- nflreadr::load_players()
team_data <- nflreadr::load_teams()
pbp_data <- nflreadr::load_pbp(seasons = 2025)

# Set up team colors
color.teams <- select(team_data, values = team_color, breaks = team_abbr)
sfm <- function(color.df) {
  scale_fill_manual(breaks = color.df$breaks, values = color.df$values)
}

# Filter for quarterback stats from 2025 season
qb_stats <- pbp_data %>%
  filter(season_type == "REG", !is.na(passer_player_id)) %>%
  group_by(passer_player_id, passer_player_name, posteam) %>%
  summarise(
    # Basic passing stats
    attempts = n(),
    completions = sum(complete_pass, na.rm = TRUE),
    yards = sum(passing_yards, na.rm = TRUE),
    touchdowns = sum(touchdown == 1 & pass_attempt == 1, na.rm = TRUE),
    interceptions = sum(interception, na.rm = TRUE),
    sacks = sum(sack, na.rm = TRUE),

    # Advanced metrics
    epa_per_play = mean(epa, na.rm = TRUE),
    success_rate = mean(success, na.rm = TRUE),
    cpoe = mean(cpoe, na.rm = TRUE),
    air_yards = mean(air_yards, na.rm = TRUE),
    yac = sum(yards_after_catch, na.rm = TRUE),

    # Pressure stats
    times_hit = sum(qb_hit, na.rm = TRUE),
    scrambles = sum(qb_scramble, na.rm = TRUE),

    .groups = "drop"
  ) %>%
  mutate(
    completion_pct = (completions / attempts) * 100,
    yards_per_attempt = yards / attempts,
    td_rate = (touchdowns / attempts) * 100,
    int_rate = (interceptions / attempts) * 100,
    td_int_ratio = touchdowns / pmax(interceptions, 1)
  ) %>%
  # Filter for starters (minimum 100 attempts)
  filter(attempts >= 100) %>%
  arrange(desc(epa_per_play))

# Join with team data for colors
qb_stats <- qb_stats %>%
  left_join(team_data, by = c("posteam" = "team_abbr"))

# Display top performers
cat("\n=== Top 10 QBs by EPA per Play ===\n")
print(qb_stats %>%
        select(passer_player_name, posteam, attempts, epa_per_play, success_rate, completion_pct) %>%
        head(10))

# ===== VISUALIZATIONS =====

# 1. EPA per Play by QB
ggplot(head(qb_stats, 15),
       aes(x = reorder(passer_player_name, epa_per_play),
           y = epa_per_play,
           fill = posteam)) +
  geom_col() +
  coord_flip() +
  sfm(color.teams) +
  theme_minimal() +
  labs(
    title = "Top 15 QBs by EPA per Play - 2025 Season",
    subtitle = "Minimum 100 attempts",
    x = "",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    legend.position = "none"
  )

# 2. Completion % vs EPA per Play scatter
ggplot(qb_stats, aes(x = completion_pct, y = epa_per_play, color = posteam)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text(
    data = filter(qb_stats, epa_per_play > 0.15 | completion_pct > 70),
    aes(label = passer_player_name),
    hjust = -0.1, size = 3
  ) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "QB Completion % vs EPA per Play - 2025 Season",
    x = "Completion %",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

# 3. Yards vs Touchdowns
ggplot(qb_stats, aes(x = yards, y = touchdowns, color = posteam, size = epa_per_play)) +
  geom_point(alpha = 0.7) +
  geom_text(
    data = filter(qb_stats, touchdowns > quantile(qb_stats$touchdowns, 0.75)),
    aes(label = passer_player_name),
    hjust = -0.1, size = 3, show.legend = FALSE
  ) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "QB Passing Yards vs Touchdowns - 2025 Season",
    x = "Passing Yards",
    y = "Touchdowns",
    size = "EPA/Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "right"
  )

# 4. Success Rate vs CPOE
ggplot(qb_stats, aes(x = cpoe * 100, y = success_rate * 100, color = posteam)) +
  geom_point(size = 3, alpha = 0.7) +
  geom_hline(yintercept = mean(qb_stats$success_rate * 100),
             linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = mean(qb_stats$cpoe * 100, na.rm = TRUE),
             linetype = "dashed", alpha = 0.5) +
  geom_text(
    data = filter(qb_stats, success_rate > 0.50 | cpoe > 0.03),
    aes(label = passer_player_name),
    hjust = -0.1, size = 3
  ) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "QB Success Rate vs Completion % Over Expected - 2025",
    x = "CPOE (%)",
    y = "Success Rate (%)"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

# 5. TD to INT Ratio
qb_stats_td_int <- qb_stats %>%
  filter(interceptions > 0) %>%
  arrange(desc(td_int_ratio))

ggplot(head(qb_stats_td_int, 15),
       aes(x = reorder(passer_player_name, td_int_ratio),
           y = td_int_ratio,
           fill = posteam)) +
  geom_col() +
  coord_flip() +
  sfm(color.teams) +
  theme_minimal() +
  labs(
    title = "Top 15 QBs by TD:INT Ratio - 2025 Season",
    x = "",
    y = "TD:INT Ratio"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

# ===== SUMMARY STATISTICS =====
cat("\n=== Summary Statistics for Starting QBs ===\n")
cat(sprintf("Total QBs analyzed: %d\n", nrow(qb_stats)))
cat(sprintf("Average EPA per play: %.3f\n", mean(qb_stats$epa_per_play)))
cat(sprintf("Average completion %%: %.1f%%\n", mean(qb_stats$completion_pct)))
cat(sprintf("Average yards per attempt: %.2f\n", mean(qb_stats$yards_per_attempt)))
cat(sprintf("Average TD rate: %.2f%%\n", mean(qb_stats$td_rate)))
cat(sprintf("Average INT rate: %.2f%%\n", mean(qb_stats$int_rate)))

# Export data
write.csv(qb_stats, "qb_stats_2025.csv", row.names = FALSE)
cat("\nData exported to qb_stats_2025.csv\n")
