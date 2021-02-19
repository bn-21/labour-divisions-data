#load libraries
library(tidyverse)
library(rvest)
library(hansard)
library(tictoc)
library(beepr)


#pull vector of votes IDs in relevant time period
ids <- commons_divisions(end_date = "2016-03-23") %>% 
  pull(about)

mps <- read_html("https://labourlist.org/2016/03/leaked-list-ranks-labour-mps-by-hostility-to-corbyn/") %>% 
  html_node(xpath = "/html/body/div[5]/main/article/div/div[1]/div[1]/div[2]/table") %>% 
  html_table(header = T, fill = T) %>% 
  pivot_longer(everything(), "group",
               values_to = "mp") %>% 
  filter(mp != "")
mps$mp[mps$mp == "Alan Johnon"] <- "Alan Johnson" #correct typo in article

#first division
dat <- commons_divisions(ids[1]) %>%
  mutate(mp = str_trim(str_remove_all(label_value, ".*for|Mr|Dr|Ms|Mrs|Sir|Dame|Lord|Baroness"))) %>% 
  filter(mp %in% mps$mp) %>% 
  select(c(type, mp))
names(dat)[1] <- paste("vote_", ids[1])

#iterate other divisions
tic()
for (i in 2:length(ids)) {
  d <- commons_divisions(ids[i]) %>%
    mutate(mp = str_trim(str_remove_all(label_value, ".*for|Mr|Dr|Ms|Mrs|Sir|Dame|Lord|Baroness"))) %>% 
    filter(mp %in% mps$mp) %>% 
    select(c(type, mp))
  
  names(d)[1] <- paste("vote_", ids[i])
  
  dat <- dat %>% full_join(d) %>% distinct(mp, .keep_all = T)
}
toc()
beep()

#join with mp group

dat <- dat %>% left_join(mps)

#write csv
write_csv(dat, "lab-divisions.csv")
