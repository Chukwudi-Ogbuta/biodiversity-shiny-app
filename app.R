# Load required libraries
library(shiny)
library(shinydashboard)

# Source external modules for UI, Server, and Data Handling
source("modules/ui_module.R")
source("modules/server_module.R")

# Initialize and run the Shiny app
shinyApp(ui = app_ui, server = app_server)