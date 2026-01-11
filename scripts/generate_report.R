# Generate HTML Report with All QB Analysis Plots
pacman::p_load(dplyr, ggplot2, nflreadr, tidyr, htmltools)

# Create output directory for plots
dir.create("report_plots", showWarnings = FALSE)

# Load data
pbp_data <- nflreadr::load_pbp(seasons = 2025)
team_data <- nflreadr::load_teams()
player_data <- nflreadr::load_players()

# Calculate QB stats
qb_stats <- pbp_data %>%
  filter(season_type == "REG", !is.na(passer_player_id)) %>%
  group_by(passer_player_id, passer_player_name, posteam) %>%
  summarise(
    attempts = n(),
    completions = sum(complete_pass, na.rm = TRUE),
    yards = sum(passing_yards, na.rm = TRUE),
    touchdowns = sum(touchdown == 1 & pass_attempt == 1, na.rm = TRUE),
    interceptions = sum(interception, na.rm = TRUE),
    epa_per_play = mean(epa, na.rm = TRUE),
    success_rate = mean(success, na.rm = TRUE),
    cpoe = mean(cpoe, na.rm = TRUE),
    air_yards_per_att = mean(air_yards, na.rm = TRUE),
    yac_per_comp = sum(yards_after_catch, na.rm = TRUE) / sum(complete_pass, na.rm = TRUE),
    deep_att = sum(air_yards >= 20, na.rm = TRUE),
    deep_comp = sum(complete_pass[air_yards >= 20], na.rm = TRUE),
    deep_yards = sum(passing_yards[air_yards >= 20], na.rm = TRUE),
    deep_td = sum(touchdown[air_yards >= 20], na.rm = TRUE),
    explosive_passes = sum(passing_yards >= 20, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(attempts >= 100) %>%
  mutate(
    completion_pct = (completions / attempts) * 100,
    yards_per_attempt = yards / attempts,
    deep_comp_pct = (deep_comp / deep_att) * 100,
    td_int_ratio = touchdowns / pmax(interceptions, 1),
    explosive_rate = (explosive_passes / attempts) * 100
  ) %>%
  left_join(team_data, by = c("posteam" = "team_abbr"))

# Color setup
color.teams <- select(team_data, values = team_color, breaks = team_abbr)
sfm <- function(color.df) {
  scale_fill_manual(breaks = color.df$breaks, values = color.df$values)
}
scm <- function(color.df) {
  scale_color_manual(breaks = color.df$breaks, values = color.df$values)
}

# Get specific QBs
maye <- qb_stats %>% filter(passer_player_name == "D.Maye")
stafford <- qb_stats %>% filter(passer_player_name == "M.Stafford")

cat("Generating plots...\n")

# Plot 1: Top 15 QBs by EPA
p1 <- ggplot(head(qb_stats %>% arrange(desc(epa_per_play)), 15),
       aes(x = reorder(passer_player_name, epa_per_play),
           y = epa_per_play,
           fill = posteam)) +
  geom_col() +
  coord_flip() +
  sfm(color.teams) +
  theme_minimal() +
  labs(
    title = "Top 15 QBs by EPA per Play - 2025 Season",
    x = "",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    legend.position = "none"
  )
ggsave("report_plots/01_top_qbs_epa.png", p1, width = 10, height = 8, dpi = 300)

# Plot 2: Completion % vs EPA
p2 <- ggplot(qb_stats, aes(x = completion_pct, y = epa_per_play, color = posteam)) +
  geom_hline(yintercept = 0, linetype = "dashed", alpha = 0.3) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text(
    data = filter(qb_stats, epa_per_play > 0.15 | completion_pct > 67),
    aes(label = passer_player_name),
    hjust = -0.1, size = 3, show.legend = FALSE
  ) +
  scm(color.teams) +
  theme_minimal() +
  labs(
    title = "Completion % vs EPA per Play",
    x = "Completion %",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    legend.position = "none"
  )
ggsave("report_plots/02_comp_vs_epa.png", p2, width = 10, height = 8, dpi = 300)

# Plot 3: Success Rate vs CPOE
p3 <- ggplot(qb_stats, aes(x = cpoe * 100, y = success_rate * 100, color = posteam)) +
  geom_hline(yintercept = mean(qb_stats$success_rate * 100),
             linetype = "dashed", alpha = 0.5) +
  geom_vline(xintercept = mean(qb_stats$cpoe * 100, na.rm = TRUE),
             linetype = "dashed", alpha = 0.5) +
  geom_point(size = 3, alpha = 0.7) +
  geom_text(
    data = filter(qb_stats, success_rate > 0.50 | cpoe > 5),
    aes(label = passer_player_name),
    hjust = -0.1, size = 3, show.legend = FALSE
  ) +
  scm(color.teams) +
  theme_minimal() +
  labs(
    title = "Success Rate vs Completion % Over Expected",
    x = "CPOE (%)",
    y = "Success Rate (%)"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    legend.position = "none"
  )
ggsave("report_plots/03_success_vs_cpoe.png", p3, width = 10, height = 8, dpi = 300)

# Plot 4: Maye - Efficiency vs Aggression
p4 <- ggplot(qb_stats, aes(x = air_yards_per_att, y = epa_per_play)) +
  geom_hline(yintercept = mean(qb_stats$epa_per_play),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_vline(xintercept = mean(qb_stats$air_yards_per_att),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_point(aes(color = posteam), size = 3, alpha = 0.6) +
  geom_point(data = maye, aes(color = posteam), size = 8, shape = 21,
             stroke = 3, fill = NA) +
  geom_text(data = maye, aes(label = "DRAKE MAYE"),
            hjust = -0.1, fontface = "bold", size = 5, color = "#002244") +
  scm(color.teams) +
  annotate("text", x = 11, y = 0.25, label = "Elite & Aggressive",
           fontface = "bold", color = "darkgreen", size = 5) +
  theme_minimal() +
  labs(
    title = "Drake Maye: Efficiency + Aggression Elite Territory",
    x = "Air Yards per Attempt (Aggression)",
    y = "EPA per Play (Efficiency)"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    legend.position = "none"
  )
ggsave("report_plots/04_maye_efficiency_aggression.png", p4, width = 10, height = 8, dpi = 300)

# Plot 5: Maye - Deep Ball
qb_stats_deep <- qb_stats %>% filter(deep_att >= 20)
p5 <- ggplot(qb_stats_deep, aes(x = deep_att, y = deep_comp_pct)) +
  geom_hline(yintercept = mean(qb_stats_deep$deep_comp_pct, na.rm = TRUE),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_point(aes(color = posteam, size = deep_yards), alpha = 0.6) +
  geom_point(data = filter(maye, deep_att >= 20),
             aes(color = posteam), size = 10, shape = 21, stroke = 3, fill = NA) +
  geom_text(data = filter(maye, deep_att >= 20),
            aes(label = "MAYE"), hjust = -0.2, fontface = "bold", size = 5, color = "#002244") +
  scm(color.teams) +
  theme_minimal() +
  labs(
    title = "Drake Maye: Deep Ball Volume vs Accuracy",
    subtitle = "Size = Total Deep Yards | 20+ Air Yards",
    x = "Deep Attempts",
    y = "Deep Completion %",
    size = "Deep Yards"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12)
  )
ggsave("report_plots/05_maye_deep_ball.png", p5, width = 10, height = 8, dpi = 300)

# Plot 6: Stafford - Air Yards vs EPA
p6 <- ggplot(qb_stats, aes(x = air_yards_per_att, y = epa_per_play)) +
  geom_point(aes(color = posteam), size = 3, alpha = 0.6) +
  geom_point(data = stafford, aes(color = posteam), size = 8, shape = 21,
             stroke = 3, fill = NA) +
  geom_text(data = stafford, aes(label = "STAFFORD"),
            hjust = -0.1, fontface = "bold", size = 5, color = "#003594") +
  scm(color.teams) +
  theme_minimal() +
  labs(
    title = "Matthew Stafford: Air Yards vs EPA",
    x = "Air Yards per Attempt",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    legend.position = "none"
  )
ggsave("report_plots/06_stafford_air_yards_epa.png", p6, width = 10, height = 8, dpi = 300)

# Plot 7: Stafford - Deep Ball
p7 <- ggplot(qb_stats_deep, aes(x = deep_att, y = deep_yards)) +
  geom_point(aes(color = posteam, size = deep_td), alpha = 0.6) +
  geom_point(data = filter(stafford, deep_att >= 20),
             aes(color = posteam), size = 10, shape = 21, stroke = 3, fill = NA) +
  geom_text(data = filter(stafford, deep_att >= 20),
            aes(label = "STAFFORD"), hjust = -0.1, fontface = "bold", size = 5, color = "#003594") +
  scm(color.teams) +
  theme_minimal() +
  labs(
    title = "Matthew Stafford: Deep Ball Volume vs Yards",
    subtitle = "Size = Deep TDs | 20+ Air Yards",
    x = "Deep Attempts (20+ yards)",
    y = "Deep Yards",
    size = "Deep TDs"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12)
  )
ggsave("report_plots/07_stafford_deep_ball.png", p7, width = 10, height = 8, dpi = 300)

# Plot 8: Young QBs comparison
young_qbs <- qb_stats %>%
  filter(passer_player_name %in% c("D.Maye", "C.Williams", "J.Daniels",
                                     "B.Nix", "J.McCarthy", "M.Penix")) %>%
  arrange(desc(epa_per_play))

p8 <- ggplot(young_qbs, aes(x = reorder(passer_player_name, epa_per_play),
                            y = epa_per_play, fill = posteam)) +
  geom_col() +
  geom_hline(yintercept = 0, linetype = "solid", alpha = 0.3) +
  coord_flip() +
  sfm(color.teams) +
  theme_minimal() +
  labs(
    title = "Young QB Comparison (2023-2024 Draft Classes)",
    subtitle = "Drake Maye dominates recent draftees",
    x = "",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    plot.subtitle = element_text(hjust = 0.5, size = 12),
    legend.position = "none"
  )
ggsave("report_plots/08_young_qbs.png", p8, width = 10, height = 8, dpi = 300)

cat("All plots generated successfully!\n")
cat("Creating HTML report...\n")
