library(tidyverse)
library(tidytext)
library(stringr)

# Step 1: Load data
data <- read_csv("C:/Users/Rijul Bhardwaj/OneDrive/Documents/property_transaction_victoria.csv")

# Step 2: Clean column names
names(data) <- tolower(names(data))
names(data) <- str_replace_all(names(data), " ", "_")

# Step 3: Clean price column
data <- data %>%
  mutate(price = parse_number(price))  # ensures numeric conversion even if commas present

# Step 4: Sample 10% of valid rows
set.seed(123)
sample_data <- data %>%
  filter(!is.na(description), !is.na(price)) %>%
  sample_frac(0.10) %>%
  mutate(row_id = row_number())

# Step 5: Tokenize and clean text
word_data <- sample_data %>%
  select(row_id, description) %>%
  unnest_tokens(word, description) %>%
  anti_join(get_stopwords(), by = "word") %>%
  filter(!str_detect(word, "^\\d+$")) %>%             # remove numbers only
  filter(!str_detect(word, "^(am|pm|\\d{1,2}(am|pm))$")) %>%  # remove time expressions
  filter(str_detect(word, "[a-zA-Z]")) %>%            # keep only actual words
  filter(nchar(word) > 2)

# Step 6: Join with price
word_data_with_price <- word_data %>%
  left_join(sample_data %>% select(row_id, price), by = "row_id")

# Step 7: Calculate average price per word
keyword_prices <- word_data_with_price %>%
  group_by(word) %>%
  summarise(
    avg_price = mean(price, na.rm = TRUE),
    count = n()
  ) %>%
  filter(count >= 10)

# Step 8: Get top 3 keywords with highest average price
top_keywords <- keyword_prices %>%
  arrange(desc(avg_price)) %>%
  slice_head(n = 3)

# Step 9: View result
print(top_keywords)
