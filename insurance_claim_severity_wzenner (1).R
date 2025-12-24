############################################################
# Insurance Claim Severity Modeling – Actuarial Project
# Author: Will Zenner
# Program: B.S. Actuarial Science, University of Iowa
#
# This is one of my first actuarial-style projects. The goal
# is to:
#   - Work with real(istic) claim-level data
#   - Explore how claim severity behaves
#   - Fit a Gamma GLM with a log link for severity
#
# I’m early in my actuarial studies, so the focus is on
# getting the structure and reasoning right rather than
# building an extremely advanced model.
############################################################

# Load the packages I use throughout the project
library(dplyr)
library(ggplot2)
library(scales)

# -------------------------------
# 1. Load and prepare the data
# -------------------------------

# Assumes the project has a /data folder and the CSV is inside.
# If the path changes, this line needs to be updated.
df <- read.csv("data/insurance_claims.csv", stringsAsFactors = FALSE)

# Quick sanity checks before doing anything else
dim(df)        # rows x columns
names(df)      # variable names

# For this project I only keep variables that an actuary might consider
# when thinking about pricing or severity, plus the claim amount itself.
keep_vars <- c(
  "months_as_customer", "age",
  "policy_state", "policy_csl", "policy_deductable",
  "policy_annual_premium", "umbrella_limit",
  "insured_sex", "insured_education_level",
  "insured_occupation", "insured_relationship",
  "auto_make", "auto_model", "auto_year",
  "total_claim_amount", "injury_claim",
  "property_claim", "vehicle_claim"
)

df_model <- df %>%
  dplyr::select(any_of(keep_vars)) %>%
  filter(!is.na(total_claim_amount))    # need a severity outcome

# Treat categorical predictors as factors for the GLM
cat_vars <- c(
  "policy_state", "policy_csl",
  "insured_sex", "insured_education_level",
  "insured_occupation", "insured_relationship",
  "auto_make", "auto_model"
)

for (v in intersect(cat_vars, names(df_model))) {
  df_model[[v]] <- as.factor(df_model[[v]])
}

# Basic look at the target variable (claim severity)
summary(df_model$total_claim_amount)

# -------------------------------
# 2. Explore claim severity
# -------------------------------

# Histogram to check if losses are right-skewed (typical in insurance)
p_sev_hist <- ggplot(df_model, aes(x = total_claim_amount)) +
  geom_histogram(bins = 50, fill = "steelblue", color = "white") +
  scale_x_continuous(labels = scales::comma) +
  labs(
    title = "Distribution of Insurance Claim Severity",
    x = "Claim Amount ($)",
    y = "Number of Claims"
  )

# Boxplot of severity by deductible – important coverage feature
p_sev_by_ded <- ggplot(df_model, aes(x = as.factor(policy_deductable),
                                     y = total_claim_amount)) +
  geom_boxplot(fill = "grey85") +
  scale_y_continuous(labels = scales::comma) +
  labs(
    title = "Claim Severity by Policy Deductible",
    x = "Policy Deductible",
    y = "Claim Amount ($)"
  )

# Show plots in RStudio
print(p_sev_hist)
print(p_sev_by_ded)

# Save plots for the GitHub repo
if (!dir.exists("outputs")) dir.create("outputs")
ggsave("outputs/severity_histogram.png", plot = p_sev_hist, width = 8, height = 5)
ggsave("outputs/severity_by_deductible.png", plot = p_sev_by_ded, width = 8, height = 5)

# -------------------------------
# 3. Fit Gamma GLM for severity
# -------------------------------

# Because the losses are positive and right-skewed,
# a Gamma GLM with a log link is a reasonable starting point.
severity_model <- glm(
  total_claim_amount ~
    age +
    months_as_customer +
    policy_deductable +
    policy_annual_premium +
    umbrella_limit +
    insured_sex +
    insured_education_level +
    insured_relationship +
    auto_year,
  data = df_model,
  family = Gamma(link = "log")
)

summary(severity_model)

# Translate coefficients into approximate % changes in expected severity
coef_table <- data.frame(
  term = names(coef(severity_model)),
  beta = coef(severity_model),
  row.names = NULL
) %>%
  mutate(
    pct_effect = (exp(beta) - 1) * 100
  ) %>%
  arrange(desc(abs(pct_effect)))   # largest absolute effects at the top

head(coef_table, 15)

# Some quick notes for myself (and anyone reviewing this):
# - I don’t interpret the intercept directly in this model.
# - Education coefficients suggest higher education is associated with
#   roughly 7–14% higher claim costs, conditional on a claim.
# - Newer auto_year has a small negative effect on severity, which
#   lines up with the idea of safer/newer vehicles.
# - Demographic effects (sex, relationship) are present but small
#   compared to policy and vehicle characteristics.

# Save the cleaned dataset in case I want to reuse it later
write.csv(df_model, "data/df_model.csv", row.names = FALSE)