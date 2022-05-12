# Number of trees

Experiment 2



Load the libraries.



This line reads in the dataset that results from collating the results files for each participant.


```r
e2 <- readRDS("fgms_e2_allsubs.rds")
```
 
This renames the raw data but doesn't do any operations on it.


```r
# this tibble is one row for each tree visited saying whether it was a revisit or not
e2_revisits <-
  e2 %>%
  transmute(
    pp           = participant,
    trial        = trial_number,
    resources    = factor(R, levels=c(".pat","dis"), labels=c("clumped", "random")),
    stage        = as_factor(ifelse(trial<=10, "early", "late")),
    progress     = factor(trial),
    index        = index,
    tree         = tile,
    is_a_revisit = revisit
  )
```

Here
