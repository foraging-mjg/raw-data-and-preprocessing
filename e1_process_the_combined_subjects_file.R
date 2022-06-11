# The aim here is to go from 
# row-per-eyetracker-sample
# to
# row-per-discrete-tree-visit-event
#
# Things that need to happen are:
# 1. Make sure that cases where they got a fruit on the first tree they looked at are handled appropriately to avoid structural missings
# 2. Annotate trials that didn't get the requisite ten fruit instead of removing them, to avoid structural missings
#
# A. Collapse consecutive samples in the same place down to a single row instead of multiple rows
# B. Get rid of rows (after collapsing down to single rows) that weren't in a tree
# C. identify memory errors


e1 <- readRDS("fgms_e1_allsubs.rds")

