#functions for model weights 
# 6/1/18 
tennis=pd.read_csv("tennis_sub1.csv")
tennis.head(4)

#split players into groups based on rank 
def player_rank(rank):
    if rank <=11:
        return "g1"
    if rank<=50 and rank>10:
        return "g2"
    if rank<=100 and rank>50:
        return "g3"
    if rank<=150 and rank>100:
        return "g4"
    if rank<=200 and rank>150:
        return "g5"
    if rank<=250 and rank>200:
        return "g6"
    else:
        return "g7"
       
tennis['player_win_group']=tennis['winner_rank'].apply(player_rank) 
tennis['player_lose_group']=tennis['loser_rank'].apply(player_rank)

tennis['tourney_date_ext'].unique() 
tennis['tourney_date_ext']=tennis.tourney_date_ext.astype('int')
tennis.info()

#round score weights (i.e. finals valued more than round of 64)
tennis['round'].unique() 

def round_score(round):
    if round=="F":
        return 5
    if round=="SF":
        return 5
    if round=="QF":
        return 3
    if round=="R32":
        return 1.5
    if round=="Q3":
        return 1.5
    if round=="Q2":
        return 1.5
    if round=="Q1":
        return 1.5
    if round=="R64":
        return 1
    if round=="R128":
        return 0.5
    else:
        return 1 

tennis['round_weight']=tennis['round'].apply(round_score)
tennis.to_csv("tennis_toes.csv")

#opponent score ranking weights 
def opp_scores(group):
    if group=="g1":
        return 2.58
    if group=="g2":
        return 1.55 
    if group=="g3":
        return 1.39 
    if group=="g4":
        return 1.24
    if group=="g5":
        return 1.14
    if group=="g6":
        return 0.92
    else:
        return 0.81

tennis['player_wg_score']=tennis['player_win_group'].apply(opp_scores)
tennis['player_lg_score']=tennis['player_lose_group'].apply(opp_scores)
tennis.to_csv("tennis_final.csv")

tennis_dates=pd.read_csv("dates_tennis.csv") 

def dates_weight(date):
    if date==2016:
        return 1
    if date==2017:
        return 2
    if date==2018:
        return 3 

tennis_dates['date_weight']=tennis_dates['x'].apply(dates_weight)
tennis_dates.to_csv("tennis_dates.csv")

#assign tourney score
tennis1=pd.read_csv("tennis_final1.csv")
tennis1.info() 

#weight date of the match 
def tourney_score(score):
    if score<=50:
        return 4
    if score>50 and score<=75:
        return 3
    if score>75 and score<=100:
        return 2
    else:
        return 1

tennis1['tourney_score']=tennis1['win_rank'].apply(tourney_score) 
tennis1.to_csv("tennis_final_actual1.csv")   










