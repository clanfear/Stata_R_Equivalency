mean_vec <- c("x" = 1.0, "y" = 2.0, "z" = 3.0)
cov_mat <- rbind(c(1.0, .75, 1.0),
                 c(.75, 1.5, 0.0),
                 c(1.0, 0.0, 2.0))
example_data <- data.frame(MASS::mvrnorm(300,
                                         mu = mean_vec, 
                                         Sigma = cov_mat,
                                         empirical = TRUE))



# car package provides a shortcut to `boot`
car::Boot(glm(y ~ x + z, data=example_data))

# Using `boot` directly
boot_glm <- function(d,indices) {  
  d <- d[indices,]  
  fit <- glm(y ~ x + z, data = d)  
  return(coef(fit))  
}
boot::boot(data = example_data, 
     statistic = boot_glm, 
     R = 1000) 

# Modern method using tidyverse packages
library(dplyr)
library(broom)
library(rsample)
library(tidyr)
library(purrr)

example_data %>% 
  bootstraps(times=1000) %>% 
  mutate(model = map(splits, 
                     function(x) glm(y ~ x + z, data=x)),
         coef_info = map(model, tidy)) %>% 
  unnest(coef_info) %>% 
  group_by(term) %>%
  summarize(pe = mean(estimate),
            se = sd(estimate),
            low =  quantile(estimate, .025),
            high = quantile(estimate, .975))