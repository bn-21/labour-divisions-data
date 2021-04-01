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

#correct name shortenings manually
mps$mp[mps$mp == "Ed Miliband"] <- "Edward Miliband"
mps$mp[mps$mp == "Catherine Smith"] <- "Cat Smith"
mps$mp[mps$mp == "Chinyelu Onwurah"] <- "Chi Onwurah"
mps$mp[mps$mp == "Elizabeth Kendall"] <- "Liz Kendall"
mps$mp[mps$mp == "Dave Anderson"] <- "David Anderson"
mps$mp[mps$mp == "Chinyelu Onwurah"] <- "Chi Onwurah"
mps$mp[mps$mp == "Catherin McKinnell"] <- "Catherine McKinnell"
mps$mp[mps$mp == "Frank Field"] <- "Field of Birkenhead"
mps$mp[mps$mp == "Graham Jones"] <- "Graham P Jones"
mps$mp[mps$mp == "Chris Matheson"] <- "Christian Matheson"
mps$mp[mps$mp == "RIP Michael Meacher"] <- "Michael Meacher"
mps$mp[mps$mp == "Ian Austin"] <- "Austen of Dudley"
mps$mp[mps$mp == "Chinyelu Onwurah"] <- "Chi Onwurah"
mps$mp[mps$mp == "Rebecca Long-Bailer"] <- "Rebecca Long-Bailey"
mps$mp[mps$mp == "Gloria de Piero"] <- "Gloria De Piero"
mps$mp[mps$mp == "John Woodcock"] <- "Walney"
mps$mp[mps$mp == "Ian Lucas"] <- "Ian C. Lucas"
mps$mp[mps$mp == "Jenny Chapman"] <- "Chapman of Darlington"
mps$mp[mps$mp == "Gloria de Piero"] <- "Gloria De Piero"
mps$mp[mps$mp == "John Mann"] <- "Mann"
mps$mp[mps$mp == "Stuart"] <- "Stewart of Edgbaston"
mps$mp[mps$mp == "Jon Ashworth"] <- "Jonathan Ashworth"
mps$mp[mps$mp == "Huw Irrance-Davies"] <- "Huw Irranca-Davies"
mps$mp[mps$mp == "Paula Sheriff"] <- "Paula Sherriff"
mps$mp[mps$mp == "Rob Flello"] <- "Robert Flello"
mps$mp[mps$mp == "Kate Hoey"] <- "Hoey"
mps$mp[mps$mp == "Sue Hayman"] <- "Hayman of Ullock"
mps$mp[mps$mp == "Vernon Coaker"] <- "Coaker"
mps$mp[mps$mp == "Naseem Shah"] <- "Naz Shah"
mps$mp[mps$mp == "Virenda Sharma"] <- "Virendra Sharma"
mps$mp[mps$mp == "Nia Giffith"] <- "Nia Griffith"
mps$mp[mps$mp == "Nick Brown"] <- "Nicholas Brown"


#first division
dat <- commons_divisions(ids[1]) %>%
  mutate(mp = if_else(label_value == "Biography information for Clive Efford",
                      "Clive Efford",
                      if_else(label_value == "Biography information for Clive Efford",
                                              "Jack Dromey", "Jack Dromey", str_trim(str_remove_all(label_value, ".*for|Mrs|Dr|Ms|Mr|Sir|Dame|Lord|Baroness"))))) %>% 
  filter(mp %in% mps$mp) %>% 
  select(c(type, mp)) %>% left_join(mps)
names(dat)[1] <- paste("vote_", ids[1])

#iterate other divisions
tic()
for (i in 2:length(ids)) {
  d <- commons_divisions(ids[i]) %>%
    mutate(mp = str_trim(str_remove_all(label_value, ".*for|Mrs|Dr|Ms|Mr|Sir|Dame|Lord|Baroness"))) %>% 
    filter(mp %in% mps$mp) %>% 
    select(c(type, mp))
  
  names(d)[1] <- paste("vote_", ids[i])
  
  dat <- dat %>% full_join(d) %>% distinct(mp, .keep_all = T)
}
toc()
beep()

# remove whitespace from variable names
colnames(dat) <- str_remove_all(colnames(dat), " ")

#write csv
write_csv(dat, "lab-divisions.csv")
