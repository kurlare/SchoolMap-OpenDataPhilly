## Server.R For Philly School App

library(shiny)
library(DT)
library(ggplot2)
library(ggmap)
library(leaflet)

school_df <- read.csv("compiledschooldata.csv", header = T, stringsAsFactors = F)
school_df <- school_df[-1]

pal <- colorNumeric(
  palette = c("#FF9933", "darkred"),
  domain = school_df$Serious.Incidents)


shinyServer(function(input, output) {
    output$philly_map <- renderLeaflet({
      
      leaflet(data = school_df) %>% 
        addProviderTiles("CartoDB.Positron") %>% 
        addCircleMarkers(fill = T, radius = ~Enrollment.x * .008, fillOpacity = 0.7,
                         color = ~pal(Serious.Incidents)) %>%
        addLegend(position = 'bottomright', pal = pal, values = school_df$Serious.Incidents,
                  na.label = "Charter School (Data Not Avail.)", title = "Serious Incidents 2013-2014")
    })
    
    output$table <- DT::renderDataTable(DT::datatable({
       school_df
        
    }))
})