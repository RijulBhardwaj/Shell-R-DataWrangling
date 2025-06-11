# Load libraries
library(dplyr)
library(ggplot2)
library(stringr)
library(readr)
library(randomForest)

# Load training and validation data
utter_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_train.csv")
score_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_train.csv")

utter_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_validation.csv")
score_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_validation.csv")

# Feature engineering
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

# Generate features
train_features <- engineer_features(utter_train)
val_features <- engineer_features(utter_val)

# Merge features with scores
train_full <- inner_join(train_features, score_train, by = "Dialogue_ID")
val_full <- inner_join(val_features, score_val, by = "Dialogue_ID")

# Remove NAs
train_full <- na.omit(train_full)
val_full <- na.omit(val_full)

# Convert to factor
train_full$Usefulness_score <- as.factor(train_full$Usefulness_score)
val_full$Usefulness_score <- as.factor(val_full$Usefulness_score)

# Train improved model (Random Forest)
selected_features <- c("num_turns", "student_turns", "avg_student_utter_len", "dialogue_duration", "total_word_count")

set.seed(42)
model_improved <- randomForest(
  formula = as.formula(paste("Usefulness_score ~", paste(selected_features, collapse = " + "))),
  data = train_full,
  ntree = 100,
  importance = TRUE
)

# ---- TASK D: Analyze Dialogue_ID = 6090 ----

# Step 1: Extract dialogue text
target_id <- 6090  # Your specific dialogue ID
full_dialogue <- utter_val %>%
  filter(Dialogue_ID == target_id) %>%
  arrange(Timestamp)

cat("Full Dialogue for Dialogue_ID 6090:\n")
for (i in 1:nrow(full_dialogue)) {
  cat(paste0("[", full_dialogue$Interlocutor[i], "] ", full_dialogue$Utterance_text[i], "\n"))
}

# Step 2: Predict usefulness score for Dialogue_ID 6090
dialogue_row <- val_full %>% filter(Dialogue_ID == target_id)
predicted_score <- predict(model_improved, dialogue_row)

# Step 3: Output prediction vs ground truth
cat("\nPrediction for Dialogue_ID:", target_id, "\n")
cat("Predicted Usefulness Score:", as.character(predicted_score), "\n")
cat("Actual Usefulness Score   :", as.character(dialogue_row$Usefulness_score), "\n")

# Step 4: Feature Importance
cat("\nFeature Importance:\n")
print(importance(model_improved))
varImpPlot(model_improved))
