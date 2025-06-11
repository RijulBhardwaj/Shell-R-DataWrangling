library(tidyverse)
library(lubridate)

# Load data from full path
data <- read_csv("C:/Users/Rijul Bhardwaj/OneDrive/Documents/property_transaction_victoria.csv")

# View column names
colnames(data)

# Clean column names just to make them easier to work with
names(data) <- tolower(names(data))                      # make lowercase
names(data) <- str_replace_all(names(data), " ", "_")    # replace spaces with _
names(data) <- str_replace_all(names(data), "-", "_")    # replace - with _

# Convert sold_date to Date type
data <- data %>%
  mutate(sold_date = ymd(sold_date)) %>%
  filter(!is.na(sold_date), !is.na(suburb))

# STEP 1: Top 3 suburbs by number of transactions
top_suburbs <- data %>%
  count(suburb, sort = TRUE) %>%
  slice_head(n = 3) %>%
  pull(suburb)

# STEP 2: Include Toorak if not already in the top 3
if (!"Toorak" %in% top_suburbs) {
  top_suburbs <- c(top_suburbs, "Toorak")
}

# STEP 3: Filter data for 2022 and relevant suburbs
data_2022 <- data %>%
  filter(suburb %in% top_suburbs, year(sold_date) == 2022) %>%
  mutate(month = floor_date(sold_date, "month"))

# STEP 4: Count monthly transactions
monthly_counts <- data_2022 %>%
  count(suburb, month)

# STEP 5: Plot
ggplot(monthly_counts, aes(x = month, y = n, color = suburb)) +
  geom_line(size = 1.2) +
  geom_point(size = 2) +
  scale_x_date(date_labels = "%b", date_breaks = "1 month") +
  labs(
    title = "Monthly Property Transactions in 2022",
    x = "Month",
    y = "Number of Transactions",
    color = "Suburb"
  ) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1))

