# Required Libraries  
library(shiny)  
library(tidyverse)  
library(shinydashboard)  
library(leaflet)  
library(DBI)  
library(RPostgres)  
library(data.table)  
library(DT)  
library(plotly)  
library(lubridate)  
library(ggthemes)  

# Global variable to store data persistently in memory  
bio_data <- reactiveVal(NULL)  

app_server <- function(input, output, session) {  
  
  # Connect to PostgreSQL  
  con <- dbConnect(RPostgres::Postgres(),
                    dbname = "database_name",
                    host = "your_host",  
                    port = 5432,        
                    user = "your_username",
                    password = "your_password")
  
  # Load data only if not already in memory  
  observe({  
    if (is.null(bio_data())) {  
      df <- as.data.table(dbGetQuery(con, "SELECT * FROM bio"))  
      bio_data(df)  
    }  
  })  
  
  # Data processing: Filtering and adding computed columns  
  clean_df_reactive <- reactive({  
    req(bio_data())  
    bio_data() %>%  
      filter(individualcount <= quantile(individualcount, probs = 0.99)) %>%  
      mutate(  
        abundancelevel = case_when(  
          individualcount < 20 ~ "Low",  
          individualcount < 40 ~ "Moderate",  
          TRUE ~ "High"  
        ),  
        radius = case_when(  
          individualcount < 20 ~ 4,  
          individualcount < 40 ~ 8,  
          TRUE ~ 13  
        )  
      )  
  })  
  
  # Ensure database disconnects when the app stops  
  onStop(function() {  
    dbDisconnect(con)  
  })  
  
  # Update dynamic searchlist for scientificname and vernacularname
  observe({
    req(clean_df_reactive())  
    all_names <- sort(unique(c(clean_df_reactive()$scientificname, clean_df_reactive()$vernacularname)))
    updateSelectizeInput(session, "search_name", choices = c("", all_names), selected = "", server = TRUE)
  }) 
  
  # Update country dropdown  
  observe({  
    updateSelectInput(session, "country", choices = c("All", sort(unique(clean_df_reactive()$country))))  
  })  
  
  # Filter data based on user input  
  filtered_data <- reactive({  
    data <- clean_df_reactive()  
    
    if (!is.null(input$search_name) && input$search_name != "") {  
      data <- data %>% filter(grepl(input$search_name, scientificname, ignore.case = TRUE) |  
                                grepl(input$search_name, vernacularname, ignore.case = TRUE))  
    }  
    
    if (!is.null(input$year) && length(input$year) == 2) {  
      data <- data %>% filter(between(year(eventdate), input$year[1], input$year[2]))  
    }  
    
    if (!is.null(input$month)) {  
      data <- data %>% filter(month(eventdate) %in% input$month)  
    }  
    
    if (!is.null(input$country) && input$country != "All") {  
      data <- data %>% filter(country == input$country)  
    }  
    
    return(data)  
  })  
  
  # Value boxes  
  output$species_count <- renderValueBox({  
    req(filtered_data())  
    species_count <- filtered_data() %>% distinct(scientificname) %>% nrow()  
    valueBox(format(species_count, big.mark = ","), "Distinct Species", icon = icon("leaf"), color = "black")  
  })  
  
  output$observations_count <- renderValueBox({  
    req(filtered_data())  
    observations_total <- sum(filtered_data()$individualcount, na.rm = TRUE)  
    valueBox(format(observations_total, big.mark = ","), "Total Observations", icon = icon("binoculars"), color = "black")  
  })  
  
  # Leaflet map visualization  
  output$map <- renderLeaflet({  
    color_levels <- colorFactor(palette = c('red', 'yellow', 'darkgreen'), levels = c("Low", "Moderate", "High"))  
    leaflet(filtered_data()) %>%  
      addTiles() %>%  
      addProviderTiles(providers$CartoDB.DarkMatter) %>%  
      addCircleMarkers(  
        lng = ~longitudedecimal, lat = ~latitudedecimal,  
        label = lapply(paste("<strong>Name:</strong>", filtered_data()$scientificname,  
                             "<br/><strong>Count:</strong>", filtered_data()$individualcount,  
                             "<br/><strong>Level:</strong>", filtered_data()$abundancelevel), HTML),  
        radius = ~radius, color = ~color_levels(abundancelevel)  
      )  
  })  
  
  # Line plot for observations trend  
  output$line_plot <- renderPlotly({
    p <- filtered_data() %>%
      group_by(year = lubridate::year(eventdate), country) %>%
      summarise(total_count = sum(individualcount, na.rm = TRUE), .groups = "drop") %>%
      ggplot(aes(x = year, y = total_count, color = country, group = country, 
                 text = paste("Year:", year, "<br>Total Individual Count:", total_count))) +
      geom_line(size = 0.8, linetype = "dotted") +
      geom_point(size = 1.5, shape = 16) +
      scale_color_manual(values = ggthemes::tableau_color_pal("Tableau 10")(length(unique(filtered_data()$country)))) +
      labs(title = "Trend of Observations Over Years",
           x = "Year",
           y = "Total Individual Count",
           color = "Country") +
      theme_tufte() +
      theme(plot.title = element_text(hjust = 0.5, size = 13, face = 'bold'),
            axis.text = element_text(size = 10),
            axis.title = element_text(size = 10),
            legend.position = "right",
            legend.text = element_text(size = 8),
            plot.margin = margin(1, 1, 1, 1, "cm"))
    
    ggplotly(p, tooltip = "text")
  })
  
  # Bar chart for sex distribution  
  output$bar_sex <- renderPlotly({
    p_sex <- filtered_data() %>%
      group_by(sex) %>%
      summarise(total_count = sum(individualcount, na.rm = TRUE), .groups = "drop") %>%
      mutate(percentage = (total_count / sum(total_count)) * 100) %>%
      ggplot(aes(x = sex, y = total_count, fill = sex, 
                 text = paste("Sex:", sex, "<br>Total Count:", total_count, "<br>Percentage:", round(percentage, 1), "%"))) +
      geom_col(width = 0.6, show.legend = FALSE) +
      geom_text(aes(label = paste0(total_count, " (", round(percentage, 1), "%)")), 
                vjust = -0.5, size = 2.5, fontface = "bold", color = "black") +
      scale_fill_manual(values = ggthemes::tableau_color_pal("Tableau 10")(length(unique(filtered_data()$sex)))) +
      labs(title = "Sex Distribution",
           x = "Sex",
           y = "Total Individual Count") +
      theme_minimal() +
      theme(plot.title = element_text(hjust = 0.5, size = 13, face = 'bold'),
            axis.text = element_text(size = 10),
            axis.title = element_text(size = 10),
            plot.margin = margin(1, 1, 1, 1, "cm"))
    
    ggplotly(p_sex, tooltip = "text")
  })  
  
  # Data table output  
  output$data_table <- renderDT({  
    table_data <- filtered_data() %>%  
      group_by(country, scientificname) %>%  
      summarise(`total count` = sum(individualcount, na.rm = TRUE), .groups = "drop") %>%  
      arrange(desc(`total count`)) %>%  
      rename(`scientific name` = scientificname)  
    
    datatable(  
      table_data,  
      options = list(  
        pageLength = 6,  
        dom = 'Bfrtip',  
        buttons = c('copy', 'csv', 'excel', 'pdf', 'print')  
      ),  
      rownames = FALSE  
    ) %>%  
      formatStyle(columns = colnames(table_data), fontSize = '12px', color = 'black')  
  })  
}  
