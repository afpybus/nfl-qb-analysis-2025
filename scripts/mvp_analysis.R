# NFL MVP Analysis - 2025 Season
# Comprehensive analysis of MVP contenders across all positions

# Load packages
if (!require("pacman")) install.packages("pacman")
pacman::p_load(dplyr, ggplot2, nflreadr, tidyr)

# Configuration
SEASON <- 2025
MIN_QB_ATTEMPTS <- 100
MIN_RB_CARRIES <- 50
MIN_WR_TARGETS <- 30
OUTPUT_DIR <- "output"
PLOTS_DIR <- "plots"

# Create directories if needed
dir.create(OUTPUT_DIR, showWarnings = FALSE)
dir.create(PLOTS_DIR, showWarnings = FALSE)

# Load play-by-play data
cat("Loading 2025 season data...\n")
pbp <- load_pbp(SEASON)

# Load roster data for team info
rosters <- load_rosters(SEASON)

# =============================================================================
# QUARTERBACK MVP CANDIDATES
# =============================================================================

cat("\nAnalyzing QB MVP candidates...\n")

qb_stats <- pbp %>%
  filter(season_type == "REG", !is.na(passer_player_name), !is.na(epa)) %>%
  group_by(
    passer_player_id,
    passer_player_name,
    posteam
  ) %>%
  summarise(
    attempts = n(),
    completions = sum(complete_pass, na.rm = TRUE),
    pass_yards = sum(yards_gained, na.rm = TRUE),
    pass_tds = sum(touchdown == 1 & complete_pass == 1, na.rm = TRUE),
    interceptions = sum(interception, na.rm = TRUE),

    # Advanced metrics
    epa_per_play = mean(epa, na.rm = TRUE),
    cpoe = mean(cpoe, na.rm = TRUE),
    success_rate = mean(success, na.rm = TRUE),

    # Deep ball
    deep_attempts = sum(air_yards >= 20, na.rm = TRUE),
    deep_completions = sum(complete_pass == 1 & air_yards >= 20, na.rm = TRUE),
    deep_yards = sum(ifelse(complete_pass == 1 & air_yards >= 20, yards_gained, 0), na.rm = TRUE),
    deep_tds = sum(touchdown == 1 & air_yards >= 20, na.rm = TRUE),

    .groups = "drop"
  ) %>%
  filter(attempts >= MIN_QB_ATTEMPTS) %>%
  mutate(
    comp_pct = completions / attempts,
    td_int_ratio = pass_tds / pmax(interceptions, 1),
    deep_comp_pct = deep_completions / pmax(deep_attempts, 1),
    yards_per_attempt = pass_yards / attempts
  ) %>%
  arrange(desc(epa_per_play))

# Add team colors
teams <- load_teams() %>% select(team_abbr, team_color)
qb_stats <- qb_stats %>%
  left_join(teams, by = c("posteam" = "team_abbr"))

cat("Top 10 QBs by EPA/play:\n")
print(qb_stats %>%
  select(passer_player_name, posteam, attempts, epa_per_play, pass_tds, pass_yards) %>%
  head(10))

# =============================================================================
# RUNNING BACK MVP CANDIDATES
# =============================================================================

cat("\nAnalyzing RB MVP candidates...\n")

rb_stats <- pbp %>%
  filter(season_type == "REG", !is.na(rusher_player_name), !is.na(epa)) %>%
  group_by(
    rusher_player_id,
    rusher_player_name,
    posteam
  ) %>%
  summarise(
    carries = n(),
    rush_yards = sum(yards_gained, na.rm = TRUE),
    rush_tds = sum(touchdown == 1, na.rm = TRUE),
    epa_per_rush = mean(epa, na.rm = TRUE),
    success_rate = mean(success, na.rm = TRUE),
    yards_per_carry = mean(yards_gained, na.rm = TRUE),
    first_downs = sum(first_down, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(carries >= MIN_RB_CARRIES) %>%
  arrange(desc(rush_yards))

# Add receiving stats for RBs
rb_receiving <- pbp %>%
  filter(season_type == "REG", !is.na(receiver_player_name), !is.na(epa)) %>%
  group_by(
    receiver_player_id,
    receiver_player_name
  ) %>%
  summarise(
    targets = n(),
    receptions = sum(complete_pass, na.rm = TRUE),
    rec_yards = sum(yards_gained, na.rm = TRUE),
    rec_tds = sum(touchdown == 1, na.rm = TRUE),
    .groups = "drop"
  )

# Join RB rush and receiving stats
rb_stats <- rb_stats %>%
  left_join(
    rb_receiving,
    by = c("rusher_player_id" = "receiver_player_id", "rusher_player_name" = "receiver_player_name")
  ) %>%
  mutate(
    targets = replace_na(targets, 0),
    receptions = replace_na(receptions, 0),
    rec_yards = replace_na(rec_yards, 0),
    rec_tds = replace_na(rec_tds, 0),
    total_yards = rush_yards + rec_yards,
    total_tds = rush_tds + rec_tds,
    scrimmage_touches = carries + receptions
  ) %>%
  left_join(teams, by = c("posteam" = "team_abbr"))

cat("Top 10 RBs by total scrimmage yards:\n")
print(rb_stats %>%
  select(rusher_player_name, posteam, total_yards, total_tds, scrimmage_touches, epa_per_rush) %>%
  head(10))

# =============================================================================
# WIDE RECEIVER MVP CANDIDATES
# =============================================================================

cat("\nAnalyzing WR MVP candidates...\n")

wr_stats <- pbp %>%
  filter(season_type == "REG", !is.na(receiver_player_name), !is.na(epa)) %>%
  group_by(
    receiver_player_id,
    receiver_player_name,
    posteam
  ) %>%
  summarise(
    targets = n(),
    receptions = sum(complete_pass, na.rm = TRUE),
    rec_yards = sum(yards_gained, na.rm = TRUE),
    rec_tds = sum(touchdown == 1, na.rm = TRUE),
    epa_per_target = mean(epa, na.rm = TRUE),
    yards_per_reception = mean(ifelse(complete_pass == 1, yards_gained, 0), na.rm = TRUE),
    first_downs = sum(first_down, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  filter(targets >= MIN_WR_TARGETS) %>%
  mutate(
    catch_rate = receptions / targets,
    yards_per_target = rec_yards / targets
  ) %>%
  arrange(desc(rec_yards)) %>%
  left_join(teams, by = c("posteam" = "team_abbr"))

cat("Top 10 WRs by receiving yards:\n")
print(wr_stats %>%
  select(receiver_player_name, posteam, rec_yards, rec_tds, receptions, targets) %>%
  head(10))

# =============================================================================
# MVP COMPARISON: TOP CONTENDERS
# =============================================================================

cat("\n=== TOP MVP CONTENDERS ===\n")

# Top 3 QBs
top_qbs <- qb_stats %>% head(3)
cat("\nTop 3 Quarterbacks:\n")
for(i in 1:nrow(top_qbs)) {
  cat(sprintf("%d. %s (%s): %.3f EPA/play, %d TDs, %d yards, %.1f%% comp\n",
              i, top_qbs$passer_player_name[i], top_qbs$posteam[i],
              top_qbs$epa_per_play[i], top_qbs$pass_tds[i],
              top_qbs$pass_yards[i], top_qbs$comp_pct[i] * 100))
}

# Top 3 RBs
top_rbs <- rb_stats %>% head(3)
cat("\nTop 3 Running Backs:\n")
for(i in 1:nrow(top_rbs)) {
  cat(sprintf("%d. %s (%s): %d total yards, %d TDs, %d touches, %.3f EPA/rush\n",
              i, top_rbs$rusher_player_name[i], top_rbs$posteam[i],
              top_rbs$total_yards[i], top_rbs$total_tds[i],
              top_rbs$scrimmage_touches[i], top_rbs$epa_per_rush[i]))
}

# Top 3 WRs
top_wrs <- wr_stats %>% head(3)
cat("\nTop 3 Wide Receivers:\n")
for(i in 1:nrow(top_wrs)) {
  cat(sprintf("%d. %s (%s): %d yards, %d TDs, %d rec, %.3f EPA/target\n",
              i, top_wrs$receiver_player_name[i], top_wrs$posteam[i],
              top_wrs$rec_yards[i], top_wrs$rec_tds[i],
              top_wrs$receptions[i], top_wrs$epa_per_target[i]))
}

# =============================================================================
# VISUALIZATIONS
# =============================================================================

cat("\nGenerating MVP analysis visualizations...\n")

# Plot 1: Top QB MVP Candidates - EPA vs Volume
top10_qbs <- qb_stats %>% head(10)

p1 <- ggplot(top10_qbs, aes(x = attempts, y = epa_per_play)) +
  geom_point(aes(size = pass_tds), color = top10_qbs$team_color, alpha = 0.7) +
  geom_text(aes(label = passer_player_name),
            hjust = -0.1, size = 3.5, fontface = "bold") +
  scale_size_continuous(range = c(5, 15), name = "Pass TDs") +
  scale_x_continuous(expand = expansion(mult = c(0.05, 0.25))) +
  scale_y_continuous(expand = expansion(mult = c(0.1, 0.1))) +
  labs(
    title = "Top 10 QB MVP Candidates - Efficiency vs Volume",
    subtitle = "Size = Touchdown Passes | 2025 Regular Season",
    x = "Pass Attempts",
    y = "EPA per Play",
    caption = "Data: nflreadr | Min. 100 attempts"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    plot.margin = margin(10, 20, 10, 10)
  )

ggsave(file.path(PLOTS_DIR, "09_mvp_qb_contenders.png"), p1,
       width = 10, height = 7, dpi = 300)

# Plot 2: Top RB MVP Candidates - Total Production
top8_rbs <- rb_stats %>% head(8)

p2 <- ggplot(top8_rbs, aes(x = reorder(rusher_player_name, total_yards), y = total_yards)) +
  geom_col(fill = top8_rbs$team_color, alpha = 0.8) +
  geom_text(aes(label = sprintf("%d yds\n%d TDs", total_yards, total_tds)),
            hjust = -0.1, size = 3, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  coord_flip() +
  labs(
    title = "Top RB MVP Candidates - Total Scrimmage Yards",
    subtitle = "Rushing + Receiving | 2025 Regular Season",
    x = NULL,
    y = "Total Scrimmage Yards",
    caption = "Data: nflreadr | Min. 50 carries"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    axis.text.y = element_text(face = "bold", size = 10)
  )

ggsave(file.path(PLOTS_DIR, "10_mvp_rb_contenders.png"), p2,
       width = 10, height = 7, dpi = 300)

# Plot 3: Top WR MVP Candidates
top8_wrs <- wr_stats %>% head(8)

p3 <- ggplot(top8_wrs, aes(x = reorder(receiver_player_name, rec_yards), y = rec_yards)) +
  geom_col(fill = top8_wrs$team_color, alpha = 0.8) +
  geom_text(aes(label = sprintf("%d yds\n%d TDs", rec_yards, rec_tds)),
            hjust = -0.1, size = 3, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  coord_flip() +
  labs(
    title = "Top WR MVP Candidates - Receiving Yards",
    subtitle = "2025 Regular Season",
    x = NULL,
    y = "Receiving Yards",
    caption = "Data: nflreadr | Min. 30 targets"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    axis.text.y = element_text(face = "bold", size = 10)
  )

ggsave(file.path(PLOTS_DIR, "11_mvp_wr_contenders.png"), p3,
       width = 10, height = 7, dpi = 300)

# Plot 4: MVP Value Comparison - EPA across positions
mvp_comparison <- bind_rows(
  top_qbs %>%
    mutate(position = "QB",
           total_epa = epa_per_play * attempts,
           player_name = passer_player_name) %>%
    select(player_name, position, posteam, total_epa, team_color) %>%
    head(5),
  top_rbs %>%
    mutate(position = "RB",
           total_epa = epa_per_rush * carries,
           player_name = rusher_player_name) %>%
    select(player_name, position, posteam, total_epa, team_color) %>%
    head(3),
  top_wrs %>%
    mutate(position = "WR",
           total_epa = epa_per_target * targets,
           player_name = receiver_player_name) %>%
    select(player_name, position, posteam, total_epa, team_color) %>%
    head(3)
)

p4 <- ggplot(mvp_comparison, aes(x = reorder(player_name, total_epa), y = total_epa)) +
  geom_col(fill = mvp_comparison$team_color, alpha = 0.8) +
  geom_text(aes(label = sprintf("%.1f\n(%s)", total_epa, position)),
            hjust = -0.1, size = 3, fontface = "bold") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.15))) +
  coord_flip() +
  labs(
    title = "MVP Contenders - Total EPA Added",
    subtitle = "Expected Points Added | 2025 Regular Season",
    x = NULL,
    y = "Total EPA (Season)",
    caption = "Data: nflreadr | QB: EPA*attempts | RB: EPA*carries | WR: EPA*targets"
  ) +
  theme_minimal() +
  theme(
    plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
    plot.subtitle = element_text(hjust = 0.5, size = 10),
    axis.text.y = element_text(face = "bold", size = 10)
  )

ggsave(file.path(PLOTS_DIR, "12_mvp_total_epa.png"), p4,
       width = 10, height = 7, dpi = 300)

# =============================================================================
# EXPORT DATA
# =============================================================================

cat("\nExporting MVP analysis data...\n")

write.csv(qb_stats, file.path(OUTPUT_DIR, "mvp_qb_candidates_2025.csv"), row.names = FALSE)
write.csv(rb_stats, file.path(OUTPUT_DIR, "mvp_rb_candidates_2025.csv"), row.names = FALSE)
write.csv(wr_stats, file.path(OUTPUT_DIR, "mvp_wr_candidates_2025.csv"), row.names = FALSE)
write.csv(mvp_comparison, file.path(OUTPUT_DIR, "mvp_top_contenders_2025.csv"), row.names = FALSE)

cat("\n✓ MVP Analysis Complete!\n")
cat(sprintf("  - Generated 4 visualizations in %s/\n", PLOTS_DIR))
cat(sprintf("  - Exported 4 data files to %s/\n", OUTPUT_DIR))
cat("\nFiles created:\n")
cat("  Plots: 09_mvp_qb_contenders.png, 10_mvp_rb_contenders.png, 11_mvp_wr_contenders.png, 12_mvp_total_epa.png\n")
cat("  Data: mvp_qb_candidates_2025.csv, mvp_rb_candidates_2025.csv, mvp_wr_candidates_2025.csv, mvp_top_contenders_2025.csv\n")
