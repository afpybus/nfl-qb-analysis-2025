# Matt Stafford Deep Dive Analysis - 2025 Season
pacman::p_load(dplyr, ggplot2, nflreadr, tidyr)

# Load data
pbp_data <- nflreadr::load_pbp(seasons = 2025)
team_data <- nflreadr::load_teams()

# Calculate comprehensive QB stats
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

    # Situational stats
    third_down_success = sum(success[down == 3], na.rm = TRUE) / sum(down == 3, na.rm = TRUE),
    red_zone_td_rate = sum(touchdown[yardline_100 <= 20], na.rm = TRUE) / sum(pass_attempt[yardline_100 <= 20], na.rm = TRUE),

    # Deep ball stats
    deep_att = sum(air_yards >= 20, na.rm = TRUE),
    deep_comp = sum(complete_pass[air_yards >= 20], na.rm = TRUE),
    deep_yards = sum(passing_yards[air_yards >= 20], na.rm = TRUE),
    deep_td = sum(touchdown[air_yards >= 20], na.rm = TRUE),

    # Short/intermediate
    short_success = mean(success[air_yards < 10], na.rm = TRUE),
    medium_success = mean(success[air_yards >= 10 & air_yards < 20], na.rm = TRUE),

    .groups = "drop"
  ) %>%
  filter(attempts >= 100) %>%
  mutate(
    completion_pct = (completions / attempts) * 100,
    yards_per_attempt = yards / attempts,
    deep_comp_pct = (deep_comp / deep_att) * 100,
    deep_yards_per_game = deep_yards / 17
  )

# Get Stafford's stats
stafford <- qb_stats %>% filter(passer_player_name == "M.Stafford")

cat("\n========== MATT STAFFORD 2025 ANALYSIS ==========\n\n")

# Overall ranking
cat("=== OVERALL RANKINGS ===\n")
metrics <- c("epa_per_play", "yards", "touchdowns", "yards_per_attempt",
             "deep_yards", "deep_td", "air_yards_per_att")

for(metric in metrics) {
  rank <- sum(qb_stats[[metric]] > stafford[[metric]], na.rm = TRUE) + 1
  percentile <- round((1 - rank/nrow(qb_stats)) * 100, 1)
  cat(sprintf("%s: Rank %d of %d (Top %.1f%%)\n",
              metric, rank, nrow(qb_stats), 100 - percentile))
}

# Deep ball comparison
cat("\n=== DEEP BALL (20+ AIR YARDS) ===\n")
cat(sprintf("Stafford Deep Attempts: %d (Rank: %d)\n",
            stafford$deep_att,
            sum(qb_stats$deep_att > stafford$deep_att, na.rm = TRUE) + 1))
cat(sprintf("Stafford Deep Completions: %d\n", stafford$deep_comp))
cat(sprintf("Stafford Deep Completion %%: %.1f%% (League avg: %.1f%%)\n",
            stafford$deep_comp_pct, mean(qb_stats$deep_comp_pct, na.rm = TRUE)))
cat(sprintf("Stafford Deep Yards: %d (Rank: %d)\n",
            stafford$deep_yards,
            sum(qb_stats$deep_yards > stafford$deep_yards, na.rm = TRUE) + 1))
cat(sprintf("Stafford Deep TDs: %d (Rank: %d)\n",
            stafford$deep_td,
            sum(qb_stats$deep_td > stafford$deep_td, na.rm = TRUE) + 1))

# Air yards
cat("\n=== AIR YARDS ===\n")
cat(sprintf("Stafford Air Yards/Attempt: %.2f (League avg: %.2f)\n",
            stafford$air_yards_per_att, mean(qb_stats$air_yards_per_att, na.rm = TRUE)))
cat(sprintf("Rank: %d of %d\n",
            sum(qb_stats$air_yards_per_att > stafford$air_yards_per_att, na.rm = TRUE) + 1,
            nrow(qb_stats)))

# Top 10 comparison
cat("\n=== TOP 10 QBS BY DEEP BALL YARDS ===\n")
print(qb_stats %>%
        select(passer_player_name, posteam, deep_att, deep_comp, deep_yards, deep_td) %>%
        arrange(desc(deep_yards)) %>%
        head(10))

cat("\n=== TOP 10 QBS BY AIR YARDS PER ATTEMPT ===\n")
print(qb_stats %>%
        select(passer_player_name, posteam, air_yards_per_att, deep_att, epa_per_play) %>%
        arrange(desc(air_yards_per_att)) %>%
        head(10))

# Visualizations
color.teams <- select(team_data, values = team_color, breaks = team_abbr)
qb_stats <- qb_stats %>%
  left_join(team_data, by = c("posteam" = "team_abbr"))

# 1. Air Yards vs EPA
ggplot(qb_stats, aes(x = air_yards_per_att, y = epa_per_play)) +
  geom_point(aes(color = posteam), size = 3, alpha = 0.6) +
  geom_point(data = stafford, aes(color = posteam), size = 6, shape = 21,
             stroke = 2, fill = NA) +
  geom_text(data = stafford, aes(label = "Stafford"),
            hjust = -0.2, fontface = "bold", size = 4) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "Air Yards per Attempt vs EPA - Stafford Highlighted",
    x = "Air Yards per Attempt",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

# 2. Deep Ball Success
qb_stats_deep <- qb_stats %>% filter(deep_att >= 20)

ggplot(qb_stats_deep, aes(x = deep_att, y = deep_yards)) +
  geom_point(aes(color = posteam, size = deep_td), alpha = 0.6) +
  geom_point(data = filter(stafford, deep_att >= 20),
             aes(color = posteam), size = 10, shape = 21, stroke = 2, fill = NA) +
  geom_text(data = filter(stafford, deep_att >= 20),
            aes(label = "Stafford"), hjust = -0.2, fontface = "bold", size = 4) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "Deep Ball Volume vs Yards - Stafford Highlighted",
    subtitle = "Size = Deep TDs | 20+ Air Yards",
    x = "Deep Attempts (20+ yards)",
    y = "Deep Yards",
    size = "Deep TDs"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

# 3. Stafford's strengths radar
stafford_percentiles <- data.frame(
  metric = c("EPA/Play", "Deep Yards", "Air Yards", "YPA", "Comp %", "TD Rate"),
  percentile = c(
    (1 - (sum(qb_stats$epa_per_play > stafford$epa_per_play) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$deep_yards > stafford$deep_yards, na.rm = TRUE) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$air_yards_per_att > stafford$air_yards_per_att, na.rm = TRUE) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$yards_per_attempt > stafford$yards_per_attempt) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$completion_pct > stafford$completion_pct) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$touchdowns > stafford$touchdowns) + 1) / nrow(qb_stats)) * 100
  )
)

ggplot(stafford_percentiles, aes(x = reorder(metric, percentile), y = percentile)) +
  geom_col(fill = "#003594", alpha = 0.8) +
  geom_hline(yintercept = 75, linetype = "dashed", color = "red", alpha = 0.5) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "gray", alpha = 0.5) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Matt Stafford's Percentile Rankings - 2025 Season",
    subtitle = "Among QBs with 100+ attempts",
    x = "",
    y = "Percentile"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  ) +
  ylim(0, 100)
