prettify_anova = function(raw, cap="title"){
  
  init = raw$ANOVA %>% 
    select(-ges) %>% 
    rename(sig=`p<.05`) %>%
    mutate(
      p = ifelse(p<0.00099, "0.000", p)
    ) %>% 
    mutate(
      sig=case_when(
        p < 0.001 ~ "***",
        p < 0.01  ~ "**",
        p < 0.05  ~ "*",
        TRUE      ~ ""
      )
    )
  
  knitr::kable(init,
        row.names=F,
        digits = c(0,1,1,2,3,1),
        caption=cap) %>%
    kable_styling(full_width = F, position='left')
}


prettify_sphericity = function(raw, cap="title"){
  infile = raw$`Sphericity Corrections` %>% 
    mutate(
      `p[GG]` = ifelse(`p[GG]`<.00099, "0.000", `p[GG]`),
      `p[HF]` = ifelse(`p[HF]`<.00099, "0.000", `p[HF]`),
      `p[GG]<.05`= case_when(
        `p[GG]` < 0.001 ~ "***",
        `p[GG]` < 0.01  ~ "**",
        `p[GG]` < 0.05  ~ "*",
        TRUE      ~ ""
      ),
      `p[HF]<.05`= case_when(
        `p[HF]` < 0.001 ~ "***",
        `p[HF]` < 0.01  ~ "**",
        `p[HF]` < 0.05  ~ "*",
        TRUE      ~ ""
      )
    )  %>%
    rename(
      `sig[GG]` = `p[GG]<.05`,
      `sig[HF]` = `p[HF]<.05`,
    )
      
  knitr::kable(infile,
               row.names = F,
               digits=3,
               caption=cap) %>% 
    kable_styling(full_width = F, position='left')
}


prettify_means = function(raw, cap="title"){
  kable(raw, digits=2, caption=cap) %>% 
    kable_styling(full_width = F, position = 'left')
}

prettify_corrected_dfs = function(raw, cap="title"){
  infile = raw$`Sphericity Corrections`
}