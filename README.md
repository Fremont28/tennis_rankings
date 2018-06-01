# tennis_rankings
Building a tennis player ranking system 

As the best tennis players prepare for the upcoming summer season, we thought it might be fun to create a tennis win probability model. Our algorithm takes into account the round, tournament, adjusted opponent rank, and the date of when the match was played. The model is based on player match data from Jeff Sackman's Github page between January, 2016 through May 28th, 2018.

Below is the formula we used to calculate each player’s final ranking. To account for injuries and missed matches, we divided each player’s raw ranking by the number of matches played over this two-year plus period.

Players are assigned separate rankings depending on whether they won or lost the match. The player’s final ranking (for matches lost) is subtracted from his final ranking (for matches won) and divided by the number of matches played.

Adjusted Player Ranking=

Sigma (round weight* tournament weight *opponent weight *date weight) – (-round weight)* (1/tournament weight)*(1/opponent weight)*(date weight) ) / (matches  played)

This is the first iteration of the model and we may tweak the weights of tournaments, round, and date.

We also developed player rankings for clay and hard/grass surfaces. Obviously, surface has a big impact on player performance. Adjusting each player’s ranking based on surface should provide more accurate win probabilities in the model.

For example, Juan Martin Del Potro’s 20.2 adjusted grass/concrete ranking is 12.36 points better than his clay adjusted ranking! On the flip side, Rafael Nadal’s ranking jumps to +19.2 points on clay compared to grass/concrete surfaces.

Further, we weighted tournaments on three levels based on the average winning player ranking. This gives grand slam tournaments like the French Open and the U.S Open more importance than a tournament in Antwerp or Miami, which generally have a lower level of competition.
