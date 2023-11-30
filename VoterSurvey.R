#Author: emmcavoy
#Last modified 5/1/22
#This script analyzes voting behavior in the U.S. 2016 presidential election using data from the VOTER (Views of the Electorate Research) Survey

#Required libraries
#Script created in R 4.1.2
library(tidyverse)
data <- read.csv('VOTER_Survey_December16_Release1.csv')
mod_data <- data

#2016 Presidential Vote
mod_data$presvote16_group <- mod_data$presvote16post_2016
mod_data[mod_data$presvote16post_2016=='','presvote16_group'] <- 'Missing'
mod_data[mod_data$presvote16post_2016=='Did not vote for President','presvote16_group'] <- "Didn't Vote"
mod_data[mod_data$presvote16post_2016=='Evan McMullin' | mod_data$presvote16post_2016=='Gary Johnson' | mod_data$presvote16post_2016=='Gary Johnson'| mod_data$presvote16post_2016=='Jill Stein','presvote16_group'] <- 'Other'
mod_data[mod_data$presvote16post_2016=='Donald Trump','presvote16_group'] <- 'Trump'
mod_data[mod_data$presvote16post_2016=='Hillary Clinton','presvote16_group'] <- 'Clinton'
mod_data$presvote16_group <- factor(mod_data$presvote16_group,levels=c('Trump','Clinton','Other','Missing',"Didn't Vote"))
ggplot(mod_data,aes(x=presvote16_group))+geom_bar(fill=c('#FF3300','#3366FF','#006600','#171717','#808080'))+labs(x='Candidate',y='Number of Votes',title='Number of Votes by Candidate in 2016 Presidential Election')

#2016 Presidential Vote by Voter Party
#2016 pid7 into Democrat, Republican, Independent, Not sure
mod_data$pid7collapse_2016 <- mod_data$pid7_2016
mod_data[mod_data$pid7collapse_2016=='Strong Democrat' | mod_data$pid7collapse_2016=='Not very strong Democrat' | mod_data$pid7collapse_2016=='Lean Democrat','pid7collapse_2016'] <- 'Democrat'
mod_data[mod_data$pid7collapse_2016=='Strong Republican' | mod_data$pid7collapse_2016=='Not very strong Republican' | mod_data$pid7collapse_2016=='Lean Republican','pid7collapse_2016'] <- 'Republican'
table(mod_data$pid7collapse_2016)
mod_data$pid7collapse_2016 <- factor(mod_data$pid7collapse_2016,levels=c('Democrat','Republican','Independent','Not sure'))

ggplot(mod_data,aes(fill=pid7collapse_2016,x=presvote16_group))+geom_bar()+scale_fill_manual(values=c("#3366FF","#FF3300",'#006600','#666666'))+labs(x='Candidate',y='Number of Votes',title='2016 Presidential Election Votes by Voter Party',fill='Voter Self-Identified Party')
table(mod_data$pid7collapse_2016,mod_data$presvote16_group)
prop.table(table(mod_data$pid7collapse_2016,mod_data$presvote16_group),2)*100

#2016 Presidential Vote by Voter Race
ggplot(mod_data,aes(fill=race_2016,x=presvote16_group))+geom_bar()+labs(x='Candidate',y='Number of Votes',title='2016 Presidential Election Votes by Voter Race',fill='Voter Self-Identified Race')
table(mod_data$race_2016,mod_data$presvote16_group)
prop.table(table(mod_data$race_2016,mod_data$presvote16_group),2)*100

#2016 Presidential Vote by Voter Educational Attainment
mod_data$educ_2016 <- factor(mod_data$educ_2016,levels=c('No HS','High school graduate','Some college','2-year','4-year','Post-grad'))
ggplot(mod_data,aes(fill=educ_2016,x=presvote16_group))+geom_bar()+labs(x='Candidate',y='Number of Votes',title='2016 Presidential Election Votes by Voter Educational Attainment',fill='Voter Self-Identified Educational Attainment')
table(mod_data$educ_2016,mod_data$presvote16_group)
prop.table(table(mod_data$educ_2016,mod_data$presvote16_group),2)*100

#2016 Presidential Vote by Voter Gender
ggplot(mod_data,aes(fill=gender_baseline,x=presvote16_group))+geom_bar()+labs(x='Candidate',y='Number of Votes',title='2016 Presidential Election Votes by Voter Gender',fill='Voter Self-Identified Gender')
table(mod_data$gender_baseline,mod_data$presvote16_group)
prop.table(table(mod_data$gender_baseline,mod_data$presvote16_group),2)*100