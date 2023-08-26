# Load necessary libraries
library(dplyr)        # For data manipulation
library(tidyr)        # For data reshaping
library(countrycode)  # For country name to ISO3 code mapping


# Get the path of the current script
script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Create a new folder for saving CSV files
output_folder <- file.path(script_path, "output_csv")
dir_create(output_folder)  # Create the new folder if it doesn't exist

# Read the data
data_clean_interpolated <- read_csv(file.path(script_path, "data_clean_filled.csv"))

# We have to exctract from the column Country_Name only the countries
# In this column there are also other greater areas containing more than one countries
# We need ISO3 codes

# Create a vector of all unique country names in the dataset
all_country_names <- unique(data_clean_interpolated$Country_Name)

# Map country names to ISO3 codes
country_mapping <- countrycode(sourcevar = all_country_names,
                               origin = "country.name",
                               destination = "iso3c")

# Create a dataframe
country_mapping_df <- data.frame(Country_Name = all_country_names,
                                 ISO3_Code = country_mapping)

# Merge the data_clean_interpolated with country_mapping_df based on Country_Name
data_clean_mapped <- data_clean_filled %>%
  left_join(country_mapping_df, by = "Country_Name")

# Create a new dataframe without NA values in the ISO3_Code column
data_clean_mapped_filtered <- data_clean_mapped %>%
  filter(!is.na(ISO3_Code))


# Reshape the data to long format
data_clean_mapped_long <- data_clean_mapped_filtered %>%
  pivot_longer(cols = starts_with("2000"), 
               names_to = "Year",
               values_to = "Water_Index")