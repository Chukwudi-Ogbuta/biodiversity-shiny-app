# Biodiversity Insights Dashboard

This Shiny application provides an interactive platform for visualizing and analyzing biodiversity data from various countries. The app allows users to filter data based on country, year, month, scientific name, and vernacular name, while also providing a variety of data visualizations, including maps, bar charts, and line plots.

### Key Features:
- **Dynamic Filtering:** Users can filter data by country, year range, month, and species (both scientific and vernacular names).
- **Interactive Visualizations:** Includes an interactive map, bar chart for sex distribution, and line plot for observation trends.
- **Data Table:** View detailed biodiversity data in a tabular format, with the ability to export to CSV, Excel, and other formats.
- **Country-Specific Data:** Currently supports Poland, Slovakia, and Lithuania.

### Libraries Used:
- `shiny`: For building the web application.
- `shinydashboard`: For creating a dashboard layout.
- `leaflet`: For displaying interactive maps.
- `plotly`: For creating interactive plots.
- `DT`: For displaying interactive data tables.
- `DBI` and `RPostgres`: For connecting to a PostgreSQL database to fetch and store biodiversity data.
- `lubridate`: For date manipulation.
- `ggthemes`: For improved plot themes.

### Setup Instructions:
1. Install required packages:
    ```r
    install.packages(c("shiny", "shinydashboard", "leaflet", "plotly", "DT", "DBI", "RPostgres", "lubridate", "ggthemes"))
    ```
   
2. Create a PostgreSQL database with your data and update the connection details in the server code (lines 12–14).

### How It Works:
1. **Data Connection**: The app connects to a PostgreSQL database where biodiversity data is stored. The data is loaded dynamically based on user filters.
2. **Dynamic Inputs**: 
    - `Select Country`: Choose from available countries (currently Poland, Slovakia, Lithuania).
    - `Select Year`: A slider to choose a range of years.
    - `Select Month`: Multi-select for choosing one or more months.
    - `Search by Scientific or Vernacular Name`: Allows searching species by either name.
   
3. **Visualizations**:
    - **Map**: Displays a map of biodiversity observations with color-coded markers based on abundance levels.
    - **Bar Chart**: Displays the distribution of observations by sex.
    - **Line Plot**: Shows trends in observations over time.
    - **Data Table**: A detailed table of biodiversity observations, sortable and filterable.

### Logging and Validation:
The application employs a logging mechanism using print statements and row count checks to ensure data validation before being passed to the visualization components. The data row count is printed in the logs to monitor changes and updates, ensuring data integrity throughout the app's operation.

### Example Workflow:
1. **Choose a Country**: Select a country from the drop-down menu.
2. **Select Year and Month**: Use the sliders to adjust the year and month range.
3. **Search Species**: Enter a species name to filter results.
4. **View Data**: View the filtered data on the map, data table, and in interactive plots.

### Files Included:
- `app_ui.R`: Contains the user interface code, defining the dashboard layout and input elements.
- `app_server.R`: Contains the server logic for processing and visualizing the data.
- `custom.css`: Custom styles for the app.

### Example Outputs:
- **Map**: Displays a world map with circles representing observation locations, color-coded by abundance level.
- **Bar Chart**: Shows the distribution of observations by sex (male/female).
- **Line Plot**: Displays a time series of observations, segmented by country.

### Links:
- [LinkedIn Profile](https://www.linkedin.com/in/chukwudi-ogbuta-382a1626b)
- [Other Projects](https://chukwudi-ogbuta.github.io/Cogbuta.github.io/)

---

**Note:** Make sure to replace the database connection details with your actual credentials for the app to work properly.
