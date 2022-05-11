library(reticulate)
library(tidyverse)
library(standardize)

if (Sys.info()[['sysname']]=="Windows"){
  source_python("dos2unix.py")
}
e1allsubs = tibble()
outf = tibble()
indir = "e1_pickles"
numberoftrials = 20
for (infilename in list.files(indir, pattern=".pickle$")) {
  i = 0
  if (Sys.info()[['sysname']]=="Windows"){
    dos2unix(
      file.path(indir, infilename),
      file.path("temporary.pickle")
    )
    infilecontent <- py_load_object(file.path("temporary.pickle"))
    unlink("temporary.pickle")
  } else {
    infilecontent <- py_load_object(file.path(indir, infilename))
  }
  for (trialnumber in 1:numberoftrials) {
    trialnumber <- as.character(trialnumber)
    samples  <- names(infilecontent[[trialnumber]][['samples']])
    for (samplenumber in samples) {
      i <- i + 1
      outf[i, "experiment"]          = 1
      outf[i, 'pid']                 = infilecontent[[trialnumber]][['participant_number']]
      outf[i, 'R']                   = ifelse(grepl("cluster", infilecontent[[trialnumber]][['trial_name']]), "clumped", "random")
      outf[i, 'trial_in_session']    = infilecontent[[trialnumber]][['trial_num_in_expt']]
      outf[i, 'trial']               = infilecontent[[trialnumber]][['trial_num_in_block']]
      outf[i, 'trial_identity']      = infilecontent[[trialnumber]][['trial_name']]
      outf[i, 'index']               = infilecontent[[trialnumber]][['samples']][[samplenumber]]$sample_index
      outf[i, 'time']                = infilecontent[[trialnumber]][['samples']][[samplenumber]]$sample_timestamp
      outf[i, 'x']                   = infilecontent[[trialnumber]][['samples']][[samplenumber]]$psychopy_x
      outf[i, 'y']                   = infilecontent[[trialnumber]][['samples']][[samplenumber]]$psychopy_y
      outf[i, 'tile']                = infilecontent[[trialnumber]][['samples']][[samplenumber]]$hit_tile + 1
      outf[i, 'flag']                = infilecontent[[trialnumber]][['samples']][[samplenumber]]$hit_flag
      outf[i, 'basket']              = infilecontent[[trialnumber]][['samples']][[samplenumber]]$fruit_tally
    }
  }
  if (infilename == "P009.pickle") {
    outf$pid = 9; 
    message(paste0("... P009 correcting the error vlada made ",
                   "when she called p9 p10 and corrected it in the csv but ",
                   "obviously couldn't do that in the pickle"))
  }
  
  # files saved by pickle are in arbitrary (though often deceptively sane) row order
  # so we need to sort on row order after grouping to identify each trial
  # This sequence of tidyverse operations also does a lot of other stuff...
  outf <-
    outf %>%
    group_by(R, pid, trial) %>%
    arrange(index, .by_group=TRUE) 
  
  outf <- outf %>%
    mutate(time = time-time[1]) %>%
    filter(flag %in% c(1, 2, 3)) %>%
    filter(max(basket) >= 10) %>%
    # remove the second (and any subsequent) *consecutive* duplicates
    filter(is.na(tile != lag(tile)) | tile != lag(tile)) %>%
    # identify as TRUE the second (and any subsequent) duplicates whether 
    # they are consecutive or not (i.e, memory errors)
    mutate(revisit = as.numeric(duplicated(tile))) %>%           
    mutate(numtrees = n()) %>%
    mutate(trialdur = round(max(time),2)) %>%
    mutate(itdistance = round(sqrt((lead(x)-x)^2 + (lead(y)-y)^2), 2)) %>%
    mutate(index = seq_along(index)) %>%
    ungroup()
  # how many trees to get each fruit?
  outf$ntreesperfruit = NA
  j = 0
  for (k in seq_along(outf$index)) {
    j = j + 1
    if (outf[k, 'flag'] ==2) {
      outf[k, 'ntreesperfruit'] = j
      j = 0
    }
  }
  # all done
  message(paste(substr(infilename, 1, 4), "done"))
  e1allsubs <- bind_rows(e1allsubs, outf)
}
e1allsubs             <- e1allsubs %>% select(-R, R) 
e1allsubs$experiment  <- as_factor(e1allsubs$experiment)
e1allsubs$pid         <- as_factor(e1allsubs$pid)
e1allsubs$flag        <- as_factor(e1allsubs$flag)
e1allsubs$R           <- named_contr_sum(e1allsubs$R, return_contr = FALSE)
e1allsubs$L           <- ifelse(e1allsubs$flag==2, "fruit", "not_fruit")
e1allsubs$L           <- named_contr_sum(e1allsubs$L, return_contr = FALSE)
saveRDS(e1allsubs, "fgms_e1_allsubs.rds")
