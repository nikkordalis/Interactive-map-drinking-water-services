# Interactive-map-drinking-water-services
Explore, clean, and gain insights from a dataset focusing on access to safely managed water services
In this data analysis and visualization project, I utilized R programming to explore, clean, and gain insights from a dataset focusing on access to safely managed water services. The project encompassed multiple stages, starting with data reading and cleaning, including the removal of missing values and transforming the data structure for analysis. I created informative visualizations such as a box plot that illustrated the distribution of water access percentages across various years, before and after filling missing data using linear interpolation. Additionally, interactive choropleth maps were generated to visualize the water index across different countries and years, allowing for dynamic exploration of trends. I also presented the countries with the lowest water index, shedding light on regions facing water access challenges. Below are the key steps outlined in my code for data processing and visualization:
R Source Files:

1_DatasetFlawsHandling

It is recommended to run code in chunks

1. Initial Data Import and Cleaning:
 Reading the data from a CSV file.
 Renaming columns and selecting relevant columns.
 Displaying summary statistics.
 Checking and saving data types.
2. Addressing Dataset Flaws:
 Removing rows with all missing values.
 Removing columns with all missing values.
 Saving cleaned data.
 Extracting and saving removed countries and columns.
 Reshaping the data.
3. Plotting and Visualization:
 Creating and saving box plots.
 Creating and saving a correlation matrix plot.
4. Rows with Missing Values:
 Filtering rows with missing values.
 Creating and saving missing value plots for individual rows.
5. Filling Missing Values:
 Linearly interpolating missing values.
 Saving the filled data.
 Creating and saving new plots for filled data.

2_Data Visualization

1. Bar Plot for Bottom 20 Countries:
 Calculating the mean water index for each country.
 Selecting the bottom 20 countries based on the mean water index.
 Creating a bar plot with the selected countries.
2. Time Series Line Plot for World Data:
 Reading the cleaned data.
 Filtering data for the "World" only.
 Reshaping the data for the line plot.
 Creating a line plot and converting it to an interactive Plotly plot.
 Saving the interactive Plotly plot as an HTML file.

3_Interactive_Maps

1. Interactive Choropleth Map:
 Read and prepare the cleaned dataset.
 Create a user interface (UI) for the Shiny app with input options for year and country selection.
 Generate a choropleth map using Plotly, displaying Safely Managed Water Index values for the selected year and countries.
 Include hover text for each country showing the Water Index. • Apply map layout settings, such as color scale and projection.
2. Time Series Line Chart:
 Prepare data for the line chart by filtering the dataset based on the selected country.
 Reshape the data to a long format suitable for a time series line chart.
 Create a Plotly line chart showing the Safely Managed Water Index trends over the years.
 Customize chart layout, including titles and axis labels.
3. Shiny App Server Logic:
 Define server logic for the Shiny app, linking user inputs to plot outputs.
 Render the choropleth map and time series line chart based on user selections.
4. Shiny App User Interface:
 Construct the user interface layout for the Shiny app, including title and sidebar panels.
 Provide input options for selecting years and countries.
 Display the interactive choropleth map and time series line chart.
5. Create and Run Shiny App:
 Assemble the Shiny app by combining the UI and server logic.
 Run the Shiny app, enabling users to interactively explore the Safely Managed Water Index data through the choropleth map and time series line chart.
