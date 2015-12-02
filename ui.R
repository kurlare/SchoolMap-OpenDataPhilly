## User Interface for Philly School Data Explorer
library(leaflet)
library(DT)
shinyUI(fluidPage(theme = "bootstrap.css",
                  
                  titlePanel(strong("Philadelphia Schools Behavioral Map")),
                          fluidRow(
                            column(12,
                                   helpText("Each circle represents a school in the Philadelphia School
                                            District.  The size of circle corresponds to the total enrollment,
                                            while the color illustrates which quantile the school falls into for
                                            suspensions and serious incidents (per 100 students).  
                                            Use the checkboxes to select which overlay to display.  To see
                                            more detailed information for a school, click on a circle.  
                                            'City Rank' is an academic metric based on progress reports conducted
                                            by the School District.",
                                            br(),
                                            "Check back soon for a more detailed analysis of this data.",
                                            p(),
                                            "All data was compiled from",
                                            a("OpenDataPhilly.", href="https://www.opendataphilly.org/group/education-group"))
                          ),
                  
                          fluidRow(
                            leafletOutput("philly_map", width = '99%')
                          ),
                  
                          fluidRow(
                            DT::dataTableOutput("table", width = '99%')
                              
                          )
                          
                        )
                        
                      )
)





