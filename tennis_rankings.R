#5/29/18 
#tennis ranking code 

tennis=read.csv("atp_fanta.csv")
tennis_sub=subset(tennis,select=c("tourney_name","tourney_date","winner_rank","loser_rank","round","winner_name","loser_name"))
dim(tennis_sub) 

#tourney score (take average of winner and loser rank at the tourney)
library(plyr)
tourney_win_rank=ddply(tennis_sub,.(tourney_name),plyr::summarize,win_rank=mean(winner_rank))
describe(tourney_win_rank) #average winner rank= 246.3 

tourney_lose_rank=ddply(tennis_sub,.(tourney_name),plyr::summarize,lose_rank=mean(loser_rank))
describe(tourney_lose_rank) #average loser rank= 288.1

tourney_player_ratings=merge(tourney_win_rank,tourney_lose_rank,by="tourney_name")
str(tourney_player_ratings)


#tourney dates weight (recent matches are weighted higher) 
tourney_date=tennis_sub['tourney_date']
library(stringr)
tourney_date_ext=substr(tennis_sub$tourney_date,start=1,stop=6)
tourney_date_ext
tennis_sub1=cbind(tennis_sub,tourney_date_ext)
write.csv(tennis_sub1,"tennis_sub1.csv")


#count player_wins (by winner ranking)
count_winner_groups<-tennis_sub1 %>%
  group_by(player_win_group) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

count_winner_groups


#count player_loss (by loser ranking)
count_loser_groups<-tennis_sub1 %>%
  group_by(player_lose_group) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

count_loser_groups

#ratios (ratio wins vs. loses by ranking group)
final_ranks=cbind(count_winner_groups,count_loser_groups)
names(final_ranks)[6]="freq1"
final_ranks$ratio=(final_ranks$freq)/(final_ranks$freq1)
final_ranks


tennis_date=tennis_sub1["tourney_date"]
tourney_date_ext1=substr(tennis_sub1$tourney_date,start=1,stop=4)
tourney_date_ext1
write.csv(tourney_date_ext1,file="dates_tennis.csv")

#merge by tennis tourneys
t1=read.csv("tennis_final.csv")
t2=read.csv("tourney_score.csv")
t3=merge(t1,t2,by="tourney_name")
write.csv(t3,file="tennis_final1.csv")


###########************************
#player ratings 
ratings=read.csv("tennis_final_actual1.csv")
ratings_sub=subset(ratings,select=c("winner_name","loser_name","round_weight","player_wg_score",
                                    "player_lg_score","date_weight","tourney_score","surface"))

library(VGAM) #for reciprocal values 
#winner score 
ratings_sub$winner_score=(ratings_sub$round_weight)*(ratings_sub$tourney_score)*(ratings_sub$player_lg_score)*(ratings_sub$date_weight)
#loser score
ratings_sub$loser_score=-(reciprocal(ratings_sub$round_weight)*reciprocal(ratings_sub$tourney_score)*reciprocal(ratings_sub$player_lg_score)*(ratings_sub$date_weight))

#i. 
#raw rankings (not controlling for surface)
winner_raw=ddply(ratings_sub,.(winner_name),plyr::summarize,winner_rank=sum(winner_score))
loser_raw=ddply(ratings_sub,.(loser_name),plyr::summarize,loser_rank=sum(loser_score))

names(winner_raw)[1]="player"
names(loser_raw)[1]="player"

raw_ratings=merge(winner_raw,loser_raw,by="player")
raw_ratings$raw_rank=(raw_ratings$winner_rank)-(raw_ratings$loser_rank)

#cut off games played
count_players_win<- ratings_sub%>%
  group_by(winner_name) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

count_players_lose<- ratings_sub%>%
  group_by(loser_name) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

names(count_players_win)[1]="player"
names(count_players_lose)[1]="player"

count_players_final=merge(count_players_win,count_players_lose,by="player")
count_players_final$total_games=(count_players_final$n.x)+(count_players_final$n.y)
count_players1=subset(count_players_final,total_games>5)

# raw ratings 1 
raw_ratings1=merge(raw_ratings,count_players1,by="player")
raw_ratings1$adj_raw_rank=raw_ratings1$raw_rank/raw_ratings1$total_games
raw_ratings2=subset(raw_ratings1,select=c("player","raw_rank","adj_raw_rank","total_games"))

##5/30/18 clay ratings 
ratings_clay=subset(ratings_sub,surface=="Clay") #5491 matches

#winner score 
ratings_clay$winner_score=(ratings_clay$round_weight)*(ratings_clay$tourney_score)*(ratings_clay$player_lg_score)*(ratings_clay$date_weight)
#loser score
ratings_clay$loser_score=-(reciprocal(ratings_clay$round_weight)*reciprocal(ratings_clay$tourney_score)*reciprocal(ratings_clay$player_lg_score)*(ratings_clay$date_weight))

#i. 
#raw rankings (not controlling for surface)
winner_raw=ddply(ratings_clay,.(winner_name),plyr::summarize,winner_rank=sum(winner_score))
loser_raw=ddply(ratings_clay,.(loser_name),plyr::summarize,loser_rank=sum(loser_score))

names(winner_raw)[1]="player"
names(loser_raw)[1]="player"

raw_ratings=merge(winner_raw,loser_raw,by="player")
raw_ratings$raw_rank=(raw_ratings$winner_rank)-(raw_ratings$loser_rank)

#cut off games played
count_players_win<- ratings_clay%>%
  group_by(winner_name) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

count_players_lose<- ratings_clay%>%
  group_by(loser_name) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

names(count_players_win)[1]="player"
names(count_players_lose)[1]="player"

count_players_final=merge(count_players_win,count_players_lose,by="player")
count_players_final$total_games=(count_players_final$n.x)+(count_players_final$n.y)
count_players1=subset(count_players_final,total_games>1)

# raw ratings 1 
raw_ratings_clay1=merge(raw_ratings,count_players1,by="player")
raw_ratings_clay1$adj_raw_rank_clay=raw_ratings_clay1$raw_rank/raw_ratings_clay1$total_games
raw_ratings_clay2=subset(raw_ratings_clay1,select=c("player","raw_rank","adj_raw_rank_clay","total_games"))

#surface-"Clay"  "Grass" "Hard"  "None" 

#ii. Grass/Concrete 
ratings_hg=subset(ratings_sub,surface=="Grass"|surface=="Hard") #7949 matches
dim(ratings_hg)
#winner score 
ratings_hg$winner_score=(ratings_hg$round_weight)*(ratings_hg$tourney_score)*(ratings_hg$player_lg_score)*(ratings_hg$date_weight)
#loser score
ratings_hg$loser_score=-(reciprocal(-ratings_hg$round_weight)*reciprocal(ratings_hg$tourney_score)*reciprocal(ratings_hg$player_lg_score)*(ratings_hg$date_weight))

#i. 
#raw rankings (not controlling for surface)
winner_raw=ddply(ratings_hg,.(winner_name),plyr::summarize,winner_rank=sum(winner_score))
loser_raw=ddply(ratings_hg,.(loser_name),plyr::summarize,loser_rank=sum(loser_score))

names(winner_raw)[1]="player"
names(loser_raw)[1]="player"

raw_ratings=merge(winner_raw,loser_raw,by="player")
raw_ratings$raw_rank=(raw_ratings$winner_rank)-(raw_ratings$loser_rank)

#cut off games played
count_players_win<- ratings_hg%>%
  group_by(winner_name) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

count_players_lose<- ratings_hg%>%
  group_by(loser_name) %>%
  summarise(n=n()) %>%
  mutate(freq=n/sum(n))

names(count_players_win)[1]="player"
names(count_players_lose)[1]="player"

count_players_final=merge(count_players_win,count_players_lose,by="player")
count_players_final$total_games=(count_players_final$n.x)+(count_players_final$n.y)
count_players1=subset(count_players_final,total_games>1)

# raw ratings 1 
raw_ratings_hg1=merge(raw_ratings,count_players1,by="player")
raw_ratings_hg1$adj_raw_rank_hg=raw_ratings_hg1$raw_rank/raw_ratings_hg1$total_games
raw_ratings_hg2=subset(raw_ratings_hg1,select=c("player","raw_rank","adj_raw_rank_hg","total_games"))

#merge clay and (hard,grass) ratings
surface_ratings=merge(raw_ratings_hg2,raw_ratings_clay2,by="player")
surface_ratings1=subset(surface_ratings,select=c("player","adj_raw_rank_hg","adj_raw_rank_clay"))
#difference (grass,hard rating- clay rating )
surface_ratings1$diff=surface_ratings1$adj_raw_rank_hg-surface_ratings1$adj_raw_rank_clay


#surface ratings plot
library(plotly)
p=plot_ly(surface_ratings1,x=~surface_ratings1$adj_raw_rank_hg,
          y=~surface_ratings1$adj_raw_rank_clay,type='scatter',
          mode='markers',marker=list(size=~diff,opacity=0.3)) %>%
  layout(title='How Do Players Fair on Different Surfaces?',
         xaxis=list(showgrid=FALSE),
         yaxis=list(showgrid=FALSE))


ggplot(data=surface_ratings1, aes(x=adj_raw_rank_hg, y=adj_raw_rank_clay,color=diff)) +
  geom_point(aes(size=diff)) +         
  theme(legend.position = "none")+xlab("Adjusted Concrete/Grass Ranking")+
  ylab("Adjusted Clay Ranking")+geom_text(aes(label=ifelse(diff>5,as.character(player),'')),hjust=0,vjust=0)
