# Load required libraries
library(dplyr)
library(lubridate)
library(readr)

# Step 1: Import dataset
data <- read.csv("property_transaction_victoria.csv", stringsAsFactors = FALSE)

# Step 2: Clean and convert 'sold_date' to proper date format
data$sold_date <- ymd(data$sold_date)
data$price <- parse_number(as.character(data$price))


# Step 3: Filter data - remove rows with missing sold_date, price, or address
cleaned_data <- data %>%
  filter(!is.na(sold_date), !is.na(price), !is.na(full_address)) %>%
  arrange(full_address, sold_date)

# Step 4: Get first and last sale info for each property
property_gains <- cleaned_data %>%
  group_by(full_address) %>%
  summarise(
    first_price = first(price),
    last_price = last(price),
    first_date = first(sold_date),
    last_date = last(sold_date),
    .groups = "drop"
  ) %>%
  mutate(
    duration_years = as.numeric(difftime(last_date, first_date, units = "days")) / 365,
    capital_gain = last_price - first_price
  )


# Step 5: Filter for valid gain within 5 years
valid_gains <- property_gains %>%
  filter(duration_years <= 5, capital_gain > 0) %>%
  arrange(desc(capital_gain)) %>%
  slice_head(n = 5)

# Step 6: Print final result
print(valid_gains %>% select(full_address, capital_gain, duration_years))
