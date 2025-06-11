# Load libraries
library(tidyverse)
library(tidytext)
library(text2vec)
library(caret)
library(randomForest)
library(e1071)

# Load datasets
utter_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_train.csv")
score_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_train.csv")

utter_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_validation.csv")
score_val <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_validation.csv")

utter_test <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_test.csv")
score_test <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_test.csv")


# Combine utterances by Dialogue_ID
train_text <- utter_train %>%
  group_by(Dialogue_ID) %>%
  summarise(full_dialogue = paste(Utterance_text, collapse = " ")) %>%
  left_join(score_train, by = "Dialogue_ID")

val_text <- utter_val %>%
  group_by(Dialogue_ID) %>%
  summarise(full_dialogue = paste(Utterance_text, collapse = " ")) %>%
  left_join(score_val, by = "Dialogue_ID")

test_text <- utter_test %>%
  group_by(Dialogue_ID) %>%
  summarise(full_dialogue = paste(Utterance_text, collapse = " ")) %>%
  left_join(score_test, by = "Dialogue_ID")

# Text preprocessing
prep_fun <- tolower
tok_fun <- word_tokenizer

it_train <- itoken(train_text$full_dialogue, 
                   preprocessor = prep_fun, tokenizer = tok_fun, progressbar = FALSE)

vocab <- create_vocabulary(it_train)
vectorizer <- vocab_vectorizer(vocab)

# Document-Term Matrices
dtm_train <- create_dtm(it_train, vectorizer)
dtm_val <- create_dtm(itoken(val_text$full_dialogue, preprocessor = prep_fun, tokenizer = tok_fun), vectorizer)
dtm_test <- create_dtm(itoken(test_text$full_dialogue, preprocessor = prep_fun, tokenizer = tok_fun), vectorizer)

# Prepare response variables
y_train <- as.factor(train_text$Usefulness_score)
y_val <- as.factor(val_text$Usefulness_score)

# Train Random Forest model
rf_model <- randomForest(x = as.matrix(dtm_train), y = y_train, ntree = 100)

# Predict on validation set
val_pred <- predict(rf_model, newdata = as.matrix(dtm_val))

# Evaluate on validation set
confusionMatrix(val_pred, y_val)

# Predict on test set (optional)
y_test <- as.factor(test_text$Usefulness_score)
test_pred <- predict(rf_model, newdata = as.matrix(dtm_test))

# Evaluate on test set
confusionMatrix(test_pred, y_test)


# ---------------------------
# 1. Load Libraries
# ---------------------------
library(tidyverse)
library(stringr)
library(ggplot2)

# ---------------------------
# 2. Load Data
# ---------------------------
utter_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_utterance_train.csv")
score_train <- read_csv("C:\\Users\\Rijul Bhardwaj\\OneDrive\\Documents\\dialogue_usefulness_train.csv")

# ---------------------------
# 3. Feature Engineering
# ---------------------------
# For each dialogue, calculate:
# - Number of turns
# - Average student utterance length

feature_df <- utter_train %>%
  group_by(Dialogue_ID) %>%
  summarise(
    num_turns = n(),
    student_avg_utter_len = mean(str_count(Utterance_text[Interlocutor == "student"], "\\w+"))
  ) %>%
  left_join(score_train, by = "Dialogue_ID") %>%
  filter(Usefulness_score %in% c(1, 2, 4, 5)) %>%    # Keep only Low and High scores
  mutate(group = case_when(
    Usefulness_score %in% c(1, 2) ~ "Low",
    Usefulness_score %in% c(4, 5) ~ "High"
  )) %>%
  mutate(group = as.factor(group))


# ---------------------------
# 4. Boxplot Visualization
# ---------------------------

# Boxplot: Number of Turns
ggplot(feature_df, aes(x = group, y = num_turns)) +
  geom_boxplot(fill = "skyblue") +
  labs(
    title = "Number of Turns vs Usefulness Score",
    x = "Usefulness Group",
    y = "Number of Turns"
  )

# Boxplot: Student Avg Utterance Length
ggplot(feature_df, aes(x = group, y = student_avg_utter_len)) +
  geom_boxplot(fill = "lightgreen") +
  labs(
    title = "Student Average Utterance Length vs Usefulness Score",
    x = "Usefulness Group",
    y = "Average Utterance Length"
  )

# ---------------------------
# 5. Statistical Significance Testing (t-tests)
# ---------------------------

# t-test: Number of Turns
t_test_turns <- t.test(num_turns ~ group, data = feature_df)
print(t_test_turns)

# t-test: Student Avg Utterance Length
t_test_utter_len <- t.test(student_avg_utter_len ~ group, data = feature_df)
print(t_test_utter_len)

