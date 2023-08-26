library(dplyr) # For data manipulation and summarization
library(ggplot2) # For creating plots
library(plotly) # For interactive plotting
library(htmlwidgets) # For saving interactive plots as HTML files


# Get the path of the current script
script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Define the path to the "plots" folder
plots_folder <- file.path(script_path, "plots")

# Define the path to the "countries_explore" folder within the "plots" folder
countries_explore_folder <- file.path(plots_folder, "countries_explore")
dir_create(countries_explore_folder, showWarnings = FALSE)

-----------------------------------------------------------------------
####################### Worst Countries/Areas #########################
-----------------------------------------------------------------------
# Read the data from the CSV file in the "output_csv" folder
data_path <- file.path(script_path, "output_csv", "data_clean_reshaped.csv")
data_clean_reshaped <- read.csv(data_path)


mean_water_index_country <- data_clean_reshaped %>%
  group_by(Country_Name) %>%
  summarize(Mean_Water_Index = mean(water_index, na.rm = TRUE))
bottom_n_countries <- 20  # Set the number of top countries to display

# Order the data frame by Mean_Water_Index and select the bottom 20 countries
bottom_countries <- mean_water_index_country %>%
  arrange(Mean_Water_Index) %>%
  head(bottom_n_countries)  

# Create a bar plot for the mean water index of the bottom N countries
bottom_countries_plot <- ggplot(bottom_countries, aes(x = reorder(Country_Name, Mean_Water_Index), y = Mean_Water_Index)) +
  geom_bar(stat = "identity", fill = "blue") +
  labs(title = paste(bottom_n_countries, " bottom Countries"), x = "Country Name", y = "Safely Managed Water (% of Pop.)") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12),
    axis.title = element_text(face = "bold", size = 14),
    plot.title = element_text(face = "bold", size = 24, hjust = 0.5)
  )

# Save the bar plot as an image in the "countries_explore" folder
output_image <- file.path(countries_explore_folder, "20_bottom_countries_areas.png")
ggsave(output_image, bottom_countries_plot, width = 12, height = 8)
print(bottom_countries_plot)

-----------------------------------------------------------------------
####################### Safely Managed Water Services: Global Yearly Trends #############################
-----------------------------------------------------------------------

# Read the data from the CSV file in the "output_csv" folder
data_path <- file.path(script_path, "output_csv", "data_clean.csv")
data_clean <- read.csv(data_path, header = TRUE, check.names = FALSE)

# Filter data for the "World" only
world_data <- data_clean %>%
  filter(Country_Name == "World")

# Reshape the data to long format
world_data_long <- world_data %>%
  pivot_longer(cols = starts_with("2"), names_to = "Year", values_to = "Water_Index")

# Create a line plot for the water index of the "World" for each year
p <- ggplot(world_data_long, aes(x = Year, y = Water_Index)) +
  geom_line(color = "blue", size = 0.5, group = 1) +  # Add size parameter for the line and group for line connection
  geom_point(color = "blue", alpha = 0.7) +  # Add alpha parameter for dot opacity
  labs(x = "Year", y = "(% of Pop.)", title = "Global Safely Managed Water Trends") +
  theme_minimal() +
  theme(
    axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", size = 12),
    axis.text.y = element_text(face = "bold", size = 12),
    axis.title = element_text(face = "bold", size = 14),
    plot.title = element_text(face = "bold", size = 24, hjust = 0.5)  # Adjust size and alignment
  ) +
  scale_y_continuous(breaks = seq(0, 100, by = 2))  # Adjust y-axis breaks and ticks

# Convert ggplot plot to plotly object for interactivity
plotly_plot <- ggplotly(p, tooltip = c("x", "y"))

# Add a line trace to connect the dots
plotly_plot <- plotly_plot %>%
  add_trace(
    x = world_data_long$Year,
    y = world_data_long$Water_Index,
    type = "scatter",
    mode = "lines+markers",
    line = list(color = "blue", width = 1)
  )

# Save the interactive plot as an HTML file in the "countries_explore" folder
output_file <- file.path(countries_explore_folder, "Safely Managed Water Services Global Yearly Trends.html")
saveWidget(plotly_plot, file = output_file)

# Print the path to the saved HTML file
cat("Interactive plot saved as:", output_file, "\n")
print(plotly_plot)





# Convert ggplot plot to plotly object for interactivity
plotly_plot <- ggplotly(p, tooltip = c("x", "y"))

# Add a line trace to connect the dots
plotly_plot <- plotly_plot %>%
  add_trace(
    x = world_data_long$Year,
    y = world_data_long$Water_Index,
    type = "scatter",
    mode = "lines+markers",
    line = list(color = "blue", width = 1)
  )

# Save the interactive plot as an image using kaleido
output_image_file <- file.path(countries_explore_folder, "Safely_Managed_Water_Trends.png")
plotly::export(plotly_plot, file = output_image_file, width = 1200, height = 900)

# Print the path to the saved image file
cat("Image saved as:", output_image_file, "\n")
