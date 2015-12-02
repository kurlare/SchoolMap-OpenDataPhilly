## Server.R For Philly School App

library(shiny)
library(DT)
library(ggplot2)
library(ggmap)
library(leaflet)

school_df <- read.csv("compiledschooldata.csv", header = T, stringsAsFactors = F)

pal  <- colorQuantile(
    palette = c("darkgreen", "orange", "red"),
    domain = school_df$Incidents.Per.100,
    n = 6)

pal2 <- colorQuantile(
    palette = c("darkgreen", "orange", "red"),
    domain = school_df$Suspensions.Per.100,
    n = 6)


school_popup <- paste("<strong>School:</strong>", 
                      school_df$school_name, 
                      "<br><strong>Overall City Rank:</strong>",
                      school_df$overall_city_rank,
                      "<br><strong>Enrollment:</strong>",
                      school_df$Enrollment.x,
                      "<br><strong>Serious Incidents Per 100 Students: </strong>", 
                      school_df$Incidents.Per.100,
                      "<br><strong>Suspensions Per 100 Students:</strong>",
                      school_df$Suspensions.Per.100,
                      "<br><strong>Percent Native American:</strong>",
                      school_df$Percent.Native.American.y,
                      "<br><strong>Percent Asian:</strong>",
                      school_df$Percent.Asian.y,
                      "<br><strong>Percent Black:</strong>",
                      school_df$Percent.Black.y,
                      "<br><strong>Percent Multirace:</strong>",
                      school_df$Percent.Multirace.y,
                      "<br><strong>Percent Pacific Islander:</strong>",
                      school_df$Percent.Pacific.Islander.y,
                      "<br><strong>Percent White:</strong>",
                      school_df$Percent.White.y)


shinyServer(function(input, output) {
    output$philly_map <- renderLeaflet({
      leaflet(data = school_df, width = 500) %>% 
        addProviderTiles("Hydda.Full") %>% 
        addCircleMarkers(fill = T, radius = ~Enrollment.x * .008, 
                         fillOpacity = 0.7,
                         color = ~pal(Incidents.Per.100), 
                         popup = school_popup, 
                         group = "Serious Incidents") %>%
        addCircleMarkers(fill = T, radius = ~Enrollment.x * .008, 
                         fillOpacity = 0.7,
                         color = ~pal2(Suspensions.Per.100), 
                         popup = school_popup, 
                         group = "Suspensions") %>%
        addLayersControl(
            overlayGroups = c("Serious Incidents", "Suspensions"),
            options = layersControlOptions(collapsed = FALSE)
            ) %>%
        addLegend(position = 'bottomright', pal = pal, values = school_df$Incidents.Per.100,
                  na.label = "Charter School", title = "Behavioral Incidents 2013-2014")
    })
    
    output$table <- DT::renderDataTable(DT::datatable({
       school_df[, c(4,5,7,8,10,12)]
    }, options = list(
        autoWidth = TRUE,
        columnDefs = list(list(width = '150px', targets = "_all"))
    )))
})