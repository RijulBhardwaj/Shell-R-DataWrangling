# Shell-R-DataWrangling
Data Science Portfolio Project: Real Estate Analytics &amp; Dialogue Usefulness Prediction

Task 1: Exploratory Data Analysis (EDA) of Property Data
Dataset: property_transaction_victoria.csv (Melbourne real estate transactions).

Key Questions
Top Suburbs by Transactions: Identify top 3 suburbs by transaction volume (2022) and visualize monthly trends.

Keyword Impact on Prices: Extract top 3 keywords from property descriptions (10% sample) correlated with price.

Price vs. Land Size: Compute correlations for top suburbs and property types (House, Unit, etc.).

Capital Gains Analysis: Identify top 5 properties with highest price increases (≤5 years between sales).

Price Volatility: Find suburb-property type combinations with highest median price volatility (2022).

Price Prediction: Forecast September 2025 prices for 4-bedroom houses in 6 suburbs using historical data.

Skills Demonstrated:

Data cleaning (dplyr, tidyr), time-series analysis (lubridate), NLP (tm, tidytext), regression modeling (caret).

Task 2: Predictive Modeling of Dialogue Usefulness
Dataset: Chatbot conversational data (dialogue_utterance_*.csv, dialogue_usefulness_*.csv).

Key Steps
Feature Engineering:

Propose features (e.g., dialogue length, sentiment score, response time) and validate with boxplots/statistical tests (t-test/ANOVA).

Model Building:

Train models (e.g., regression trees, polynomial regression) using 5+ features. Evaluate on validation set (RMSE/R²).

Model Optimization:

Improve performance via feature selection, outlier removal, scaling, or algorithm choice (e.g., random forests, XGBoost).

Prediction & Analysis:

Predict usefulness scores for test dialogues and analyze feature importance (e.g., SHAP values, coefficients).

Skills Demonstrated:

Feature engineering (stringr, sentimentr), ML pipelines (caret, xgboost), statistical testing, model interpretation.
