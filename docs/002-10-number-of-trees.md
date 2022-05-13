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
e2_ntrees <-
  e2 %>%
  transmute(
    pp           = as_factor(participant),
    trial        = trial_number,
    resources    = factor(R, levels=c(".pat","dis"), labels=c("clumped", "random")),
    fading       = factor(V, levels=c(".fade","nofade"), labels=c("fade", "no_fade")),
    stage        = as_factor(ifelse(trial<=10, "early", "late")),
    progress     = factor(trial),
    index        = index,
    tree         = tile)
```

## Aggregation 1: 

The data has a row for each tree visited. We want a trial level count of the number of trees visited. 


```r
TRIAL_SUMS <- 
  e2_ntrees %>% 
  group_by(pp, resources, stage, fading, trial, progress) %>% 
  summarise(trees=n())
```
                                
## Aggregation 2:


```r
PARTICIPANT_MEANS <-
  TRIAL_SUMS %>% 
  group_by(pp, resources, stage, fading) %>% 
  summarise(mean_trees_per_stage = mean(trees))
```

## Aggregation 3:


```r
CONDITION_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(resources, stage, fading) %>% 
  summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage)) 

RESOURCES_FADING_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(resources, fading) %>% 
  summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage))

RESOURCES_STAGE_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(resources, stage) %>% 
  summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage))
  
STAGE_FADING_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(stage, fading) %>% 
  summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage))
  
RESOURCES_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(resources) %>% 
    summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage))

STAGE_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(stage) %>% 
    summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage))

FADING_MEANS <-
  PARTICIPANT_MEANS %>% 
  group_by(fading) %>% 
    summarise(mean = mean(mean_trees_per_stage), sd = sd(mean_trees_per_stage))
```

## Descriptives


```r
CONDITION_MEANS %>% gt(groupname_col = "resources") %>% fmt_number(columns = c("mean","sd"), decimals=2) %>% tab_header("Number of trees") %>%  gtsave("e2_tables/ntrees_condition_means.png")
```

<img src="e2_figures/unnamed-chunk-7-1.png" width="33%" />


```r
RESOURCES_FADING_MEANS %>% gt(groupname_col = "resources") %>% fmt_number(columns = c("mean","sd"), decimals=2) %>% tab_header("Number of trees") %>% gtsave("e2_tables/ntrees_resources_fading_means.png")
```

<img src="e2_figures/unnamed-chunk-8-1.png" width="33%" />


```r
RESOURCES_STAGE_MEANS %>% gt(groupname_col = "resources") %>% fmt_number(columns = c("mean","sd"), decimals=2) %>% tab_header("Number of trees") %>% gtsave("e2_tables/ntrees_resources_stage_means.png")
```

<img src="e2_figures/unnamed-chunk-9-1.png" width="33%" />


```r
STAGE_FADING_MEANS %>% gt(groupname_col = "stage") %>% fmt_number(columns = c("mean","sd"), decimals=2) %>% tab_header("Number of trees") %>% gtsave("e2_tables/ntrees_stage_fading_means.png")
```

<img src="e2_figures/unnamed-chunk-10-1.png" width="33%" />


```r
RESOURCES_MEANS %>% gt() %>% fmt_number(columns = c("mean","sd"), decimals=2) %>%  tab_header("Number of trees") %>% gtsave("e2_tables/ntrees_resources_means.png")
```

<img src="e2_figures/unnamed-chunk-11-1.png" width="33%" />


```r
STAGE_MEANS %>% gt() %>% fmt_number(columns = c("mean","sd"), decimals=2) %>%  tab_header("Number of trees") %>% gtsave("e2_tables/ntrees_stage_means.png")
```

<img src="e2_figures/unnamed-chunk-12-1.png" width="33%" />


```r
FADING_MEANS %>% gt() %>% fmt_number(columns = c("mean","sd"), decimals=2) %>%  tab_header("Number of trees") %>% gtsave("e2_tables/ntrees_fading_means.png")
```

<img src="e2_figures/unnamed-chunk-13-1.png" width="33%" />

## ANOVA with resources and stage within-subjects and fading between-subjects


```r
options(contrasts=c("contr.sum","contr.poly"))
ez_ntrees <- ezANOVA(data=PARTICIPANT_MEANS,
               dv=mean_trees_per_stage,
               wid=pp,
               within=c(resources,stage),
               between=fading,
               type=3)
#> Warning: Data is unbalanced (unequal N per group). Make sure
#> you specified a well-considered value for the type argument
#> to ezANOVA().
```

<img src="e2_figures/unnamed-chunk-15-1.png" width="33%" />

## Plots

<img src="e2_figures/unnamed-chunk-16-1.png" width="50%" />

<img src="e2_figures/unnamed-chunk-17-1.png" width="50%" />

