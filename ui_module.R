# Load required libraries
library(shiny)  # Essential for Shiny app
library(fontawesome)  # For icons in the sidebar
library(shinydashboard)  # For dashboard layout
library(DT)  # For data tables
library(leaflet)  # For map output
library(plotly)  # For interactive plots

app_ui <- dashboardPage(
  skin = "black",  # Modern dark theme
  dashboardHeader(
    title = div("Appsilon", style = "font-size: 24px; font-weight: bold; color: #ffffff;"),
    titleWidth = 200
  ),
  
  dashboardSidebar(
    width = 250,
    sidebarMenu(
      selectInput("country", "Select Country", choices = NULL, selected = "All", selectize = FALSE),
      sliderInput("year", "Select Year", min = 1983, max = 2020, value = c(1983, 2020), step = 1, sep = ""),
      selectInput("month", "Select Months",
                  choices = list("Jan" = 1, "Feb" = 2, "Mar" = 3, "Apr" = 4, "May" = 5, "Jun" = 6,
                                 "Jul" = 7, "Aug" = 8, "Sep" = 9, "Oct" = 10, "Nov" = 11, "Dec" = 12),
                  multiple = TRUE,  # Enable multi-selection
                  selectize = TRUE),
      menuItem("About Me", icon = icon("linkedin"), href = "https://www.linkedin.com/in/chukwudi-ogbuta-382a1626b"),
      menuItem("View Other Projects", icon = icon("github"), href = "https://chukwudi-ogbuta.github.io/Cogbuta.github.io/")
    )
  ),
  
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    fluidPage(
      br(),
      titlePanel(title = div(img(src = "R.jpg", height = 50, width = 100), "Biodiversity Insights", 
                             style = "font-size: 28px; font-weight: bold; color: #2c3e50;")),
      
      # Search Bar
      selectizeInput("search_name", "Search by Scientific or Vernacular Name",
                     choices = NULL,
                     options = list(placeholder = "Enter name...", create = FALSE, allowEmptyOption = TRUE)),
      
      # Value Boxes (Visible in Both Tabs)
      fluidRow(
        valueBoxOutput("species_count", width = 6),
        valueBoxOutput("observations_count", width = 6)
      ),
      
      # Tabs
      tabsetPanel(
        tabPanel("Map & Data", 
                 fluidRow(
                   column(6, wellPanel(leafletOutput("map"))),  # Map output
                   column(6, wellPanel(DT::dataTableOutput("data_table")))  # Data table output
                 )
        ),
        tabPanel("Analysis",
                 fluidRow(
                   column(6, wellPanel(plotlyOutput("bar_sex"))),  # Interactive plot for sex distribution
                   column(6, wellPanel(plotlyOutput("line_plot")))  # Interactive line plot
                 )
        )
      )
    )
  )
)
