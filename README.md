# Insurance Claim Severity Modeling (Actuarial Project)

## Objective
This project analyzes insurance claim severity using publicly available claims data. 
The goal is indentifying policyholder, vehicle, and coverage characteristics associated with higher or lower expected claim costs, conditional on a claim occuring.

## Key Findings
- Insurance claim severity displays a strong right-sweked distribution, consistent with insurance
- Higher education levels (e.g., PhD, MD, Master's) are associated with approximately 11-14% higher expected claim costs, potentially reflecting differences in income, vehicle value, or coverage selection.
- Vehicle age is negatively associated with claim severity, with each additional model year associated with an estimated 0.3% decrease in expected claim cost.
- Claim severity increases modestly with age, at approximately 0.4% per year.
- Male insureds exhibit slightly lower claim severity (approximately 3% lower) conditional on a claim occuring.
- Houshold relationship relationship variables show relatively small effects on policy and vehicle characteristics.

## Methodology
- Data cleaning and variable seleciton focused on pricing-relevant variables.
- Exploratory data analysis of loss distributions.
- Gama generalized linear model (GLM) with log link.

## Limitation
-The dataset includes only observed claims ; non-claim exposure records were not available to me.
- Results are illustrative and intended to demonstrate actuarial modeling techniques rather than support operational pricing decisions.

## Tools
- R, dplyr, ggplot2
