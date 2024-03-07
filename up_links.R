library(rgee)
library(tidyverse)
library(sf)
library(cptcity)
ee_Initialize(user = "geografo.pe@gmail.com",drive = T)

# 1. Reading community hexagons -------------------------------------------

llanchama_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'LLANCHAMA') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

docedeabril_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% '12 DE ABRIL') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

febrero_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% '23 DE FEBRERO') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

quistococha_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'QUISTOCOCHA') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

sancarlos_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'SAN CARLOS') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

elpaujil_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'EL PAUJIL') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

sanlucas_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'SAN LUCAS') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

zungarococha_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'ZUNGAROCOCHA') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

cahuide01_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'CAHUIDE 01') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

cahuide02_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'CAHUIDE 02') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

cahuide03_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'CAHUIDE 03') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

varillal01_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'EL VARILLAL 01') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

varillal02_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'EL VARILLAL 02') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

varillal03_fc <- st_read("data/community_hexagons_of_1km2.gpkg") %>% 
  filter(village %in% 'EL VARILLAL 03') %>% 
  sf_as_ee() %>% 
  ee$FeatureCollection$geometry()

# 2. Reading ImageCollection from GEE -------------------------------------

llanchama_img   <- ee$Image('users/labsaf/harmonize-rgb/llanchama')$clip(llanchama_fc)
docedeabril_img <- ee$Image('users/labsaf/harmonize-rgb/12abril')$clip(docedeabril_fc)
febrero_img     <- ee$Image('users/labsaf/harmonize-rgb/23febrero')$clip(febrero_fc)
quistococha_img <- ee$Image('users/labsaf/harmonize-rgb/quistococha')$clip(quistococha_fc)
sancarlos_img   <- ee$Image('users/labsaf/harmonize-rgb/sancarlos')$clip(sancarlos_fc)
elpaujil_img    <- ee$Image('users/labsaf/harmonize-rgb/elpaujil')$clip(elpaujil_fc)
sanlucas_img     <- ee$Image('users/labsaf/harmonize-rgb/sanlucas')$clip(sanlucas_fc)
zungarococha_img <- ee$Image('users/labsaf/harmonize-rgb/zungarococha')$clip(zungarococha_fc)
cahuide01_img  <- ee$Image('users/labsaf/harmonize-rgb/cahuide02')$clip(cahuide01_fc)
cahuide02_img  <- ee$Image('users/labsaf/harmonize-rgb/cahuide03')$clip(cahuide02_fc)
cahuide03_img  <- ee$Image('users/labsaf/harmonize-rgb/cahuide01')$clip(cahuide03_fc)
varillal01_img <- ee$Image('users/labsaf/harmonize-rgb/varillalzona1')$clip(varillal01_fc) 
varillal02_img <- ee$Image('users/labsaf/harmonize-rgb/varillalzona2')$clip(varillal02_fc)
varillal03_img <- ee$Image('users/labsaf/harmonize-rgb/varillalzona3')$clip(varillal03_fc)


llanchama_thermal   <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/llanchama_termal')$select('b1')$clip(llanchama_fc)
docedeabril_thermal <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/12abril_termal')$select('b1')$clip(docedeabril_fc)
febrero_thermal     <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/23defebrero_termal')$select('b1')$clip(febrero_fc)
quistococha_thermal <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/quistococha_termal')$select('b1')$clip(quistococha_fc)
sancarlos_thermal   <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/sancarlos_termal')$select('b1')$clip(sancarlos_fc)
elpaujil_thermal    <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/elpaujil_termal')$select('b1')$clip(elpaujil_fc)
sanlucas_thermal     <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/sanlucas_termal')$select('b1')$clip(sanlucas_fc)
zungarococha_thermal <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/zungarococha_termal')$select('b1')$clip(zungarococha_fc)
cahuide01_thermal  <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/cahuide_termal_02')$select('b1')$clip(cahuide01_fc)
cahuide02_thermal  <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/cahuide_termal_03')$select('b1')$clip(cahuide02_fc)
cahuide03_thermal  <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/chauide_termal_01')$select('b1')$clip(cahuide03_fc)
varillal01_thermal <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/varillal_termal_01')$select('b1')$clip(varillal01_fc) 
varillal02_thermal <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/varillal_termal_02')$select('b1')$clip(varillal02_fc)
varillal03_thermal <- ee$Image('users/bryanfernandezc/harmonize-thermal-may2023/varillal_termal_03')$select('b1')$clip(varillal03_fc)

rgb <- ee$ImageCollection(
  list(
    llanchama_img,
    docedeabril_img,
    febrero_img,
    quistococha_img,
    sancarlos_img,
    elpaujil_img,
    sanlucas_img,
    zungarococha_img,
    cahuide01_img,
    cahuide02_img,
    cahuide03_img,
    varillal01_img,
    varillal02_img,
    varillal03_img)
  ) %>%  
  Map$addLayers()


thermal <- ee$ImageCollection(
  list(
    llanchama_thermal,
    docedeabril_thermal,
    febrero_thermal,
    quistococha_thermal,
    sancarlos_thermal,
    elpaujil_thermal,
    sanlucas_thermal,
    zungarococha_thermal,
    cahuide01_thermal,
    cahuide02_thermal,
    cahuide03_thermal,
    varillal01_thermal,
    varillal02_thermal,
    varillal03_thermal)
) %>%  
  Map$addLayers(visParams = list(palette = cpt(pal = "ncl_BlueYellowRed")))


# 3. New URLS -------------------------------------------------------------

new_links <- tibble(
  villages = c(
    'llanchama',
    '12 de abril',
    '23 de febrero',
    'quistococha',
    'san carlos',
    'el paujil',
    'san lucas',
    'zungarococha',
    'cahuide 01',
    'cahuide 02',
    'cahuide 03',
    'el varillal 01',
    'el varillal 02',
    'el varillal 03'),
  rgb = rgb$rgee$tokens,
  thermal = thermal$rgee$tokens
  )

write_csv(new_links,"data/drones.csv")
rsconnect::deployApp(appName = "droneapp")
