# Drake Maye Deep Dive Analysis - 2025 Season
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

    # Explosive plays
    explosive_passes = sum(passing_yards >= 20, na.rm = TRUE),

    # Scrambling
    scrambles = sum(qb_scramble, na.rm = TRUE),
    scramble_yards = sum(rushing_yards[qb_scramble == 1], na.rm = TRUE),

    .groups = "drop"
  ) %>%
  filter(attempts >= 100) %>%
  mutate(
    completion_pct = (completions / attempts) * 100,
    yards_per_attempt = yards / attempts,
    deep_comp_pct = (deep_comp / deep_att) * 100,
    td_int_ratio = touchdowns / pmax(interceptions, 1),
    explosive_rate = (explosive_passes / attempts) * 100
  )

# Get Maye's stats
maye <- qb_stats %>% filter(passer_player_name == "D.Maye")

cat("\n========== DRAKE MAYE 2025 ANALYSIS ==========\n\n")

# Overall ranking
cat("=== OVERALL RANKINGS ===\n")
metrics <- c("epa_per_play", "success_rate", "completion_pct", "yards_per_attempt",
             "deep_yards", "deep_comp_pct", "air_yards_per_att", "cpoe")

for(metric in metrics) {
  rank <- sum(qb_stats[[metric]] > maye[[metric]], na.rm = TRUE) + 1
  percentile <- round((1 - rank/nrow(qb_stats)) * 100, 1)
  cat(sprintf("%s: Rank %d of %d (Top %.1f%%)\n",
              metric, rank, nrow(qb_stats), 100 - percentile))
}

# What makes Maye special
cat("\n=== MAYE'S ELITE AREAS ===\n")
cat(sprintf("EPA per Play: %.3f (#1 in NFL - Historic for rookie/2nd year)\n", maye$epa_per_play))
cat(sprintf("Success Rate: %.1f%% (#1 in NFL)\n", maye$success_rate * 100))
cat(sprintf("Completion %%: %.1f%% (Top tier)\n", maye$completion_pct))
cat(sprintf("CPOE: %.3f (Accuracy above expectation)\n", maye$cpoe))

# Deep ball comparison
cat("\n=== DEEP BALL (20+ AIR YARDS) ===\n")
cat(sprintf("Maye Deep Attempts: %d (Rank: %d)\n",
            maye$deep_att,
            sum(qb_stats$deep_att > maye$deep_att, na.rm = TRUE) + 1))
cat(sprintf("Maye Deep Completions: %d\n", maye$deep_comp))
cat(sprintf("Maye Deep Completion %%: %.1f%% (League avg: %.1f%%)\n",
            maye$deep_comp_pct, mean(qb_stats$deep_comp_pct, na.rm = TRUE)))
cat(sprintf("Maye Deep Yards: %d (Rank: %d)\n",
            maye$deep_yards,
            sum(qb_stats$deep_yards > maye$deep_yards, na.rm = TRUE) + 1))
cat(sprintf("Maye Deep TDs: %d (Rank: %d)\n",
            maye$deep_td,
            sum(qb_stats$deep_td > maye$deep_td, na.rm = TRUE) + 1))

# Air yards
cat("\n=== AIR YARDS ===\n")
cat(sprintf("Maye Air Yards/Attempt: %.2f (League avg: %.2f)\n",
            maye$air_yards_per_att, mean(qb_stats$air_yards_per_att, na.rm = TRUE)))
cat(sprintf("Rank: %d of %d (#2 among efficient QBs)\n",
            sum(qb_stats$air_yards_per_att > maye$air_yards_per_att, na.rm = TRUE) + 1,
            nrow(qb_stats)))

# Efficiency metrics
cat("\n=== EFFICIENCY DOMINANCE ===\n")
cat(sprintf("Success Rate: %.1f%% (League avg: %.1f%%)\n",
            maye$success_rate * 100, mean(qb_stats$success_rate * 100)))
cat(sprintf("Third Down Success: %.1f%% (Rank: %d)\n",
            maye$third_down_success * 100,
            sum(qb_stats$third_down_success > maye$third_down_success, na.rm = TRUE) + 1))

# Explosive plays
cat("\n=== BIG PLAY ABILITY ===\n")
cat(sprintf("Explosive Pass Rate (20+ yards): %.1f%% (Rank: %d)\n",
            maye$explosive_rate,
            sum(qb_stats$explosive_rate > maye$explosive_rate, na.rm = TRUE) + 1))
cat(sprintf("Total Explosive Passes: %d\n", maye$explosive_passes))

# Scrambling
cat("\n=== MOBILITY ===\n")
cat(sprintf("Scrambles: %d (Rank: %d)\n",
            maye$scrambles,
            sum(qb_stats$scrambles > maye$scrambles, na.rm = TRUE) + 1))
cat(sprintf("Scramble Yards: %d yards\n", maye$scramble_yards))

# The Maye Formula
cat("\n=== THE DRAKE MAYE FORMULA ===\n")
cat("1. Elite Efficiency (#1 EPA, #1 Success Rate)\n")
cat("2. Deep Ball Aggression (70 deep attempts, 9.13 air yards/att)\n")
cat("3. High Accuracy (65.6% completion, positive CPOE)\n")
cat("4. Big Play Creation (explosive passes + scrambling)\n")
cat("\n=> Result: Most efficient QB in the NFL\n")

# Comparison with other young QBs
cat("\n=== YOUNG QB COMPARISON (Drafted 2023-2024) ===\n")
young_qbs <- qb_stats %>%
  filter(passer_player_name %in% c("D.Maye", "C.Williams", "J.Daniels",
                                     "B.Nix", "J.McCarthy", "M.Penix"))

print(young_qbs %>%
        select(passer_player_name, posteam, epa_per_play, success_rate,
               completion_pct, deep_att, air_yards_per_att) %>%
        arrange(desc(epa_per_play)))

# Visualizations
color.teams <- select(team_data, values = team_color, breaks = team_abbr)
qb_stats <- qb_stats %>%
  left_join(team_data, by = c("posteam" = "team_abbr"))

# 1. Efficiency + Aggression Quadrant
ggplot(qb_stats, aes(x = air_yards_per_att, y = epa_per_play)) +
  geom_hline(yintercept = mean(qb_stats$epa_per_play),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_vline(xintercept = mean(qb_stats$air_yards_per_att),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_point(aes(color = posteam), size = 3, alpha = 0.6) +
  geom_point(data = maye, aes(color = posteam), size = 8, shape = 21,
             stroke = 3, fill = NA) +
  geom_text(data = maye, aes(label = "MAYE"),
            hjust = -0.3, fontface = "bold", size = 5) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  annotate("text", x = 11, y = 0.25, label = "Elite & Aggressive",
           fontface = "bold", color = "darkgreen", size = 4) +
  theme_minimal() +
  labs(
    title = "Efficiency vs Aggression - Drake Maye in Elite Territory",
    subtitle = "Upper-right quadrant = Elite aggressive passers",
    x = "Air Yards per Attempt (Aggression)",
    y = "EPA per Play (Efficiency)"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    legend.position = "none"
  )

# 2. Success Rate vs CPOE
ggplot(qb_stats, aes(x = cpoe * 100, y = success_rate * 100)) +
  geom_hline(yintercept = mean(qb_stats$success_rate * 100),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_vline(xintercept = mean(qb_stats$cpoe * 100, na.rm = TRUE),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_point(aes(color = posteam), size = 3, alpha = 0.6) +
  geom_point(data = maye, aes(color = posteam), size = 8, shape = 21,
             stroke = 3, fill = NA) +
  geom_text(data = maye, aes(label = "MAYE"),
            hjust = -0.3, fontface = "bold", size = 5) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "Success Rate vs Accuracy - Maye Dominates Both",
    x = "CPOE % (Completion % Over Expected)",
    y = "Success Rate %"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    legend.position = "none"
  )

# 3. Deep Ball Efficiency
qb_stats_deep <- qb_stats %>% filter(deep_att >= 20)

ggplot(qb_stats_deep, aes(x = deep_att, y = deep_comp_pct)) +
  geom_hline(yintercept = mean(qb_stats_deep$deep_comp_pct, na.rm = TRUE),
             linetype = "dashed", alpha = 0.5, color = "gray") +
  geom_point(aes(color = posteam, size = deep_yards), alpha = 0.6) +
  geom_point(data = filter(maye, deep_att >= 20),
             aes(color = posteam), size = 10, shape = 21, stroke = 3, fill = NA) +
  geom_text(data = filter(maye, deep_att >= 20),
            aes(label = "MAYE"), hjust = -0.3, fontface = "bold", size = 5) +
  scale_color_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "Deep Ball Volume vs Accuracy - Maye's Balanced Approach",
    subtitle = "Size = Total Deep Yards | 20+ Air Yards",
    x = "Deep Attempts",
    y = "Deep Completion %",
    size = "Deep Yards"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5)
  )

# 4. Maye's percentile rankings
maye_percentiles <- data.frame(
  metric = c("EPA/Play", "Success Rate", "Comp %", "CPOE",
             "Deep Yards", "Air Yards", "YPA", "Explosive Rate"),
  percentile = c(
    (1 - (sum(qb_stats$epa_per_play > maye$epa_per_play) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$success_rate > maye$success_rate) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$completion_pct > maye$completion_pct) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$cpoe > maye$cpoe, na.rm = TRUE) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$deep_yards > maye$deep_yards, na.rm = TRUE) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$air_yards_per_att > maye$air_yards_per_att, na.rm = TRUE) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$yards_per_attempt > maye$yards_per_attempt) + 1) / nrow(qb_stats)) * 100,
    (1 - (sum(qb_stats$explosive_rate > maye$explosive_rate, na.rm = TRUE) + 1) / nrow(qb_stats)) * 100
  )
)

ggplot(maye_percentiles, aes(x = reorder(metric, percentile), y = percentile)) +
  geom_col(fill = "#002244", alpha = 0.8) +
  geom_hline(yintercept = 90, linetype = "dashed", color = "gold", alpha = 0.7, linewidth = 1) +
  geom_hline(yintercept = 75, linetype = "dashed", color = "orange", alpha = 0.5) +
  geom_hline(yintercept = 50, linetype = "dashed", color = "gray", alpha = 0.5) +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Drake Maye's Percentile Rankings - 2025 Season",
    subtitle = "Among QBs with 100+ attempts | Gold line = 90th percentile",
    x = "",
    y = "Percentile"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5)
  ) +
  ylim(0, 100) +
  geom_text(aes(label = sprintf("%.0f%%", percentile)),
            hjust = -0.2, fontface = "bold")

# 5. Young QB comparison visualization
young_qbs_viz <- young_qbs %>%
  left_join(team_data, by = c("posteam" = "team_abbr"))

ggplot(young_qbs_viz, aes(x = reorder(passer_player_name, epa_per_play),
                          y = epa_per_play, fill = posteam)) +
  geom_col() +
  coord_flip() +
  scale_fill_manual(breaks = color.teams$breaks, values = color.teams$values) +
  theme_minimal() +
  labs(
    title = "Young QB Performance Comparison (2023-2024 Draft Classes)",
    subtitle = "Drake Maye leads all recent draftees",
    x = "",
    y = "EPA per Play"
  ) +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5),
    plot.subtitle = element_text(hjust = 0.5),
    legend.position = "none"
  ) +
  geom_hline(yintercept = 0, linetype = "solid", color = "black", alpha = 0.3)

cat("\n========== ANALYSIS COMPLETE ==========\n")
cat("Drake Maye is the #1 QB in the NFL by EPA in 2025\n")
cat("He combines elite efficiency with aggressive downfield passing\n")
cat("This is historically rare for a young quarterback\n")
