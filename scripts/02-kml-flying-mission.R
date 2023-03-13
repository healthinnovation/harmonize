library(sf)
library(tidyverse)

path_gpkg <- "flying_mission.gpkg" 
data <- st_read(path_gpkg)
save_kml <- function(x){
  if(!dir.exists("kml")){dir.create("kml")}
  village <- data[x,]
  write_sf(village,sprintf("%s%s.kml","kml/",village[["village"]]))
}

lapply(1:nrow(data),FUN = save_kml)
