library(reticulate)
library(tidyverse)
library(tictoc)
library(crayon)

tic()

if (Sys.info()[['sysname']]=="Windows"){
  source_python("dos2unix.py")
}

e1allsubs = tibble()
indir = "e1_pickles"
numberoftrials = 20

for (infilename in list.files(indir, pattern=".pickle$")) {
  
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
    samples <- names(infilecontent[[trialnumber]][['samples']])
    content <- infilecontent[[trialnumber]] # a list
    content$tile_centres=NULL
    outf = tibble()
    i=0 # sequential index for samples
    for (samplenumber in samples) {
      i <- i + 1
      outf[i, "ex"] = 1
      outf[i, 'pp'] = content[['participant_number']]
      if(infilename == "P009.pickle"){outf[i, 'pp'] = 9}
      outf[i, 'rr'] = ifelse(grepl("cluster", content[['trial_name']]), "patchy", "dispersed")
      outf[i, 'tb'] = content[['trial_num_in_block']]
      outf[i, 'te'] = paste(ifelse(outf[i, 'rr']=="dispersed", 'd', 'p'), str_pad(outf[i, 'tb'],2,'left',"0"),sep=":")
      outf[i, "st"] = ifelse(content[['trial_num_in_block']] <=5, "early", "late")
      outf[i, 'ix'] = content[['samples']][[samplenumber]]$sample_index
      outf[i, 'tm'] = content[['samples']][[samplenumber]]$sample_timestamp
      outf[i, 'xx'] = content[['samples']][[samplenumber]]$psychopy_x
      outf[i, 'yy'] = content[['samples']][[samplenumber]]$psychopy_y
      outf[i, 'll'] = ifelse(content[['samples']][[samplenumber]]$hit_flag==2, "fruit", "not")
      outf[i, 'tl'] = content[['samples']][[samplenumber]]$hit_tile + 1 # + 1 to turn zero-indexed into human indexed
      outf[i, 'fl'] = content[['samples']][[samplenumber]]$hit_flag
      outf[i, 'fr'] = content[['samples']][[samplenumber]]$fruit_tally
    } # end of loop through samples
    
    m = paste("subject", substr(infilename, 1, 4), "trial", str_pad(trialnumber,2,"left"," "), "size", str_pad(nrow(outf),3,"left"," "))
    message(blue(m), appendLF = FALSE)
    
    message(blue("\tcorrecting row order and making index strictly sequential"))
    outf <- outf %>% 
      arrange(tm) %>%              # correct for bad row-order 
      mutate(ix = seq_along(tm))   # correct for where ix skips (i.e., where it has non-strictly-incrementing-by-one order)
    
    # add this participant to the allsubs tibble
    e1allsubs <- bind_rows(e1allsubs, outf)

  } # end of loop through trials
  
  # this participant is finished - go back for the next one after adding to allsubs
  message(green(paste(substr(infilename, 1, 4), "done")))
}

# all participants are done
message(green("all subjects done"))
#save out
saveRDS(e1allsubs, "001-00-e1-data.RDS")

source("001-01-e1_sanity_check_raw_data.R")
