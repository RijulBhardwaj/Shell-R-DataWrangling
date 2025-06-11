# Load libraries
library(dplyr)
library(lubridate)
library(ggplot2)
library(stringr)
library(readr)

data <- read.csv("property_transaction_victoria.csv", stringsAsFactors = FALSE)

# Step 2: Parse dates
data$sold_date <- ymd(data$sold_date)
data$year <- year(data$sold_date)
data$month <- month(data$sold_date)

# Step 3: Clean and filter relevant data
data_clean <- data %>%
  filter(!is.na(price), !is.na(sold_date), !is.na(suburb), !is.na(property_type)) %>%
  mutate(
    price = readr::parse_number(price),  # Convert price to numeric
    property_type = tolower(trimws(property_type)),
    suburb = str_to_title(suburb)
  ) %>%
  filter(property_type %in% c("house", "unit", "townhouse", "apartment"), year == 2022)

# Step 4: Compute monthly medians
monthly_medians <- data_clean %>%
  group_by(suburb, property_type, month) %>%
  summarise(median_price = median(price, na.rm = TRUE), .groups = "drop")

# Step 5: Calculate standard deviation (volatility)
volatility <- monthly_medians %>%
  group_by(suburb, property_type) %>%
  summarise(price_sd = sd(median_price, na.rm = TRUE), .groups = "drop") %>%
  arrange(desc(price_sd)) %>%
  slice_head(n = 5)

# Step 6: Display top 5 most volatile combos
print(volatility)

# Step 7: Plot monthly trends of those combos
top5_combos <- volatility %>%
  mutate(combo = paste(suburb, property_type, sep = " - "))

monthly_medians %>%
  mutate(combo = paste(suburb, property_type, sep = " - ")) %>%
  filter(combo %in% top5_combos$combo) %>%
  ggplot(aes(x = month, y = median_price, color = combo, group = combo)) +
  geom_line(linewidth = 1.2) +
  labs(
    title = "Top 5 Most Volatile Suburb–Property Type Combinations (2022)",
    x = "Month",
    y = "Median Price",
    color = "Combination"
  ) +
  scale_x_continuous(breaks = 1:12) +
  theme_minimal()