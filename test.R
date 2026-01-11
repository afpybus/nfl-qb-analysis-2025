pacman::p_load(dplyr,ggplot2,forcats,ggalluvial,tidyr)

player_data <- nflreadr::load_players()
team_data <- nflreadr::load_teams()
current_players <- filter(player_data,last_season==2025) %>%
  left_join(team_data,by=c("latest_team"="team_abbr"))

color.teams = select(team_data,values=team_color,breaks=team_abbr)
sfm = function(color.df){scale_fill_manual(breaks=color.df$breaks,values=color.df$values)}

college_table = table(current_players$college_name)
top_colleges = college_table[college_table > 30]

first_rounders = current_players %>%
  filter(draft_round == 1) 

top_picks = filter(current_players,draft_pick<=5) %>%
  mutate(college_name = gsub("[;].*","",college_name))
#filter(college_name %in% names(top_colleges)) %>%
ggplot(top_picks,aes(x=fct_infreq(latest_team),fill=latest_team)) +
  geom_bar() +
  theme_minimal() +
  sfm(color.teams) +
  ggtitle("Number of Top 5 Picks by Team") +
  theme(plot.title=element_text(face="bold",hjust=0.5)) +
  xlab("") +
  ggeasy::easy_remove_legend()

ggplot(top_picks,aes(x=fct_infreq(latest_team))) +
  geom_bar() +
  coord_flip()

df = top_picks %>%
  group_by(draft_team,latest_team) %>%
  summarise(count=n())

ggplot(df,aes(y=count,axis1=draft_team,axis2=latest_team)) +
  geom_alluvium(aes(fill=draft_team),width=1/12) +
  sfm(color.teams) +
  geom_stratum(width = 1/12, aes(fill=draft_team), color = "grey") +
  geom_label(stat = "stratum", aes(label = after_stat(stratum)))   



df_long = top_picks %>%
  pivot_longer(cols = c("draft_team","latest_team"),names_to = "team_type",values_to="team") %>%
  mutate(count=1) %>%
  mutate(team_type=case_when(
    team_type=="draft_team" ~ "Draft Team",
    team_type=="latest_team" ~ "Current Team"
  )) %>%
    mutate(team_type=factor(team_type,levels=c("Draft Team","Current Team")))

ggplot(df_long,aes(x=team_type,stratum=team,alluvium=display_name,fill=team,label=team)) +
  sfm(color.teams) +
  geom_flow(stat = "alluvium")+
  geom_stratum()


ggplot(df_long,
       aes(x = team_type, stratum = team, alluvium = display_name,
           y = count,
           fill = team, label = team)) +
  scale_x_discrete(expand = c(.1, .1)) +
  geom_flow(alpha=1,color="black") +
  geom_stratum() +
  geom_label(stat = "stratum", size = 3.5,fill="white") +
  theme_minimal() +
  theme(legend.position = "none") +
  sfm(color.teams) +
  xlab("") + ylab("Player Count") +
  ggtitle("Top 5 Draft Picks: Draft Team vs Current Team") +
  theme(plot.title=element_text(face="bold",hjust=0.5))

