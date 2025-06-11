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

markdown
Copy
Edit

---

## 🧩 Task C: Exploratory Data Analysis Using R

**Are you interested in buying a property in Melbourne?** This task explores over 13 years of Melbourne’s real estate data collected from a top property website. The dataset (`property_transaction_victoria.csv`) contains detailed transaction records including price, type, size, and descriptions.

### 📑 Column Overview

Key columns include:  
- `suburb`, `property_type`, `price`, `bedrooms`, `bathrooms`, `land_size`, `sold_date`, `description`, etc.

### 📝 Analysis Questions

1. **Top Suburbs**  
   Identify the top 3 suburbs with the highest transaction volume. Plot their monthly transaction counts for 2022. Include *Toorak* even if not in top 3.

2. **Keyword Impact**  
   From a 10% sample, extract 3 keywords from the `description` field most associated with price variation.

3. **Price Correlations**  
   Compute correlation between `price` and `land_size` by suburb and property type (house, unit, townhouse, apartment).

4. **Capital Gains**  
   Identify top 5 properties with highest price gains (≤5-year holding). Include `address`, `capital gain`, and `duration`.

5. **Price Volatility**  
   Analyze which suburb-property type combinations showed the most median price volatility in 2022. Visualize the top 5.

6. **Price Prediction**  
   Predict September 2025 prices for 4-bedroom, 2-bathroom renovated houses in 6 suburbs (Mulgrave, Vermont South, Doncaster East, Rowville, Glen Waverley, Wheelers Hill) based on the dataset.

---

## 🧠 Task D: Predictive Data Analysis Using R

**How useful is the FLoRA GPT-4o chatbot?** This task evaluates 434 anonymized student–chatbot dialogues to build predictive models for usefulness scores (Likert 1–5).

### 📂 Data Overview

Two types of CSVs:
- `dialogue_utterance_{train,validation,test}.csv`
  - `Dialogue_ID`, `Timestamp`, `Interlocutor`, `Utterance_text`
- `dialogue_usefulness_{train,validation,test}.csv`
  - `Dialogue_ID`, `Usefulness_score`

### 📝 Modeling Tasks

1. **Feature Engineering**  
   Propose features (e.g., dialogue length, sentiment score, response time, complexity).  
   Visualize 2 of them using boxplots between low-score (1–2) and high-score (4–5) groups.  
   Test statistical significance.

2. **Model 1: Baseline**  
   Build a model (e.g., regression tree, polynomial regression) using ≥5 features.  
   Evaluate on validation set using RMSE/R². This is Model 1.

3. **Model Improvement**  
   Improve Model 1 by:
   - Selecting feature subsets
   - Handling outliers
   - Scaling/transforming variables
   - Trying new models (e.g., Random Forest, XGBoost)  
   Report metrics and justify your choices.

4. **Personal Dialogue Prediction**  
   Predict usefulness of your own dialogue (if in training set, remove it).  
   Compare prediction vs. ground truth. Identify influential features and use model interpretability tools (e.g., feature importance).

5. **Final Test Set Prediction**  
   Use best model to fill `Usefulness_score` in `dialogue_usefulness_test.csv` and save as:  
   `LastName_StudentNumber_dialogue_usefulness_test.csv`  
   Final performance will be measured based on **RMSE** on hidden scores.

---

## 🧪 Sample Code Snippets

### Property Analysis

```r
library(tidyverse)
library(lubridate)

properties <- read_csv("data/property_transaction_victoria.csv") %>%
  mutate(sold_date = dmy(sold_date))

top_suburbs <- properties %>%
  count(suburb, sort = TRUE) %>%
  head(3)
Dialogue Sentiment
r
Copy
Edit
library(ggplot2)
library(sentimentr)

dialogues <- dialogues %>%
  mutate(sentiment = sentiment_by(utterance_text)$ave_sentiment)

ggplot(dialogues, aes(x = factor(Usefulness_score), y = sentiment)) +
  geom_boxplot()
🚀 Getting Started
Clone this repository

Install required R packages:

r
Copy
Edit
install.packages(c("tidyverse", "caret", "xgboost", "sentimentr"))
Run RMarkdown files in /scripts/

📄 License
This project is licensed under the MIT License. See the LICENSE file for details.

vbnet
Copy
Edit

Let me know if you'd like a shorter version, embedded visuals, or help setting up `.Rproj` structure or GitHub
