#7/2/18 
library(randomForest)
tennis_wib=read.csv("ratings.csv")
tennis_wib$win=as.factor(tennis_wib$win)


model=randomForest(win~ player1+player2,data=tennis_wib,importance=TRUE,
                   ntree=500)
varImpPlot(model)
#predict with wimbledon 2018 (first round matchups)
wim_2018_x=subset(wim_2018,select=c(2,3))
wim_2018_x$predict_win=predict(model,wim_2018_x,type="prob")

