# ----------------- Load Required Libraries -----------------
library(dplyr)
library(tidyr)
library(stringr)
library(readr)
library(caret)
library(randomForest)
library(e1071)
library(xgboost)

# ----------------- Load Data -----------------
utter_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_train.csv")
score_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_train.csv")

utter_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_validation.csv")
score_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_validation.csv")

# ----------------- Feature Engineering -----------------
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

# Apply feature engineering
train_features <- engineer_features(utter_train)
val_features <- engineer_features(utter_val)

# Merge with usefulness scores
train_full <- inner_join(train_features, score_train, by = "Dialogue_ID")
val_full <- inner_join(val_features, score_val, by = "Dialogue_ID")

# ----------------- Data Cleaning -----------------
train_full <- na.omit(train_full)
val_full <- na.omit(val_full)

train_full$Usefulness_score <- as.factor(train_full$Usefulness_score)
val_full$Usefulness_score <- as.factor(val_full$Usefulness_score)

# Remove extreme outliers
train_filtered <- train_full %>% filter(avg_student_utter_len < 300, dialogue_duration < 1000)
val_filtered <- val_full %>% filter(avg_student_utter_len < 300, dialogue_duration < 1000)

# ----------------- Feature Scaling + Log Transformation -----------------
selected_features <- c("num_turns", "student_turns", "avg_student_utter_len", "dialogue_duration", "total_word_count")

scale_transform <- function(df) {
  df <- df %>%
    mutate(
      avg_student_utter_len = log1p(avg_student_utter_len),
      dialogue_duration = log1p(dialogue_duration),
      total_word_count = log1p(total_word_count)
    )
  df %>%
    mutate(across(all_of(selected_features), ~ as.numeric(scale(.))))
}

train_scaled <- scale_transform(train_filtered)
val_scaled <- scale_transform(val_filtered)

train_scaled$Usefulness_score <- droplevels(train_filtered$Usefulness_score)
val_scaled$Usefulness_score <- droplevels(val_filtered$Usefulness_score)

common_levels <- intersect(levels(train_scaled$Usefulness_score), levels(val_scaled$Usefulness_score))
train_scaled <- filter(train_scaled, Usefulness_score %in% common_levels)
val_scaled <- filter(val_scaled, Usefulness_score %in% common_levels)
train_scaled$Usefulness_score <- droplevels(train_scaled$Usefulness_score)
val_scaled$Usefulness_score <- droplevels(val_scaled$Usefulness_score)

# ----------------- Random Forest -----------------
set.seed(123)
model_rf <- randomForest(
  Usefulness_score ~ .,
  data = train_scaled %>% select(all_of(selected_features), Usefulness_score),
  ntree = 200,
  importance = TRUE
)
pred_rf <- predict(model_rf, val_scaled)
conf_rf <- confusionMatrix(pred_rf, val_scaled$Usefulness_score)
cat("Random Forest Accuracy:", conf_rf$overall["Accuracy"], "\n")

# ----------------- SVM -----------------
model_svm <- svm(
  Usefulness_score ~ .,
  data = train_scaled %>% select(all_of(selected_features), Usefulness_score),
  kernel = "radial"
)
pred_svm <- predict(model_svm, val_scaled)
conf_svm <- confusionMatrix(pred_svm, val_scaled$Usefulness_score)
cat("SVM Accuracy:", conf_svm$overall["Accuracy"], "\n")

# ----------------- XGBoost -----------------
x_train <- as.matrix(train_scaled %>% select(all_of(selected_features)))
y_train <- as.numeric(train_scaled$Usefulness_score) - 1
x_val <- as.matrix(val_scaled %>% select(all_of(selected_features)))
y_val <- as.numeric(val_scaled$Usefulness_score) - 1

dtrain <- xgb.DMatrix(data = x_train, label = y_train)
dval <- xgb.DMatrix(data = x_val, label = y_val)

params <- list(
  objective = "multi:softmax",
  num_class = length(unique(train_scaled$Usefulness_score)),
  eta = 0.1,
  max_depth = 5,
  eval_metric = "merror"
)

model_xgb <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  watchlist = list(val = dval),
  early_stopping_rounds = 10,
  verbose = 0
)

pred_xgb <- predict(model_xgb, x_val)
pred_xgb_factor <- factor(pred_xgb + 1, levels = levels(train_scaled$Usefulness_score))
conf_xgb <- confusionMatrix(pred_xgb_factor, val_scaled$Usefulness_score)
cat("XGBoost Accuracy:", conf_xgb$overall["Accuracy"], "\n")

# ----------------- Summary Table -----------------
model_accuracies <- data.frame(
  Model = c("Random Forest", "SVM", "XGBoost"),
  Accuracy = c(
    conf_rf$overall["Accuracy"],
    conf_svm$overall["Accuracy"],
    conf_xgb$overall["Accuracy"]
  )
)

print(model_accuracies)
