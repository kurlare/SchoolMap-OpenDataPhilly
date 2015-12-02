## SchoolMap-OpenDataPhilly

This repository contains files to run an interactive map application in Shiny.  It contains four files:

1.  **schoolanalysis.R** - This is a R script to read in the various files taken from www.opendataphilly.org, clean the data,
    and consolidate the relevant columns into one table.
    
2.  **compiledschooldata.csv** - This is a .csv file with data from the School District of Philadelphia.  It contains information on 
    demographics, enrollment, crime/suspensions, and city-wide rankings from school progress reports.  It also contains geospatial values
    for locating the schools on a map.
    
3.  **ui.R** - This is a R script containing code for the application user interface.

4.  **server.R** - This is a R script containing code for the output displayed in ui.R  

In order for the app to run locally, you need to have the compiledschooldata.csv, server.R, and ui.R files in your working directory.  
You will also need to install several packages, namely Shiny, Leaflet, dplyr, and DT.  

All data for this project can be found at www.opendataphilly.org.  The specific file names can be gleaned from schoolanalysis.R.

If you have any questions, please email me at rafi.kurlansik@gmail.com!
