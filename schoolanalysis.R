## This is a script to prepare and analyze the Philadelphia School District Data
require(readxl)
require(dplyr)
require(data.table)
require(xlsx)

## Read in latest demographic data, clean up column names
stu_eth_dem <- read.xlsx(file = '2014-2015 enrollment & demographics.xlsx',
                     sheetIndex = 5,
                     startRow = 6,
                     header = T)

colnames(stu_eth_dem) <- c('src_school_id', 'School.Name', 'Grade', 'Enrollment',
                       'Count.Native.American', 'Percent.Native.American',
                       'Count.Asian', 'Percent.Asian', 'Count.Black',
                       'Percent.Black', 'Count.Hispanic', 'Percent.Hispanic',
                       'Count.Multirace', 'Percent.Multirace', 'Count.Pacific.Islander',
                       'Percent.Pacific.Islander', 'Count.White', 'Percent.White')
stu_eth_dem <- stu_eth_dem[stu_eth_dem$Grade == "All Grades",]
##stu_eth_dem <- stu_eth_dem[, -c(1:3)]
stu_eth_dem$Enrollment <- as.numeric(stu_eth_dem$Enrollment)
stu_eth_dem$src_school_id <- as.factor(stu_eth_dem$src_school_id)



## Get Suspensions and Serious Incidents
suspensions <- fread('School Profiles Suspensions 2013-2014.txt',
                        select = c(1,5),
                        header = T)
colnames(suspensions) <- c("School.ID", "Unique.Suspensions")
suspensions$School.ID <- as.numeric(suspensions$School.ID)


ser_inc <- read.csv('School Profiles Serious Incidents 2013-2014.txt', header = T)
colnames(ser_inc)[1] <- "School.ID"

## Aggregate serious incidents by school
ser_inc <- summarise(group_by(ser_inc, School.ID), Serious.Incidents = sum(INCIDENT_COUNT))


## Get Test Scores and School Performance Metrics
sch_testscores <- read_excel('PSSA-Keystones-2013-2014-Actual.xlsx',
                             sheet = 2,
                             skip = 6)

colnames(sch_testscores) <- c("Test.Name", "Subject", "School.Code", "School.Name",
                              "Grade", "Category", "Mean.Scaled.Score", "Number.Tested",
                              "Level.1.Count", "Level.1.Percent", "Level.2.Count",
                              "Level.2.Percent", "Level.3.Count", "Level.3.Percent",
                              "Level.4.Count", "Level.4.Percent", "Levels.3.4.Count", 
                              "Levels.3.4.Percent")

sch_spr <- read.csv('2013-2014_SCHOOL_PROGRESS_REPORT_20150428.xls', 
                    header = T, 
                    na.strings = c('999', '995', '996'))

colnames(sch_spr)[1] <- "School.ID"

grep("city_rank", colnames(sch_spr)) ## Gives Index of Rankings

sch_spr <- sch_spr[, c(1, 2, 5, 22, 28, 36, 44, 52)]

## Get School Locations
school_info <- read.csv('Schools.csv', header = T)

colnames(school_info)[1:2] <- c("Longitude", "Latitude")

## school_info$Location <- paste(school_info$Latitude, school_info$Longitude, sep = ":")

## Consolidate data into one dataframe 
school_df <- data.frame(school_info$Longitude, school_info$Latitude, school_info$LOCATION_ID,  
                        school_info$ENROLLMENT, school_info$GRADE_LEVEL)

school_df <- school_df[!is.na(school_df$school_info.LOCATION_ID),]  ## Removes Private Schools
colnames(school_df) <- c("Longitude", "Latitude", "School.ID", "Enrollment", "Grade.Level")
school_df <- left_join(school_df, sch_spr[, 1:4], by = 'School.ID')  ## Add overall city rank
school_df <- left_join(school_df, ser_inc, by = 'School.ID')  ## Add Serious Incidents, per 100
school_df$Incidents.Per.100 <- round((school_df$Serious.Incidents/school_df$Enrollment)*100, 2)

school_df <- left_join(school_df, suspensions, by = 'School.ID')  ## Add Suspensions, per 100
school_df$Suspensions.Per.100 <- round((school_df$Unique.Suspensions/school_df$Enrollment)*100,2)

school_df <- left_join(school_df, stu_eth_dem, by = 'src_school_id') ## Add Demographics
school_df <- school_df[, -c(13,14,15)] ## Remove Duplicate columns
school_df <- school_df[!is.na(school_df$school_name),] ## Remove rows with empty school names

## Convert factors to numeric, join numerics, drop factors
schooldat <- as.data.frame(apply(subset(school_df, select = c(School.ID,Count.Native.American:Percent.White)), 2, as.numeric))
school_df <- left_join(school_df, schooldat, by = 'School.ID')
drops <- colnames(school_df)[13:26]
school_df <- school_df[, !names(school_df) %in% drops]
school_df$Longitude <- round(as.numeric(school_df$Longitude), 3)
school_df$Latitude <- round(as.numeric(school_df$Latitude), 3)
school_df[, 13:26] <- round(school_df[,13:26], 2) ## Round demographic numbers
school_df <- school_df[!is.na(school_df$Enrollment.x), ] ## Drop rows with no enrollment
school_df <- distinct(school_df) ## Remove any duplicates



## Write to csv
write.csv(school_df, "compiledschooldata.csv", header = T, stringsAsFactors = F)




## Subset Charter Schools
pub_schools <- school_df[!is.na(school_df$Serious.Incidents),]
pub_schools <- pub_schools[pub_schools$Serious.Incidents > 0,]
chart_schools <- school_df[is.na(school_df$Serious.Incidents),]


<<<<<<< HEAD
## GGvis plot (doesn't really work)
=======
## Plot in GoogleVis (doesn't work due to scale issues)
>>>>>>> origin/master

s1 <- gvisGeoChart(school_df, 
                   locationvar = "Location", 
                   colorvar = "Serious.Incidents", 
                   hovervar = "overall_city_rank",
                   options = list(region = '504'))

## GGMap plot

phl <- get_map(location ='philadelphia', zoom = 11, source = "google", maptype = 'roadmap')

ggmap(phl) + 
    geom_point(data = pub_schools, aes(x = Longitude, y = Latitude,
                                                size = Enrollment.x, 
                                                color = Serious.Incidents)) + 
    scale_size_area(max_size = 15) + 
    scale_color_gradient(breaks = seq(0,225,25),
                         low = "#FF9933", high = 'darkred',
                         space = "Lab",
                         na.value = "grey50",
                         guide = "colourbar") + 
    geom_point(data = pub_schools, aes(Longitude, Latitude), 
               shape = 1, 
               size = 3, 
               color = 'red') + 
    geom_point(data = chart_schools, aes(x = Longitude, y = Latitude), 
               size = 4.5, 
               alpha = 0.3, 
               color = '#666666') +
    geom_point(data = chart_schools, aes(x = Longitude, y = Latitude))

## Leaflet Plot

pal <- colorNumeric(
    palette = c("#FF9933", "darkred"),
    domain = school_df$Serious.Incidents)


leaflet(data = school_df) %>% 
    addTiles() %>% 
    addCircleMarkers(fill = T, radius = ~Enrollment.x * .008, fillOpacity = 0.7,
                     color = ~pal(Serious.Incidents))



