library(standardize)
library(tidyverse)

e2allsubs = tibble() 
outfilecontent = tibble()
indir = "e2_csvs"
for (infilename in list.files(indir, pattern=".csv$")) {
  infilecontent = read_csv(file.path(indir, infilename), col_types = cols())
  outfilecontent <-
    infilecontent %>%
    filter(bg_type != "practice") %>%
    transmute(
      experiment         = 2,
      participant        = as.numeric(substr(participant, 2, 4)),
      V                  = tree_behaviour,
      R                  = resource_distribution,
      L                  = ifelse(flag==2, "fruit", "no_fruit"),
      trial_number       = trial_number,
      index              = sample,
      time               = secs_elapsed,
      x                  = as.integer(round(x)),
      y                  = as.integer(round(y)),
      tile               = (((row-1) * 16) + col),
      flag               = flag,
      nfruit             = fruits
    )
  outfilecontent <-
    outfilecontent %>%
    group_by(participant, R, V, trial_number) %>%
    arrange(index, .by_group=TRUE) %>%
    mutate(time = time-time[1]) %>%
    filter(flag %in% c(1, 2, 3)) %>%
    filter(max(nfruit) >= 14) %>%
    filter(is.na(tile != lag(tile)) | tile != lag(tile)) %>%      # remove the second (and any subsequent) *consecutive* duplicates
    mutate(revisit      = as.numeric(duplicated(tile))) %>%            # identify as TRUE the second (and any subsequent) duplicates whether they are consecutive or not (i.e, memory errors, now called revisits)
    mutate(revisits     = sum(revisit)) %>%
    mutate(numtrees     = n()) %>%
    mutate(trialdur     = round(max(time),2)) %>%
    mutate(itdist       = round(sqrt((lead(x)-x)^2 + (lead(y)-y)^2), 2)) %>%  # inter-tree distance
    mutate(index        = seq_along(index)) %>%
    ungroup()
  # how many trees to get each fruit?
  outfilecontent$rateaq = NA
  j = 0
  for (k in seq_along(outfilecontent$index)) {
    j = j + 1
    if (outfilecontent[k, 'flag'] ==2) {
      outfilecontent[k, 'rateaq'] = j
      j = 0
    }
  }
  message(paste(substr(infilename, 1, 4), "done"))
  e2allsubs <- bind_rows(e2allsubs, outfilecontent)
}
e2allsubs               <- e2allsubs %>% select(-c(V, R), c(R, V))
e2allsubs$R             <- plyr::revalue(e2allsubs$R, c("patchy"=".pat", "dispersed"="dis"))
e2allsubs$R             <- named_contr_sum(e2allsubs$R, return_contr = FALSE)
e2allsubs$V             <- plyr::revalue(e2allsubs$V, c("fade"=".fade", "no_fade"="nofade"))
e2allsubs$V             <- named_contr_sum(e2allsubs$V, return_contr = FALSE)
e2allsubs$L             <- plyr::revalue(e2allsubs$L, c("fruit"=".frt", "no_fruit"="nofrt"))
e2allsubs$L             <- named_contr_sum(e2allsubs$L, return_contr = FALSE)
e2allsubs$trl           <- as.numeric(scale(e2allsubs$trial_number))
saveRDS(e2allsubs, "fgms_e2_allsubs.rds")