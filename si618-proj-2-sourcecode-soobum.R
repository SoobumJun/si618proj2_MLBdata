install.packages('Lahman')
setwd('~/Desktop/SI618/proj2/')
# install.packages("picante")
library(Lahman)
library(dplyr)
library(data.table)
library(ggplot2)
library(picante)

# load Batting data
data(Batting)
Batting

# extract salaries of all players 
salaries <- Salaries %>%
  select(playerID, yearID, teamID, salary)

peopleInfo <- People %>%
  select(playerID, birthYear, birthMonth, nameLast, 
         nameFirst, bats)

batting <- battingStats() %>% 
  left_join(salaries, 
            by =c("playerID", "yearID", "teamID")) %>%
  left_join(peopleInfo, by = "playerID") %>%
  mutate(age = yearID - birthYear - 
           1L *(birthMonth >= 10)) %>%
  arrange(playerID, yearID, stint)

## select player who have minimun At bat 520 (whicich is considered as eligible Batting average )
eligibleHitters <- batting %>%
  filter(yearID >= 1900 & PA > 520)

topHitters <- eligibleHitters %>%
  group_by(yearID) %>%
  filter(BA == max(BA)| BA >= .400) %>%
  select(playerID, yearID, nameLast, 
         nameFirst, BA)

# limit player who played after 2000 (since it has some)
topHitters <- topHitters %>%
  filter(yearID >= 2000)

# join salary to top hitters 
topHitters <- topHitters %>%
  left_join(salaries, 
            by =c("playerID", "yearID")) %>%
  arrange(yearID, playerID)
## impute missing value after googling 
topHitters$salary[20]<-4500000
topHitters$salary[21]<-20000000

## plotting 
ggplot(topHitters, aes(yearID))+
  geom_line(aes(y = BA, colour ='blue'), color = 'blue')+
  ggtitle('Top hitters vs BA in each season')+
  xlab('year')+
  ylab('Batting Average')


ggplot(topHitters, aes(yearID))+ 
  geom_line(aes(y = salary, color = 'blue'))+
  ggtitle('Top hitters salary in each season')+
  xlab('year')+
  ylab('salary')
  
  
  #batting avg vs salary
ggplot(topHitters, aes(x= salary, y =BA))+ geom_point()+
  xlab('Batting Average')+
  ylab('Salary')+
  ggtitle('Top Hitters BA vs Salary by each year')
cor.test(topHitters$BA, topHitters$salary)

#-> cannot observe any bigh difference of batting average and salary -> that is the reason why the money ball is important that findout undervalued feature can give better result for the team. ( putting and gaterhing player who have higher salaries are not always the solution for the team winning)

  
#### Q2 #### 
# team level data analysis 
# then which features are meaningful for predicting team won and lost
  # data explortaion
data(Teams)

## select column 
  # select after live ball era, and mutate new features 
teams <- Teams %>% 
  filter(yearID >= 1920 & lgID %in% c("AL", "NL")) %>%
  group_by(yearID, teamID) %>%
  mutate(BA = H/AB,
         TB = H + X2B + 2 * X3B + 3 * HR,
         WinPct = W/G,
         rpg = R/G,
         hrpg = HR/G,
         tbpg = TB/G,
         kpg = SO/G,
         k2bb = SO/BB,
         whip = 3 * (H + BB)/IPouts,
         SLG = TB/AB)
# drop the unnecessary columns
team <- teams %>%
select(-c(franchID,divID,teamIDBR,teamIDlahman45,teamIDretro,DivWin,WCWin, HBP, SF))
# View(team)


###1) H vs WPCT 
  #1-a
  # correlation and scatter plot
cor(team$H, team$WinPct)  # 0.3119283
cor(team$HA, team$WinPct) # -0.383275


  #scatter plot 
  ## H vs WinPct(Hit vs Winning percentage)
ggplot(team, aes(H, WinPct))+ 
  geom_point(size = 0.1) + 
  geom_smooth(method = lm, se = TRUE)+
  xlab("Winning Percentage")+
  ylab("Number of team Hit")



  ## HA vs WinPct(against team's Hit vs Winning Percentage )
ggplot(team, aes(HA, WinPct))+ 
  geom_point(size = 0.1) + 
  geom_smooth(method = lm, se = TRUE)+
  xlab("Winning Percentage")+
  ylab("Number of Against team Hit")




# running regression 
  #H as IV, and WinPct as DV 
team.Reg.H <- lm(WinPct~H, data = team)
summary(team.Reg.H)

  #HA as IV, ad WinPct as DV
team.Reg.HA <- lm(WinPct~HA, data = team)
summary(team.Reg.HA)

# multiple regression 
H.HA.team.Reg <- lm(WinPct~H+HA, data = team)
summary(H.HA.team.Reg)
  
# Scatter plot and correlation for Hit difference 
# find and add new variable
team <- team %>%
  mutate(HD = H-HA)
cor(team$HD, team$WinPct) # 0.787

ggplot(team, aes(x = HD, y = WinPct)) +
  geom_point(size = 0.1) +
  geom_smooth(method = lm, se = TRUE)+
  ylab('Winning Percentage of team')+
  xlab("Hit difference by teams")
str(team)

HD.team.Reg <- lm(WinPct~HD, data = team)
summary(HD.team.Reg)

# compute fitted values and redisuals from model
team$fitted.HD<-predict(HD.team.Reg)

team$residuals.HD<-residuals(HD.team.Reg)

  #residual plot
ggplot(team, aes(x = HD, y=residuals.HD))+
  geom_point(size = 0.3)+ geom_hline(yintercept=0, color = "red")

#calculate Root Mean Square Error (RMSE)
RMSE <- sqrt(mean(team$residuals.HD^2))
RMSE


## Q3 ## 
##  is a team salary cap correlated with the winning ratio? 

## merge batting and pitching, salary 
players <-  batting %>%
  left_join(Pitching, 
            by =c("playerID", "yearID")) %>%
  arrange(yearID, playerID)
# joing salary 
players <- players %>%
  inner_join(salaries,
             by = c("playerID", "yearID"))%>%
  arrange(yearID,playerID)

players <- players %>%
  select(c(playerID, year, teamID, salary.y))
# groupby team to calculate team salary cap
players
players<-setnames(players, old = c('salary.y'), new = c('salary'))
players

salary.cap<- players %>%
  group_by(yearID,teamID)%>%
  summarise(sum.salary = sum(salary, na.rm = TRUE))
salary.cap  

team.Wpct <- teams %>%
  select(c(yearID,teamID, WinPct))

salary.cap <- salary.cap %>%
  inner_join(team.Wpct,
             by = c('yearID','teamID'))
salary.cap <-na.omit(salary.cap)
salary.cap

# find years 
# correlation test by year
years<-unique(salary.cap$yearID)

for (year in years){
  sorted <- salary.cap %>% filter(yearID == year)
  print(year)
  print(cor.test(sorted$sum.salary,sorted$WinPct))
  }
## there are less correlation betwwen salary and team winning
