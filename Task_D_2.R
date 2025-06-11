# Load libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(rpart)
library(rpart.plot)
library(caret)
library(Metrics)
library(readr)
library(stringr)

# Load utterance and usefulness data
utter_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_train.csv")
score_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_train.csv")

utter_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_validation.csv")
score_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_validation.csv")

# Feature Engineering Function
engineer_features <- function(utter_data) {
  utter_data %>%
    group_by(Dialogue_ID) %>%
    summarise(
      num_turns = n(),
      student_turns = sum(Interlocutor == "Student"),
      bot_turns = sum(Interlocutor == "Chatbot"),
      avg_student_utter_len = mean(nchar(Utterance_text[Interlocutor == "Student"]), na.rm = TRUE),
      total_word_count = sum(str_count(Utterance_text, "\\w+")),
      dialogue_duration = as.numeric(difftime(max(Timestamp), min(Timestamp), units = "secs"))
    )
}

# Engineer features
train_features <- engineer_features(utter_train)
val_features <- engineer_features(utter_val)

# ename the score tables correctly
useful_train <- score_train
useful_val <- score_val

# Merge with usefulness scores
train_full <- inner_join(train_features, useful_train, by = "Dialogue_ID")
val_full <- inner_join(val_features, useful_val, by = "Dialogue_ID")

# Remove rows with missing values
train_full <- na.omit(train_full)
val_full <- na.omit(val_full)

# Convert Usefulness_score to factor for classification
train_full$Usefulness_score <- as.factor(train_full$Usefulness_score)
val_full$Usefulness_score <- as.factor(val_full$Usefulness_score)

# Train Model 1: Regression Tree Classifier
set.seed(123)
model1 <- rpart(
  Usefulness_score ~ num_turns + student_turns + bot_turns +
    avg_student_utter_len + total_word_count + dialogue_duration,
  data = train_full,
  method = "class"  # Use "anova" for regression
)

# Plot the decision tree
rpart.plot(model1)

# Predict on validation set
val_pred <- predict(model1, val_full, type = "class")

# Confusion matrix for classification
conf_matrix <- confusionMatrix(val_pred, val_full$Usefulness_score)
print(conf_matrix)

