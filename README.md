# Shell-R-DataWrangling

**Data Science Portfolio Project: Real Estate Analytics & Dialogue Usefulness Prediction**

A comprehensive data science project featuring:

- 🏡 Exploratory analysis of Melbourne property transactions (2010–2023)  
- 💬 Machine learning model to predict chatbot dialogue usefulness

---

## 📁 Project Structure

text
├── data/
│ ├── property_transaction_victoria.csv
│ ├── dialogue_utterance_{train,validation,test}.csv
│ └── dialogue_usefulness_{train,validation,test}.csv
├── reports/
│ ├── EDA_Property_Analysis.pdf
│ └── Dialogue_Usefulness_Prediction.pdf
├── scripts/
│ ├── Task_C_Property_Analysis.Rmd
│ └── Task_D_Dialogue_Analysis.Rmd
└── output/
└── predicted_usefulness_scores.csv


---

## 🧩 Task C: Melbourne Property Market Analysis

### 📊 Dataset Overview

Analyzing 13 years of property transactions in Greater Melbourne with 25+ features including:

- Property type, price, bedrooms, bathrooms  
- Land/building sizes, location data  
- Transaction dates and descriptions  

### 🔍 Key Analyses

- **Transaction Trends**  
  - Identify top 3 suburbs by volume  
  - Monthly transaction visualization for 2022  

- **Text Analysis**  
  - Extract top 3 price-impacting keywords from descriptions (10% sample)  

- **Price Correlations**  
  - Compute price vs. land size correlations by suburb/property type  

- **Capital Gains**  
  - Top 5 properties with highest price increases (≤5 year holding period)  

- **Price Volatility**  
  - Identify most volatile suburb-property type combinations in 2022  

- **Price Prediction**  
  - Forecast September 2025 prices for 4-bedroom houses in 6 target suburbs  

### 🛠️ Technical Implementation

```r
# Example code snippet for transaction analysis
library(tidyverse)
library(lubridate)

properties <- read_csv("data/property_transaction_victoria.csv") %>%
  mutate(sold_date = dmy(sold_date))

top_suburbs <- properties %>%
  count(suburb, sort = TRUE) %>%
  head(3)
🧠 Task D: Chatbot Dialogue Usefulness Prediction
🗃️ Dataset Overview
434 anonymized student-chatbot dialogues

Features: Dialogue text, timestamps, speaker labels

Target: Usefulness score (1–5 Likert scale)

⚙️ Modeling Approach
Feature Engineering

Dialogue length, sentiment score, response time

Keyword presence, question complexity metrics

Model Development

Baseline: Regression trees, polynomial regression

Advanced: Random forests, XGBoost

Evaluation

RMSE / R² on validation set

Feature importance analysis

Optimization

Hyperparameter tuning

Error analysis and model refinement

📈 Example Feature Analysis

library(ggplot2)
library(sentimentr)

# Sentiment analysis feature
dialogues <- dialogues %>%
  mutate(sentiment = sentiment_by(utterance_text)$ave_sentiment)

# Visualize score differences
ggplot(dialogues, aes(x = factor(Usefulness_score), y = sentiment)) +
  geom_boxplot()
🚀 Getting Started
Clone this repository

Install required R packages:

r
Copy
Edit
install.packages(c("tidyverse", "caret", "xgboost", "sentimentr"))
Run RMarkdown files in /scripts/ to reproduce analysis

📄 License
This project is licensed under the MIT License. See the LICENSE file for details.

vbnet
Copy
Edit

Let me know if you want badges, visuals, or a version with clickable links and embedded plots!
