library(tidyverse)
library(purrr)
library(stabledist)
library(nortest)

########################
# Stable Distribution
########################
# define experiment
stableDF <- cross_df(.l = list(param = seq(1, 1.95, .05), iteration = seq(1, 1000, 1))) %>%
  arrange(param, iteration)

# make data
generate_data_stable <- function(param) {
  out <- rstable(n = 30, alpha = param, beta = 0)
  return(out)
}

set.seed(1)
stableDF <- stableDF %>%
  mutate(x = map(param, generate_data_stable))

# run tests
stableDF <- stableDF %>%
  mutate(
    AD = map(x, ad.test),
    AD_P = map_dbl(AD, chuck, "p.value")
  )

stableDF <- stableDF %>%
  mutate(
    CVM = map(x, cvm.test),
    CVM_P = map_dbl(CVM, chuck, "p.value")
  )

stableDF <- stableDF %>%
  mutate(
    LILLIE = map(x, lillie.test),
    LILLIE_P = map_dbl(LILLIE, chuck, "p.value")
  )

stableDF <- stableDF %>%
  mutate(
    PEARSON = map(x, pearson.test),
    PEARSON_P = map_dbl(PEARSON, chuck, "p.value")
  )

stableDF <- stableDF %>%
  mutate(
    SF = map(x, sf.test),
    SF_P = map_dbl(SF, chuck, "p.value")
  )

# check results
stableDF %>%
  summarise(across(contains("_P"), min))
stableDF %>%
  summarise(across(contains("_P"), max))

# save results
stableDF %>%
  saveRDS("data/stableDF.rds")
rm(stableDF, generate_data_stable)
