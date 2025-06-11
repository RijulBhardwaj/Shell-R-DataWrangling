# Load libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(readr)
library(caret)
library(randomForest)
library(rpart.plot)

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

# Rename score tables
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

# Filter Outliers (optional improvement)
train_filtered <- train_full %>% filter(avg_student_utter_len < 300, dialogue_duration < 1000)
val_filtered <- val_full %>% filter(avg_student_utter_len < 300, dialogue_duration < 1000)

# Feature Scaling Function
scale_features <- function(df) {
  df %>%
    mutate(across(
      c(num_turns, student_turns, bot_turns, avg_student_utter_len, total_word_count, dialogue_duration),
      ~ scale(.)[, 1]
    ))
}

# Apply scaling
train_scaled <- scale_features(train_filtered)
val_scaled <- scale_features(val_filtered)

# Drop empty levels
train_scaled$Usefulness_score <- droplevels(train_scaled$Usefulness_score)
val_scaled$Usefulness_score <- droplevels(val_scaled$Usefulness_score)

# Match common levels in both sets
common_levels <- intersect(levels(train_scaled$Usefulness_score), levels(val_scaled$Usefulness_score))
train_scaled <- filter(train_scaled, Usefulness_score %in% common_levels)
val_scaled <- filter(val_scaled, Usefulness_score %in% common_levels)
train_scaled$Usefulness_score <- droplevels(train_scaled$Usefulness_score)
val_scaled$Usefulness_score <- droplevels(val_scaled$Usefulness_score)

# Select top 5 features based on importance/insight
selected_features <- c("num_turns", "student_turns", "avg_student_utter_len", "dialogue_duration", "total_word_count")

# Train improved model: Random Forest
set.seed(42)
model_improved <- randomForest(
  formula = as.formula(paste("Usefulness_score ~", paste(selected_features, collapse = " + "))),
  data = train_scaled,
  ntree = 100,
  importance = TRUE
)

saveRDS(model_improved, "C:/Users/Rijul Bhardwaj/OneDrive/Documents/best_model_rf.rds")

# Feature importance plot
print(importance(model_improved))
varImpPlot(model_improved)

# Predict on validation set
val_pred_rf <- predict(model_improved, val_scaled)

# Confusion matrix
conf_matrix <- confusionMatrix(val_pred_rf, val_scaled$Usefulness_score)
print(conf_matrix)

# Optional: Accuracy
cat("Accuracy of Improved Model:", conf_matrix$overall['Accuracy'], "\n")
