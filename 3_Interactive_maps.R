library(readr)
library(dplyr)
library(plotly)
library(shiny)

# Get the path of the current script
script_path <- dirname(rstudioapi::getActiveDocumentContext()$path)

# Read the data from the CSV file in the "output_csv" folder
data_path <- file.path(script_path, "output_csv", "data_clean_mapped.csv")
cleaned_data_mapped <- read.csv(data_path, header = TRUE, check.names = FALSE)

# Create UI for Shiny app
ui <- fluidPage(
  titlePanel("Interactive Map and Comparative Chart of Safely Managed Water Index"),
  sidebarLayout(
    sidebarPanel(
      selectInput("year_input", "Select Year", choices = colnames(cleaned_data_mapped)[3:(ncol(cleaned_data_mapped)-1)]),
      selectInput("country_input", "Select Country", choices = cleaned_data_mapped$Country_Name)
    ),
    mainPanel(
      plotlyOutput("choropleth_map"),
      plotlyOutput("line_chart")
    )
  )
)

# Server logic for Shiny app
server <- function(input, output) {
  output$choropleth_map <- renderPlotly({
    selected_year <- input$year_input
    
    # Filter data for the selected year
    year_data <- cleaned_data_mapped %>%
      select(Country_Name, all_of(selected_year))
    
    # Create a vector of all unique Country Names
    all_country_names <- unique(cleaned_data_mapped$Country_Name)
    
    # Identify missing Country Names for the selected year
    missing_countries <- setdiff(all_country_names, year_data$Country_Name)
    
    if (length(missing_countries) > 0) {
      # Create a data frame with missing Country Names and NA values for water index
      missing_data <- data.frame(Country_Name = missing_countries)
      for (col in colnames(year_data)[-1]) {
        missing_data[[col]] <- NA
      }
      
      # Combine missing data with the available data
      year_data <- bind_rows(year_data, missing_data)
    }
    
    # Create the choropleth map
    choropleth_map <- plot_geo(data = year_data, locationmode = 'country names') %>%
      add_trace(
        z = year_data[[selected_year]],
        locations = ~Country_Name,
        text = ~paste(Country_Name, "<br>Water Index:", 
                      ifelse(is.na(year_data[[selected_year]]), "No Data", format(round(year_data[[selected_year]], 2), nsmall = 2))),
        hoverinfo = "text",
        type = 'choropleth',
        colorscale = 'YlGnBu',
        reversescale = TRUE,
        marker = list(line = list(color = 'rgba(0,0,0,0.5)', width = 1)),
        colorbar = list(title = "Water Index")
      ) %>%
      layout(
        title = paste("Safely Managed Water Index (", selected_year, ")"),
        geo = list(
          showframe = TRUE,
          showcoastlines = TRUE,
          projection = list(type = 'mercator')
        )
      )
    
    choropleth_map
  })
  
  output$line_chart <- renderPlotly({
    selected_country <- input$country_input
    
    # Filter data for the selected country
    country_data <- cleaned_data_mapped %>%
      filter(Country_Name == selected_country)
    
    # Reshape data for the line chart
    country_data_long <- country_data %>%
      pivot_longer(cols = starts_with("2"), names_to = "Year", values_to = "Water_Index")
    
    # Create the line chart
    line_chart <- plot_ly(country_data_long, x = ~Year, y = ~Water_Index, type = 'scatter', mode = 'lines+markers') %>%
      layout(
        title = paste("Safely Managed Water Index for", selected_country),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Water Index")
      )
    
    line_chart
  })
}

# Create and run the Shiny app
shinyApp(ui = ui, server = server)

