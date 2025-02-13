library(tidyverse)

d.study1 <-
  read_csv("Study1.csv") %>%
  rename(
    log_likelihood.perceptual_responses_training_data = test_log_likelihood,
    log_likelihood.perceptual_responses_test_data = held_out_log_likelihood,
    log_likelihood.intended_category_test_data = test_log_likelihood,
    Feature.Type = `Study Type`, Experiment = `Perceptual data`, tau = distance_used, k = similarity_scaling_used) %>%
  mutate(
    cv_fold.phonetic = rep(1:5, 24),
    cv_fold.perceptual = sort(rep(1:2, 60)),
    parameters = map2(tau, k, ~ expression(tau == .(.x), k == .(.y))))

d.study1 %>%
  ggplot(aes(x = factor(k), y = log_likelihood.perceptual_responses_test_data, color = factor(tau))) +
  stat_summary(fun.data = mean_cl_boot, geom = "pointrange", position = position_dodge(.2)) +
  scale_x_discrete(expression(Similarity~scaling~k)) +
  scale_y_continuous("model's log likelihood") +
  scale_color_discrete(expression(Distance~exponent~tau)) +
  facet_wrap( ~ Experiment, scales = "free_y", labeller = label_both) +
  theme_bw() + theme(legend.position = "top")
