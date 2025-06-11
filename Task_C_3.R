# Load libraries
library(tidyverse)

# Step 1: Load the dataset
data <- read_csv("C:/Users/Rijul Bhardwaj/OneDrive/Documents/property_transaction_victoria.csv")

# Step 2: Clean column names
names(data) <- tolower(names(data))
names(data) <- str_replace_all(names(data), " ", "_")

# Step 3: Clean and parse numeric fields
data <- data %>%
  mutate(
    price = parse_number(as.character(price)),
    land_size = parse_number(as.character(land_size)),
    property_type = tolower(property_type),
    suburb = str_to_title(suburb)
  )


# Step 4: Define valid property types and top suburbs from Q1
valid_property_types <- c("house", "unit", "townhouse", "apartment")
top_suburbs <- c("Toorak", "Melbourne", "Clyde North")  # Replace with actual top 3 from Q1

# Step 5: Filter data to required combinations
filtered_data <- data %>%
  filter(
    suburb %in% top_suburbs,
    property_type %in% valid_property_types,
    !is.na(price),
    !is.na(land_size),
    price > 0,
    land_size > 0
  )

# Step 6: Compute correlation
correlation_results <- filtered_data %>%
  group_by(suburb, property_type) %>%
  summarise(
    correlation = cor(price, land_size, use = "complete.obs"),
    .groups = "drop"
  )

# Step 7: Print the result
print(correlation_results)
