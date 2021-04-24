# load libraries
pacman::p_load(tidyverse, rvest, hansard, tictoc, beepr, here)


# pull vector of votes IDs in relevant time period
ids <- commons_divisions(start_date = "2015-05-07", end_date = "2017-06-08") %>% 
  pull(about)

mps <- read_html("https://labourlist.org/2016/03/leaked-list-ranks-labour-mps-by-hostility-to-corbyn/") %>% 
  html_node(xpath = "/html/body/div[5]/main/article/div/div[1]/div[1]/div[2]/table") %>% 
  html_table(header = T, fill = T) %>% 
  pivot_longer(everything(), "group",
               values_to = "mp") %>% 
  filter(mp != "")

# correct name shortenings and typos manually
mps$mp[mps$mp == "Alan Johnon"] <- "Alan Johnson"
mps$mp[mps$mp == "Ed Miliband"] <- "Edward Miliband"
mps$mp[mps$mp == "Catherine Smith"] <- "Cat Smith"
mps$mp[mps$mp == "Chinyelu Onwurah"] <- "Chi Onwurah"
mps$mp[mps$mp == "Elizabeth Kendall"] <- "Liz Kendall"
mps$mp[mps$mp == "Dave Anderson"] <- "David Anderson"
mps$mp[mps$mp == "Chinyelu Onwurah"] <- "Chi Onwurah"
mps$mp[mps$mp == "Catherin McKinnell"] <- "Catherine McKinnell"
mps$mp[mps$mp == "Chris Matheson"] <- "Christian Matheson"
mps$mp[mps$mp == "RIP Michael Meacher"] <- "Michael Meacher"
mps$mp[mps$mp == "Rebecca Long-Bailer"] <- "Rebecca Long Bailey"
mps$mp[mps$mp == "Gloria de Piero"] <- "Gloria De Piero"
mps$mp[mps$mp == "Ian Lucas"] <- "Ian C. Lucas"
mps$mp[mps$mp == "Jon Ashworth"] <- "Jonathan Ashworth"
mps$mp[mps$mp == "Huw Irrance-Davies"] <- "Ifor Irranca-Davies"
mps$mp[mps$mp == "Paula Sheriff"] <- "Paula Sherriff"
mps$mp[mps$mp == "Rob Flello"] <- "Robert Flello"
mps$mp[mps$mp == "Kate Hoey"] <- "Catharine Hoey"
mps$mp[mps$mp == "Naseem Shah"] <- "Naz Shah"
mps$mp[mps$mp == "Virenda Sharma"] <- "Virendra Sharma"
mps$mp[mps$mp == "Nia Giffith"] <- "Nia Griffith"
mps$mp[mps$mp == "Nick Brown"] <- "Nicholas Brown"

# duplicate name ids for removal
dupl <- c("http://data.parliament.uk/members/279",
          "http://data.parliament.uk/members/4170",
          "http://data.parliament.uk/members/134",
          "http://data.parliament.uk/members/311",
          "http://data.parliament.uk/members/1602",
          "http://data.parliament.uk/members/43",
          "http://data.parliament.uk/members/26",
          "http://data.parliament.uk/members/3899",
          "http://data.parliament.uk/members/532")

# first division
dat <- commons_divisions(ids[1]) %>%
  mutate(mp = if_else(member_printed_value == "Jack Dromey",
                                              "Jack Dromey", str_trim(str_remove_all(member_printed_value, ".*Mrs|Dr|Ms|Mr|Sir|Dame|Lord|Baroness")))) %>% 
  filter(mp %in% mps$mp) %>% 
  select(c(type, mp)) %>% right_join(mps)
names(dat)[1] <- paste("vote_", ids[1], sep = "")

# iterate other divisions
tic()
for (i in 2:length(ids)) {
  d <- commons_divisions(ids[i]) %>% 
    filter(!(about %in% dupl))
  
  if ("member_printed_value" %in% colnames(d)) {
    d <- mutate(d, mp = if_else(member_printed_value == "Jack Dromey",
                        "Jack Dromey", str_trim(str_remove_all(member_printed_value, ".*Mrs|Dr|Ms|Mr|Sir|Dame|Lord|Baroness"))))
  } else {
    mpvec <- d %>% pull(member_printed) %>% unlist %>% unique %>% 
      as.data.frame
    colnames(mpvec) <- "mp"
    d <- bind_cols(d, mpvec) %>% 
      mutate(mp = if_else(mp == "Jack Dromey",
                     "Jack Dromey", str_trim(str_remove_all(mp, ".*Mrs|Dr|Ms|Mr|Sir|Dame|Lord|Baroness"))))
  }
    d <- filter(d, mp %in% mps$mp) %>% 
    select(c(type, mp))
  
  names(d)[1] <- paste("vote_", ids[i], sep = "")
  
  dat <- dat %>% full_join(d) %>% distinct(mp, .keep_all = T)
}
toc()
beep()

# convert NAs to did not vote

dat <- dat %>% mutate_all(function(x) if_else(is.na(x), "Did_Not_Vote", x))

# write csv
write_csv(dat, "lab-divisions.csv")
