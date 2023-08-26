library(readr) # For reading data from CSV files
library(dplyr) # For data manipulation and summarization
library(tidyr) # For data reshaping and tidying
library(fs)  # For working with file paths
library(ggplot2) # For creating plots

# It is recommended to run code in chunks

# Get the path of the current script
script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Create a new folder for saving CSV files
output_folder <- file.path(script_path, "output_csv")
dir_create(output_folder)  # Create the new folder if it doesn't exist

# Read the data
data <- read_csv(file.path(script_path, "API_SH.csv"))
data <- read_csv(file.path(script_path, "API_SH.csv"), skip = 3)


# Rename the Columns
data <- data %>%
  select(-c("Indicator Code", "Indicator Name")) %>%
  rename(Country_Name = `Country Name`, Country_Code = `Country Code`)

# Display summary statistics
summary_stats <- summary(data)
print(summary_stats)




# Check data types of columns
data_types <- sapply(data, class)
data_types_df <- data.frame(Column_Name = names(data_types), Data_Type = data_types)
output_csv <- file.path(output_folder, "data_types.csv")
write.csv(data_types_df, file = output_csv, row.names = FALSE)
print(data_types_df)



-----------------------------------------------------------------------
  ################### Addressing Dataset Flaws #######################
-----------------------------------------------------------------------
# Remove rows with all missing values
data_clean_rows <- data %>%
  filter(rowSums(!is.na(select(., `1960`:ncol(.)))) > 0)

# Remove columns with all missing values
data_clean_rows_cols <- data_clean_rows %>%
  select(where(~ any(!is.na(.))))

# Save the cleaned dataset
data_clean <- data_clean_rows_cols
cleaned_output_csv <- file.path(output_folder, "data_clean.csv")
write.csv(data_clean, file = cleaned_output_csv, row.names = FALSE)
cat("Number of removed countries:", nrow(data) - nrow(data_clean_rows), "\n")
cat("Number of removed columns:", ncol(data) - ncol(data_clean_rows_cols), "\n")

# Extract the names of rows (countries) with all missing values
removed_countries <- data %>%
  filter(rowSums(!is.na(select(., `1960`:ncol(.)))) == 0) %>%
  pull(Country_Name)
# Create a data frame with removed Country_Name
Removed_Country_Name_df <- data.frame(Removed_Country_Name = removed_countries)
removed_countries_csv <- file.path(output_folder, "removed_countries.csv")
write.csv(Removed_Country_Name_df, file = removed_countries_csv, row.names = FALSE)

# Extract the names of removed columns
removed_columns <- setdiff(names(data), names(data_clean))
# Create a data frame with removed columns' names
removed_columns_df <- data.frame(Removed_Column_Name = removed_columns)
removed_columns_csv <- file.path(output_folder, "removed_columns.csv")
write.csv(removed_columns_df, file = removed_columns_csv, row.names = FALSE)

# Reshape data_clean from a wide format (where each year has its own column)
# to a long format (where each year and its corresponding water index are in separate rows). 
data_clean_reshaped <- data_clean %>%
  pivot_longer(cols = starts_with("2"), 
               names_to = "year", 
               values_to = "water_index") %>%
  mutate(year = as.integer(year)) %>%
  rename(Country_Name = `Country_Name`)
data_clean_reshaped_csv <- file.path(output_folder, "data_clean_reshaped.csv")
write.csv(data_clean_reshaped, file = data_clean_reshaped_csv, row.names = FALSE)



summary_stats <- summary(data_clean)
print(summary_stats)
summary_stats_df <- as.data.frame(summary_stats)



--------------------------------------------------------------------
###############################  Plots #################################
--------------------------------------------------------------------
  
# Create a new folder for saving plots
plots_folder <- file.path(script_path, "plots")
dir_create(plots_folder)  # Create the new folder if it doesn't exist

# Create the box plot
boxplot_by_year <- ggplot(data_clean_reshaped, aes(x = factor(year), y = water_index)) +
  geom_boxplot(fill = "skyblue", color = "black") +
  labs(title = "Box Plot of Access to Water Services(%) by Year",
       x = "Year",
       y = "Access to Water Services(%)") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "bold"),
    title = element_text(face = "bold"),
    legend.position = "none"
  )

# Save the box plot as an image
output_boxplot <- file.path(plots_folder, "boxplot.png")
ggsave(output_boxplot, plot = boxplot_by_year, width = 8, height = 6)

# Print the box plot
print(boxplot_by_year)



# Correlation matrix without interpolating the missing values
# Create a custom color palette with light blue
my_color_palette <- c("orange", "white", "lightblue")

# Create the correlation plot
cor_plot <- ggplot(data = correlation_df, aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile(data = subset(correlation_df, Freq != 0), show.legend = FALSE) +
  scale_fill_gradientn(colors = my_color_palette) +
  geom_text(data = subset(correlation_df, Freq != 0),
            aes(label = round(Freq, 2)),
            #color = ifelse(correlation_df$Freq >= 0.98, "white", "black"),
            fontface = "bold") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "bold"),
    legend.position = "none",
    plot.title = element_text(size = rel(1.5), face = "bold")  # Format the title
  ) +
  labs(x = NULL, y = NULL,
       title = "Correlation Matrix of Numeric Variables")  # Add the title here

# Save the correlation plot as an image
output_correlation_plot <- file.path(plots_folder, "correlation_plot_no_filled_data.png")
ggsave(output_correlation_plot, plot = cor_plot, width = 10, height = 8)

# Print the correlation plot
print(cor_plot)



----------------------------------------------------------------------
####################### Rows with missing values #####################
---------------------------------------------------------------------
# Filter rows with missing values
rows_with_missing <- data_clean[rowSums(is.na(data_clean[, 5:ncol(data_clean)])) > 0, ]

# Create a directory to save the missing value plots
missing_value_plots_folder <- file.path(plots_folder, "missing_value_plots")
dir_create(missing_value_plots_folder, showWarnings = FALSE)

# Create a plot for each row with missing values and save it
for (i in 1:nrow(rows_with_missing)) {
  row_data <- rows_with_missing[i, ]
  
  # Extract years and values for plotting
  years <- as.numeric(colnames(row_data)[5:ncol(row_data)])
  values <- as.numeric(row_data[, 5:ncol(row_data)])
  
  # Extract years of missing values
  missing_years <- years[is.na(values)]
  
  # Extract country name
  country_name <- row_data$Country_Name
 
  
  # Create a plot using the extracted data
  plot <- ggplot() +
    geom_line(data = data.frame(years = years, values = values), aes(x = years, y = values),
              color = "blue", size = 2.5) +  # Increase the size parameter for thicker line
    geom_point(data = data.frame(years = years, values = values),
               aes(x = years, y = values), color = "blue", size = 3) +
    geom_text(data = data.frame(years = missing_years, values = rep(0, length(missing_years))),
              aes(x = years, y = rep(0, length(missing_years)), label = "X"),
              color = "red", size = 10, fontface = "bold") +
    labs(title = paste("Missing Values for", country_name),
         y = "Safely Managed Water (% of Pop.)") +
    scale_color_manual(values = c("blue", "red"), labels = c("Non-Missing Values", "Missing Values"),
                       breaks = c("blue", "red")) +
    theme_minimal() +  # Apply a white background
    theme(legend.text = element_text(size = 16, face = "bold", color = "black"),
          axis.text.x = element_text(size = 16, face = "bold", color = "black", angle = 45, hjust = 1),
          axis.text.y = element_text(size = 16, face = "bold", color = "black"),
          legend.key.size = unit(1.5, "lines"),
          legend.title = element_blank(),
          legend.position = "bottom",
          plot.title = element_text(size = 18, face = "bold"),  # Increase title font size and make it bold
          axis.title = element_text(size = 18, face = "bold"))  # Increase axis title font size and make it bold
  
  
  # Save the plot as an image
  output_file <- file.path(missing_value_plots_folder, paste0("missing_values_plot_", i, ".png"))
  ggsave(output_file, plot, width = 12, height = 9, units = "in", limitsize = FALSE)
}

-------------------------------------------------------------------------
######################## Fill the missing values ########################
-------------------------------------------------------------------------
### Time series from 2000 to 2020
  
# Linearly interpolate missing values for each row
data_clean_filled <- data_clean %>%
mutate(across(`2000`:`2020`, ~ ifelse(is.na(.), approx(seq_along(.), ., xout = seq_along(.))$y, .)))
# Save the data_clean_filled dataframe as CSV in the "output_csv" folder
output_data_clean_path <- file.path(script_path, "output_csv", "data_clean_filled.csv")
write.csv(data_clean_filled, file = output_data_clean_path, row.names = FALSE)


#Reshape the data_clean_interpolated to have one column for years and another for 
#the water index
data_clean_filled_reshaped <- data_clean_filled %>%
  pivot_longer(cols = starts_with("2"), 
               names_to = "year", 
               values_to = "water_index") %>%
  mutate(year = as.integer(year))


# Save the data_clean_filled_reshaped dataframe as CSV in the "output_csv" folder
output_data_clean_reshaped_path <- file.path(script_path, "output_csv", "data_clean_filled_reshaped.csv")
write.csv(data_clean_filled_reshaped, file = output_data_clean_reshaped_path, row.names = FALSE)


# Summary Statistics 
summary_stats_filled <- summary(data_clean_filled)
print(summary_stats_filled) 

-------------------------------------------------------------------------
########################## New Plots ####################################
-------------------------------------------------------------------------

# Create Box Plot
boxplot_by_year_filled <- ggplot(data_clean_filled_reshaped, aes(x = factor(year), y = water_index)) +
  geom_boxplot(fill = "blue", color = "grey") +  # Adding fill color and outline color
  labs(title = "Box Plot of access to water services(%) by Year- Filling missing data",
       x = "Year",
       y = "Access to water services(%)") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),  # Make x-axis tick labels bold
    axis.text.y = element_text(face = "bold"),  # Make y-axis tick labels bold
    title = element_text(face = "bold"),  # Make title bold
    legend.position = "none"
  )

# Save the box plot as an image in the "plots" folder
output_boxplot_filled <- file.path(plots_folder, "boxplot_filling_data.png")
ggsave(output_boxplot_filled, plot = boxplot_by_year_filled, width = 8, height = 6, units = "in", limitsize = FALSE)
print(boxplot_by_year_filled)



# Correlation matrix
correlation_matrix_filled <- cor(data_clean_filled %>% select_if(is.numeric))

# Convert the correlation matrix to a data frame
correlation_df_filled <- as.data.frame(as.table(correlation_matrix_filled))

# Create a custom color palette
my_color_palette <- c("blue", "white", "red")

# Create the correlation plot with filled data
cor_plot_filled <- ggplot(data = correlation_df_filled, aes(x = Var1, y = Var2, fill = Freq)) +
  geom_tile(data = subset(correlation_df_filled, Freq != 0), show.legend = FALSE) +
  scale_fill_gradientn(colors = my_color_palette) +
  geom_text(data = subset(correlation_df_filled, Freq != 0),
            aes(label = round(Freq, 2)),
            fontface = "bold") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold"),
    axis.text.y = element_text(face = "bold"),
    legend.position = "none",
    plot.title = element_text(size = rel(1.5), face = "bold")  # Format the title
  ) +
  labs(x = NULL, y = NULL,
       title = "Correlation Matrix of Numeric Variables (Filled Data)")  # Add the title here

# Save the filled correlation plot as an image in the "plots" folder
output_correlation_plot_filled <- file.path(plots_folder, "correlation_plot_filled_data.png")
ggsave(output_correlation_plot_filled, plot = cor_plot_filled, width = 10, height = 8, units = "in", limitsize = FALSE)

# Print the filled correlation plot
print(cor_plot_filled)



