library(tidyverse)
library(ggstance)

d.study1 <-
  read_csv("results/model_response_log_likelihoods.csv") %>%
  rename(
    log_likelihood.perceptual_responses_training_data = opt_log_likelihood,
    log_likelihood.perceptual_responses_test_data = heldout_log_likelihood,
    log_likelihood.intended_category_test_data = train_log_likelihood,
    tau = distance_used, k = similarity_scaling_used) %>%
  mutate(
    Experiment = gsub("^.*(Natural|Synthetic)$", "\\1", model_number),
    cv_fold.phonetic = rep(1:5, nrow(.) / 5),
    cv_fold.perceptual = 1,
    parameters = map2(tau, k, ~ expression(tau == .(.x), k == .(.y))))

# Visualizing fit on heldout data
d.study1 %>%
  filter(Experiment == "Natural") %>%
  ggplot(aes(x = factor(k), y = log_likelihood.perceptual_responses_test_data, color = factor(tau))) +
  stat_summary(fun.data = mean_cl_boot, geom = "pointrange", position = position_dodge(.2)) +
  scale_x_discrete(expression(Similarity~scaling~k)) +
  scale_y_continuous("model's log likelihood") +
  scale_color_discrete(expression(Distance~exponent~tau)) +
  facet_grid(features_used ~ Experiment, scales = "free_y", labeller = label_both) +
  theme_bw() + theme(legend.position = "top")

# Visualizing best weights (w1, w2)
d.study1 %>%
  filter(Experiment == "Natural") %>%
  ggplot(aes(x = weight_2, y = weight_1, color = factor(tau), shape = factor(k))) +
  geom_point(alpha = .5) +
  # stat_summary(fun.data = mean_cl_boot, geom = "pointrange", position = position_dodge(.2)) +
  # stat_summaryh(fun.data = mean_cl_boot, geom = "pointrangeh", position = position_dodge(.2)) +
  scale_x_continuous("F2 weight") +
  scale_y_continuous("F1 weight") +
  scale_color_discrete(expression(Distance~exponent~tau)) +
  facet_grid(features_used ~ Experiment, scales = "free_y", labeller = label_both) +
  theme_bw() + theme(legend.position = "top")
