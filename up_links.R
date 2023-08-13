library(rgee)
library(tidyverse)
library(sf)
ee_Initialize(user = "geografo.pe@gmail.com",drive = T)

hex <- st_read("data/flying_mission_1km2.gpkg") %>%
  st_geometry() |> 
  sf_as_ee() |> 
  ee$FeatureCollection$geometry()

sunga <- st_read("data/zunga.kml") %>% 
  sf_as_ee()

quisto <- st_read("data/quistococha.kml") %>% 
  sf_as_ee()

doce_abril <- ee$Image("users/bryanfernandezc/harmonize_piloto/12_abril_rgb")$clip(hex)
veinte_3 <- ee$Image("users/bryanfernandezc/harmonize_piloto/23_febrero_marzo")$clip(hex)
cahuide <- ee$Image("users/bryanfernandezc/harmonize_piloto/cahuide")$
  select(c("b1","b2","b3"))$clip(hex)
llanchama <- ee$Image("users/bryanfernandezc/harmonize_piloto/llanchama_marzo_2023")$
  select(c("b1","b2","b3"))$clip(hex)
paujil <- ee$Image("users/bryanfernandezc/harmonize_piloto/paujil")$clip(hex)
quistococha <- ee$Image("users/bryanfernandezc/harmonize_piloto/quistococha")$clip(quisto)
san_carlos <- ee$Image("users/bryanfernandezc/harmonize_piloto/san_carlos")$clip(hex)
san_lucas <- ee$Image("users/bryanfernandezc/harmonize_piloto/san_lucas")$clip(hex)
varillal_01 <- ee$Image("users/bryanfernandezc/harmonize_piloto/varillal_zona_01")$clip(hex)
zungaro <- ee$Image("users/bryanfernandezc/harmonize_piloto/zungarococha")$
  select(c("b1","b2","b3"))$clip(sunga)

piloto <- ee$ImageCollection(
  list(doce_abril,veinte_3,llanchama,paujil,quistococha,
  san_carlos,san_lucas,varillal_01,zungaro
  ))

termal <- ee$ImageCollection("users/bryanfernandezc/harmonize-thermal-may2023")$
  map(function(x){x$clip(hex)}) |> 
  Map$addLayers()

rgb <- Map$addLayers(piloto)
new_links <- tibble(
  villages = rgb$rgee$name,
  rgb = rgb$rgee$tokens,
  termal = termal$rgee$tokens[1:9]
  ) %>%
  mutate(villages = str_to_upper(case_when(
    villages == "12_abril_rgb" ~ "12 abril",
    villages == "23_febrero_marzo" ~ "23 de febrero",
    villages == "llanchama_marzo_2023" ~ "llanchama",
    villages == "san_carlos" ~ "san carlos",
    villages == "san_lucas" ~ "san lucas",
    villages == "varillal_zona_01" ~ "varillal",
    TRUE ~ villages)
  ))

write.csv(new_links,"data/drones.csv")