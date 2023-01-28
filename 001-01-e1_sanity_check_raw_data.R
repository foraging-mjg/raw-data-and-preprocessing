library(tidyverse)
options(dplyr.summarise.inform=F)

e1 <- readRDS("001-00-e1-data.RDS")

# check dimensions
print(paste("dimensions: "))
print(dim(e1))
cat("\n")

# test for duplicated rows
print(paste("number of duplicate rows in the whole set =", sum(duplicated(e1))))
cat("\n")

# test for strictly increasing time (tm)
test_row_sanity <- 
  e1 %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  mutate(validrow = tm > lag(tm, default=TRUE)) %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  summarise(nfails=sum(validrow==FALSE)) %>% 
  group_by(ex,pp,te,rr,tb) %>% 
  summarise(failed_trial = as.logical(sum(nfails>0))) %>% 
  ungroup()
n_bad_row_order_trials <- test_row_sanity %>% 
  summarise(n_bad_row_order_trials=sum(failed_trial))
print(n_bad_row_order_trials)


# test for strictly increasing ix
test_row_ix <-
  e1 %>% 
  group_by(pp,te) %>% 
  mutate(ok = ix==lag(ix)+1) %>% 
  summarise(badix=sum(ok==FALSE,na.rm=TRUE)) %>% 
  group_by(pp,te) %>%
  summarise(badix_trial=badix>0) %>% 
  ungroup()
n_bad_index_trials <- test_row_ix %>% 
  summarise(n_bad_ix_trials=sum(badix_trial))
print(n_bad_index_trials)
