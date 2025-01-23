
# ------------------------------------------------------------------------------
# Install packages if required
# install.packages(c('leaflet', 'openxlsx', 'tidyverse', 'geojsonio', 'sf', 'rgdal'))

suppressMessages(library(leaflet))
suppressMessages(library(openxlsx))
suppressMessages(library(tidyverse))
suppressMessages(library(sf))
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Clear environment and set local working folder
rm(list = ls())
setwd("U:/02 Reference/r/gis_choropleth/")
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Load lsoa data
hwics_lsoa <- read_sf("topo_E06000019.json") # hereford
hwics_lsoa <- rbind(hwics_lsoa, read_sf("topo_E07000234.json")) # bromsgrove
hwics_lsoa <- rbind(hwics_lsoa, read_sf("topo_E07000235.json")) # malvern
hwics_lsoa <- rbind(hwics_lsoa, read_sf("topo_E07000236.json")) # redditch
hwics_lsoa <- rbind(hwics_lsoa, read_sf("topo_E07000237.json")) # worcester city
hwics_lsoa <- rbind(hwics_lsoa, read_sf("topo_E07000238.json")) # wychavon
hwics_lsoa <- rbind(hwics_lsoa, read_sf("topo_E07000239.json")) # wyre forest

# Load county boundary data
hwics_lsoa_cons <- read_sf("topo_E06000019_constituency.json") # hereford
hwics_lsoa_cons <- rbind(hwics_lsoa_cons, read_sf("topo_E07000234_constituency.json")) # bromsgrove
hwics_lsoa_cons <- rbind(hwics_lsoa_cons, read_sf("topo_E07000235_constituency.json")) # malvern
hwics_lsoa_cons <- rbind(hwics_lsoa_cons, read_sf("topo_E07000236_constituency.json")) # redditch
hwics_lsoa_cons <- rbind(hwics_lsoa_cons, read_sf("topo_E07000237_constituency.json")) # worcester city
hwics_lsoa_cons <- rbind(hwics_lsoa_cons, read_sf("topo_E07000238_constituency.json")) # wychavon
hwics_lsoa_cons <- rbind(hwics_lsoa_cons, read_sf("topo_E07000239_constituency.json")) # wyre forest
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Load the data to set the choropleth.
activity_data = read_csv('act_test.csv')
hwics_lsoa = hwics_lsoa %>% 
  left_join(. , activity_data, by = c("id" = "lsoa")) # joins the piped in data

# Configure the map popup, add / remove areas to change the data displayed.
hwics_lsoa$popup <- paste("<strong>",hwics_lsoa$LSOA11NM,"</strong>", "</br>", 
                          "LSOA: ",hwics_lsoa$LSOA11CD, "</br>",
                          "Decile: ",hwics_lsoa$decile, "</br>",
                    "Activity: ", prettyNum(hwics_lsoa$activity, big.mark = ","))

lsoa_pal <- colorNumeric(
  palette = "YlGnBu",
  domain = hwics_lsoa$activity)
# ------------------------------------------------------------------------------



# ------------------------------------------------------------------------------
# Load Hospital Locations
map_points = read_csv('hospital_sites.csv')

hwics_lsoa$Edge_colour <- hwics_lsoa$Edge_colour %>% replace_na("white")


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

# Map 1 - all areas for exploring
mapp <- leaflet() %>%
  addProviderTiles(providers$CartoDB.Positron) %>%
  addPolygons(data = hwics_lsoa,
              stroke = TRUE,
              weight = 1.5, # outline thickness
              opacity = 1, # outline opacity
              smoothFactor = 0.3,
              fillColor = ~lsoa_pal(hwics_lsoa$activity), 
              fillOpacity = 0.8,
              color = "white",
              popup = ~popup,
              highlightOptions = highlightOptions(color = "red", weight = 1.5,
                                                   bringToFront = T, sendToBack = T, fillOpacity = 0.8) ) %>% 

  addPolygons(data = hwics_lsoa_cons,
              stroke = TRUE,
              weight = 1, # outline thickness
              opacity = 1, # outline opacity
              color = "black",
              fill = F) %>%   
  
  addCircleMarkers(data = map_points, lng = ~Lon, lat = ~Lat, popup = ~Label, radius = 5, color = "black") %>%
  
  addLegend("bottomright",opacity = 1,
            colors =c("#ffffcc","#c7e9b4","#7fcdbb","#41b6c4","#1d91c0","#225ea8","#0c2c84"),
            title = "Workforce",
            labels= c("Very low","low","slightly low","average","slightly high", "high", "very high")
  )

mapp
# ------------------------------------------------------------------------------



