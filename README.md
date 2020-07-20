# MLB data analysis project

#### Motivation 
I have been interested in baseball since childhood, so I memorized all the stats of players on my favorite baseball team. In college, after I became a captain in the college baseball club, I got more interested in the baseball strategy and stats. In particular, I found out that the professional baseball team I was cheering for had high salaries for individual players but did not perform well. At this time, I saw a movie called Moneyball. After read and watch at the Moneyball, each player's stats are vital, but I am also found out there are other hidden variables that can predict the game result with saving management cost of the team while finding out undervalued, but a high performed player. In this project, I aim to find out the hidden variable that can predict the game result.

Also, baseball is a game where data is more important than any other sport. Therefore, players having good stats are getting paid a good salary accordingly. However, there are many opinions on whether a player with a high salary does affect team victory. Accordingly, I will also explore the correlation between individual players’ salaries correlate with or affect team winning.

Question 1 : Which player have a higher batting average? Is top hitter always paid higher salary?

Question 2 : What type of variables has considerably predict the team winning?

Question 3 : Is the total salary of players in the team correlated with the winning ratio?


#### Data Sources 
Lahman Dataset (http://www.seanlahman.com/, included in R as R package) 

Lahman's data set is gathered by Sean Lahman, the famous sports reporter. This well-known Lahman data set is included in R as packages. The database contains 30 tables. It contains all the information on players’ and teams’ batting, salary, team and fielding performance, and other tables from 1871 through 2018, as recorded in the 2019 version of the database. I will use the recent data for all years for consistency of the result; then, I manipulate it depends on each question's characteristics. Likewise, I use this dataset to extract which features are essential to predict the team winning percentage, and exploring which features are considered important with a marketing and team management perspective. 

* Note that the Lahman data set is included in R as a package, you need to install packages in R using install.packages(‘Lahman’) and library(Lahman) instead, you download the whole dataset on the Lahman website.

