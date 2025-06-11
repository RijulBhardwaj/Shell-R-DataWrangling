# Load required libraries
library(dplyr)
library(lubridate)
library(readr)
library(ggplot2)

# Step 1: Load and clean data
data <- read.csv("property_transaction_victoria.csv", stringsAsFactors = FALSE)

# Step 2: Filter relevant houses
selected_suburbs <- c("Mulgrave", "Vermont South", "Doncaster East", "Rowville", "Glen Waverley", "Wheelers Hill")

filtered_data <- data %>%
  filter(property_type == "house",
         bedrooms == 4,
         bathrooms == 2,
         suburb %in% selected_suburbs,
         !is.na(price),
         !is.na(sold_date)) %>%
  mutate(price = parse_number(price),
         sold_date = as.Date(sold_date),
         year = year(sold_date),
         month = month(sold_date)) %>%
  filter(!is.na(year) & !is.na(month))

# Step 3: Aggregate monthly average prices
monthly_avg <- filtered_data %>%
  group_by(suburb, year, month) %>%
  summarise(avg_price = mean(price, na.rm = TRUE), .groups = "drop") %>%
  mutate(time_index = (year - min(year)) * 12 + month)

# Step 4: Predict price for Sep 2025
predict_sep_2025 <- function(df) {
  model <- lm(avg_price ~ time_index, data = df)
  sep2025_index <- (2025 - min(df$year)) * 12 + 9
  pred <- predict(model, newdata = data.frame(time_index = sep2025_index))
  return(round(pred))
}

# Step 5: Apply prediction per suburb
predicted_prices <- monthly_avg %>%
  group_by(suburb) %>%
  filter(n() >= 12) %>%  # Ensure enough data
  summarise(predicted_price_sep2025 = predict_sep_2025(cur_data()), .groups = "drop")

# Step 6: Display results
print(predicted_prices)
