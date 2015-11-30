## User Interface for Philly School Data Explorer

shinyUI(fluidPage(
                  titlePanel(strong("Philadelphia Schools Explorer")),
                          fluidRow(
                            column(4,
                                   helpText("Select a variable to see incidents",
                                   "across the city.  Charter Schools are ",
                                   "plotted in gray, other schools in color.",
                                   "Click on a point to bring up more detailed information.")),
                            column(4,
                                   selectInput("color_var", label = "Select Color Variable:",
                                               choices = c("Serious.Incidents", "Total.Suspensions", "Enrollment.x"),
                                               selected = "Serious.Incidents")),
                            column(4, 
                                   selectInput("size_var", label = "Select Size Variable:", 
                                               choices = c("Serious.Incidents", "Total.Suspensions", "Enrollment.x"),
                                               selected = "Enrollment.x"))
                          ),
                  
                          fluidRow(
                            leafletOutput("philly_map")
                          ),
                  
                          fluidRow(
                            DT::dataTableOutput("table")
                              
                          )
                          
                        )
                        
                      )
                  


