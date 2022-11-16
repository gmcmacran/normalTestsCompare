library(tidyverse)
library(purrr)
library(tweedie)
library(nortest)

########################
# Tweedie simulation
########################
# define experiment
tweedieDF <- cross_df(.l = list(param = seq(1, 2, .05), iteration = seq(1, 1000, 1))) %>%
  arrange(param, iteration)

# make data
generate_data_tweedie <- function(param) {
  out <- rtweedie(n = 30, mu = 3, phi = 1, xi = param)
  return(out)
}

set.seed(1)
tweedieDF <- tweedieDF %>%
  mutate(x = map(param, generate_data_tweedie))

# junk <- tweedieDF %>% slice(1) %>% pull(x)

# run tests
tweedieDF <- tweedieDF %>%
  mutate(
    AD = map(x, ad.test),
    AD_P = map_dbl(AD, chuck, "p.value")
  )

tweedieDF <- tweedieDF %>%
  mutate(
    CVM = map(x, cvm.test),
    CVM_P = map_dbl(CVM, chuck, "p.value")
  )

tweedieDF <- tweedieDF %>%
  mutate(
    LILLIE = map(x, lillie.test),
    LILLIE_P = map_dbl(LILLIE, chuck, "p.value")
  )

tweedieDF <- tweedieDF %>%
  mutate(
    PEARSON = map(x, pearson.test),
    PEARSON_P = map_dbl(PEARSON, chuck, "p.value")
  )

tweedieDF <- tweedieDF %>%
  mutate(
    SF = map(x, sf.test),
    SF_P = map_dbl(SF, chuck, "p.value")
  )

# Aggregate results
tweedieDF %>%
  summarise(across(contains("_P"), min))
tweedieDF %>%
  summarise(across(contains("_P"), max))

# save results
tweedieDF %>%
  saveRDS("data/tweedieDF.rds")
rm(tweedieDF, generate_data_tweedie)
