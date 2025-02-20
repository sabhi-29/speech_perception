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

# Pivot data to long format
d.study1.long <- d.study1 %>%
  pivot_longer(
    cols = starts_with("log_likelihood"),
    names_to = c("response", "fold"),
    names_pattern = "log_likelihood\\.(intended|perceptual).*_(training|test)_data",
    values_to = "value")

# Visualizing fit on heldout data
d.study1.long %>%
  filter(Experiment == "Natural", response == "perceptual") %>%
  ggplot(
    aes(
      x = factor(k), 
      y = value, 
      color = factor(tau),
      shape = fold)) +
  stat_summary(
    fun.data = mean_cl_boot, 
    geom = "pointrange", 
    position = position_dodge(.2)) +
  scale_x_discrete(expression(Similarity~scaling~k)) +
  scale_y_continuous("model's log likelihood") +
  scale_color_discrete(expression(Distance~exponent~tau)) +
  facet_grid(features_used ~ Experiment, scales = "free_y", labeller = label_both) +
  theme_bw() + theme(legend.position = "top")

# Visualizing best weights (w1, w2)
d.study1.long %>%
  filter(Experiment == "Natural") %>%
  ggplot(
    aes(
      x = weight_2, 
      y = weight_1, 
      color = factor(tau), 
      shape = factor(k))) +
  geom_point(alpha = .5) +
  # stat_summary(fun.data = mean_cl_boot, geom = "pointrange", position = position_dodge(.2)) +
  # stat_summaryh(fun.data = mean_cl_boot, geom = "pointrangeh", position = position_dodge(.2)) +
  scale_x_continuous("F2 weight") +
  scale_y_continuous("F1 weight") +
  scale_color_discrete(expression(Distance~exponent~tau)) +
  facet_grid(features_used ~ Experiment, scales = "free_y", labeller = label_both) +
  theme_bw() + theme(legend.position = "top")

# Visualizing best weights using crossbars
d.study1.long %>%
  filter(Experiment == "Natural") %>%
  group_by(Experiment, features_used, tau, k) %>%
  summarise(
    ci_weight_1 = list(enframe(Hmisc::smean.cl.boot(weight_1))),
    ci_weight_2 = list(enframe(Hmisc::smean.cl.boot(weight_2)))) %>%
  unnest(ci_weight_1, ci_weight_2) %>%
  rename(value_weight_1 = value, value_weight_2 = value1) %>%
  select(-name1) %>%
  pivot_wider(
    names_from = "name",
    values_from = c("value_weight_1", "value_weight_2")) %>% 
  group_by(Experiment, features_used, tau, k) %>%
  summarise(
    mean_CI_lower_weight_1 = mean(value_weight_1_Lower),
    mean_CI_upper_weight_1 = mean(value_weight_1_Upper),
    mean_weight_1 = mean(value_weight_1_Mean),
    mean_CI_lower_weight_2 = mean(value_weight_2_Lower),
    mean_CI_upper_weight_2 = mean(value_weight_2_Upper),
    mean_weight_2 = mean(value_weight_2_Mean)) %>%
  ggplot() +
  geom_point(
    aes(
      x = mean_weight_2,
      y = mean_weight_1, 
      color = factor(tau), 
      shape = factor(k))) +
  geom_linerange(
    aes(
      x = mean_weight_2,
      xmin = mean_CI_lower_weight_2,
      xmax = mean_CI_upper_weight_2,
      y = mean_weight_1,
      color = factor(tau))) +
  geom_linerange(
    aes(
      x = mean_weight_2,
      y = mean_weight_1,
      ymin = mean_CI_lower_weight_1,
      ymax = mean_CI_upper_weight_1,
      color = factor(tau))) +
  scale_x_continuous("F2 weight") +
  scale_y_continuous("F1 weight") +
  scale_color_discrete(expression(Distance~exponent~tau)) +
  facet_grid(features_used ~ Experiment, scales = "free_y", labeller = label_both) +
  theme_bw() + 
  theme(legend.position = "top")
