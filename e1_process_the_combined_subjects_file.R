# The aim here is to go from 
# row-per-eyetracker-sample
# to
# row-per-discrete-tree-visit-event
#
# Things that need to happen are:
# 1. Make sure that cases where they got a fruit on the first tree they looked at 
# are handled appropriately to avoid structural missings
# 2. Annotate trials that didn't get the requisite ten fruit instead of removing them, 
# to avoid structural missings
#
# [x] inertia - Collapse consecutive samples in the same place down to a single row instead of multiple rows
# [ ] Get rid of rows (after collapsing down to single rows) that weren't in a tree
# [x] identify revisits
# [ ] How many trees to get each fruit?

# [ ] inter-tree distance - after getting to row-per-tree-visit
# [ ] mark failed trials (less than 10 fruit)


e1 <- readRDS("fgms_e1_allsubs_stage_1.rds")

# Identify inertia - where this row's sample is in the same tile 
# as the previous row's sample
a1 <- e1 %>% 
  group_by(pid, R, trial) %>% 
  mutate(inertia = tile == lag(tile, default=FALSE)) 

# Remove rows with inertia
# aka "collapse same-place samples"
a2 <- a1 %>% 
  ungroup() %>% 
  filter(inertia == FALSE)

# Identify each revisit - where an initial visit is followed 
# by any other visits in the same trial
# * what about revisits where youre revisting somewehere 
# while you;re oon the same fruit - this one doesnlt make much sense
b1 <- a2 %>%
  group_by(pid, R, trial) %>% 
  mutate(revisit = duplicated(tile))   

# Remove samples that werent't in a tree UNLESS ITS THE FIRST SAMPLE
# i.e., AVOID STRUCTURAL MISSINGs
# Step 1 make column with 'deleteme' status of TRUE/FALSE
# Step 2 filter to retain only deleteme of FALSE
c1 <- b1 %>% 
  ungroup() %>% 
  # set deleteme TRUE if sample not in a tree
  mutate(deleteme = flag==0) %>% 
  # but set deleteme FALSE if it's the first sample and basket is 0
  mutate(deleteme = ifelse(index==1 & basket==0, FALSE, deleteme)) 
c2 <- c1 %>%
  ungroup() %>% 
  filter(deleteme == FALSE)




saveRDS(stage2, "fgms_e1_allsubs.rds")