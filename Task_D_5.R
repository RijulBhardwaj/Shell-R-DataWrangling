# Load required libraries
library(dplyr)
library(tidyr)
library(ggplot2)
library(stringr)
library(readr)
library(caret)
library(randomForest)

# Set working directory or adjust paths if needed
train_utter_file <- "C:/Users/Rijul Bhardwaj/OneDrive/Documents/dialogue_utterance_train.csv"
train_score_file <- "C:/Users/Rijul Bhardwaj/OneDrive/Documents/dialogue_usefulness_train.csv"
val_utter_file   <- "C:/Users/Rijul Bhardwaj/OneDrive/Documents/dialogue_utterance_validation.csv"
val_score_file   <- "C:/Users/Rijul Bhardwaj/OneDrive/Documents/dialogue_usefulness_validation.csv"
test_utter_file  <- "C:/Users/Rijul Bhardwaj/OneDrive/Documents/dialogue_utterance_test.csv"
test_template    <- "C:/Users/Rijul Bhardwaj/OneDrive/Documents/dialogue_usefulness_test.csv"

# Load data
utter_train <- read_csv(train_utter_file)
score_train <- read_csv(train_score_file)
utter_val   <- read_csv(val_utter_file)
score_val   <- read_csv(val_score_file)
utter_test  <- read_csv(test_utter_file)
final_submission <- read_csv(test_template)

# Feature engineering function
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

# Scale features function
scale_features <- function(df) {
  df %>%
    mutate(across(
      c(num_turns, student_turns, bot_turns, avg_student_utter_len, total_word_count, dialogue_duration),
      ~ scale(.)[, 1]
    ))
}

# Engineer features
train_features <- engineer_features(utter_train)
val_features   <- engineer_features(utter_val)
test_features  <- engineer_features(utter_test)

# Merge features with labels
train_full <- inner_join(train_features, score_train, by = "Dialogue_ID")
val_full   <- inner_join(val_features, score_val, by = "Dialogue_ID")

# Remove missing
train_full <- na.omit(train_full)
val_full   <- na.omit(val_full)

# Convert score to factor
train_full$Usefulness_score <- as.factor(train_full$Usefulness_score)
val_full$Usefulness_score   <- as.factor(val_full$Usefulness_score)

# Filter outliers (on train/val only)
train_filtered <- train_full %>% filter(avg_student_utter_len < 300, dialogue_duration < 1000)
val_filtered   <- val_full %>% filter(avg_student_utter_len < 300, dialogue_duration < 1000)

# Scale train and validation
train_scaled <- scale_features(train_filtered)
val_scaled   <- scale_features(val_filtered)

# Drop empty levels
train_scaled$Usefulness_score <- droplevels(train_scaled$Usefulness_score)
val_scaled$Usefulness_score   <- droplevels(val_scaled$Usefulness_score)

# Match levels
common_levels <- intersect(levels(train_scaled$Usefulness_score), levels(val_scaled$Usefulness_score))
train_scaled <- filter(train_scaled, Usefulness_score %in% common_levels)
val_scaled   <- filter(val_scaled, Usefulness_score %in% common_levels)
train_scaled$Usefulness_score <- droplevels(train_scaled$Usefulness_score)
val_scaled$Usefulness_score   <- droplevels(val_scaled$Usefulness_score)

# Define selected features
selected_features <- c("num_turns", "student_turns", "avg_student_utter_len", "dialogue_duration", "total_word_count")

# Train random forest model
set.seed(42)
model_improved <- randomForest(
  formula = as.formula(paste("Usefulness_score ~", paste(selected_features, collapse = " + "))),
  data = train_scaled,
  ntree = 100,
  importance = TRUE
)

# Save model (optional)
saveRDS(model_improved, "C:/Users/Rijul Bhardwaj/OneDrive/Documents/best_model_rf.rds")

# Predict on test set (no filtering!)
test_scaled <- scale_features(test_features)

# Ensure column exists
final_submission$Usefulness_score <- NA

# Make predictions
test_pred <- predict(model_improved, newdata = test_scaled)
test_pred_numeric <- as.numeric(as.character(test_pred))

# Match predictions by Dialogue_ID
final_submission <- final_submission %>%
  left_join(test_features %>% select(Dialogue_ID), by = "Dialogue_ID") %>%
  mutate(Usefulness_score = test_pred_numeric)

# Fill any NA predictions with neutral score (optional)
final_submission$Usefulness_score[is.na(final_submission$Usefulness_score)] <- 3

# Save final submission
write_csv(final_submission, "Bhardwaj_12345678_dialogue_usefulness_test.csv")
cat("Final prediction file written as: Bhardwaj_12345678_dialogue_usefulness_test.csv\n")
