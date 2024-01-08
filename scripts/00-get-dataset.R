library(tidyverse)
library(sf)
library(rgee)
library(innovar)
ee_Initialize(user = "geografo.pe@gmail.com")

# 1. Reading spatial data -------------------------------------------------
road_path <- "../data/raw/iquitos-nauta-road-mtc.gpkg"
cp_path <- "../data/raw/villages_loreto_inei_2017.gpkg"

# 2. Geoprocessing with spatial data --------------------------------------

road <- st_read(road_path) %>% 
  st_transform(crs = 32718) %>% 
  st_buffer(dist = 10*1000) %>% 
  st_transform(crs = 4326)

cp <- st_read(cp_path) %>%
  select(IDCCPP_17,NOMCCPP_17) %>% 
  rename(
    codigo = IDCCPP_17,
    village = NOMCCPP_17
  )

cp_in_road <- st_intersection(cp,road)

cp_in_road_ee <- cp_in_road %>% 
  st_transform(4326) %>%
  sf_as_ee()

# Precipiation -----------------

db_pp <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE")$
  select("pr")$filter(ee$Filter$calendarRange(2021,2021,'year'))$
  sum()

pp_2021 <- ee_extract(
  x = db_pp,
  y = cp_in_road_ee,
  fun = ee$Reducer$mean(),
  scale = 4638.3)


db_pp <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE")$
  select("pr")$filter(ee$Filter$calendarRange(2021,2021,'year'))$
  sum()

pp_2021 <- ee_extract(
  x = db_pp,
  y = cp_in_road_ee,
  fun = ee$Reducer$mean(),
  scale = 4638.3)




pp_2010 <- 

pp_total<- pp_2021 %>% 
  left_join(pp_2010,by = "codigo") %>% 
  mutate(delta_pr = (pr2021 - pr2010)*100/pr2010)

rm(pp_2021)
rm(pp_2010)

# Runoff  ----------------------
ro_2021 <- get_climate(
  from = "2021-01-01",
  to = "2021-12-31",
  by = "year",
  band = "ro",
  fun = "mean",
  region = cp_in_road_ee) %>% 
  select(codigo,ro2021)

ro_2010 <- get_climate(
  from = "2010-01-01",
  to = "2010-12-31",
  by = "year",
  band = "ro",
  fun = "mean",
  region = cp_in_road_ee) %>% 
  select(codigo,ro2010)

ro_total <- ro_2021 %>% 
  left_join(ro_2010,by = "codigo") %>% 
  mutate(delta_ro = (ro2021 - ro2010)*100/ro2010)

rm(ro_2021)
rm(ro_2010)

# Soil moisture ---------------
soil_2021 <- get_climate(
  from = "2021-01-01",
  to = "2021-12-31",
  by = "year",
  band = "soil",
  fun = "mean",
  region = cp_in_road_ee) %>% 
  select(codigo,soil2021)

soil_2010 <- get_climate(
  from = "2010-01-01",
  to = "2010-12-31",
  by = "year",
  band = "soil",
  fun = "mean",
  region = cp_in_road_ee) %>% 
  select(codigo,soil2010)

soil_total <- soil_2021 %>% 
  left_join(soil_2010,by = "codigo") %>% 
  mutate(delta_soil = (soil2021 - soil2010)*100/soil2010)

rm(soil_2021)
rm(soil_2010)

# Tmmx -------------------------


db <- ee$ImageCollection("IDAHO_EPSCOR/TERRACLIMATE")$
  select(c("tmmx"))$
  filterDate("2021-01-01","2021-12-31")$
  toBands()$
  multiply(0.1)

test <- ee_extract(x = db,y = cp_in_road_ee,fun = ee$Reducer$mean(),scale = 4638.3)


tmax_2021 <- get_climate(
  from = "2021-01-01",
  to = "2021-12-31",
  by = "year",
  band = "tmmx",
  fun = "max",
  region = cp_in_road_ee) %>% 
  select(codigo,tmmx2021)

tmax_2010 <- get_climate(
  from = "2010-01-01",
  to = "2010-12-31",
  by = "year",
  band = "tmmx",
  fun = "mean",
  region = cp_in_road_ee) %>% 
  select(codigo,tmmx2010)

tmax_total <- tmax_2021 %>% 
  left_join(tmax_2010,by = "codigo") %>% 
  mutate(delta_tmax = (tmmx2021 - tmmx2010)*100/tmmx2010)

rm(tmax_2021)
rm(tmax_2010)

# Tmmn -------------------------
tmin_2021 <- get_climate(
  from = "2021-01-01",
  to = "2021-12-31",
  by = "year",
  band = "tmmn",
  fun = "mean",
  region = cp_ee) %>% 
  select(codigo,tmmn2021)

tmin_2010 <- get_climate(
  from = "2010-01-01",
  to = "2010-12-31",
  by = "year",
  band = "tmmn",
  fun = "mean",
  region = cp_ee) %>% 
  select(codigo,tmmn2010)

tmin_total <- tmin_2021 %>% 
  left_join(tmin_2010,by = "codigo") %>% 
  mutate(delta_tmin = (tmmn2021 - tmmn2010)*100/tmmn2010)

rm(tmin_2021)
rm(tmin_2010)

# Global Human Modification ------
ghm <- get_ghm(region = cp_ee,fun = "mean")

# Evapotranspiration -------------

etp_2021 <- get_etp(
  from = "2021-01-01",
  to = "2021-12-31",
  band = "ET",
  region = cp_ee,
  fun = "mean"
)

etp_2021 <- etp_2021 |> 
  pivot_longer(!c("codigo","village"),names_to = "year",values_to = "ETP") |> 
  mutate(year = gsub("ET","",year) %>% substr(.,1,4) %>% as.numeric()) |> 
  group_by(codigo,village) |> 
  summarise(ETP_2021 = mean(ETP)) %>% 
  select(codigo,ETP_2021)

etp_2010 <- get_etp(
  from = "2010-01-01",
  to = "2010-12-31",
  band = "ET",
  region = cp_ee,
  fun = "mean"
)

etp_2010 <- etp_2010 |> 
  pivot_longer(!c("codigo","village"),names_to = "year",values_to = "ETP") |> 
  mutate(year = gsub("ET","",year) %>% substr(.,1,4) %>% as.numeric()) |> 
  group_by(codigo,village) |> 
  summarise(ETP_2010 = mean(ETP)) %>% 
  select(codigo,ETP_2010)

etp_total <- etp_2021 %>% 
  left_join(etp_2010,by = "codigo") %>% 
  mutate(delta_ETP = (ETP_2021 - ETP_2010)*100/ETP_2010)

rm(etp_2021)
rm(etp_2010)

# Humidity -----------------------
humidity_2021 <- get_fldas(
  from = "2021-01-01",
  to = "2021-12-31",
  by = "year",
  band = "Qair_f_tavg",
  region = cp_ee,
  fun = "mean") %>% 
  select(codigo,Qair_f_tavg2021) %>% 
  rename(humidity_2021 = Qair_f_tavg2021)

humidity_2010 <- get_fldas(
  from = "2010-01-01",
  to = "2010-12-31",
  by = "year",
  band = "Qair_f_tavg",
  region = cp_ee,
  fun = "mean") %>% 
  select(codigo,Qair_f_tavg2010) %>% 
  rename(humidity_2010 = Qair_f_tavg2010)

humidity_total <- humidity_2021 %>% 
  left_join(humidity_2010,by = "codigo") %>% 
  mutate(
    delta_humidity = (humidity_2021 - humidity_2010)*100/humidity_2010
  )

rm(humidity_2021)
rm(humidity_2010)

# Population ----------------------
pop_2010 <- get_pop(
  from = "2010-01-01",
  to = "2010-12-31",
  region = cp_ee,
  fun = "mean"
) %>% 
  select(codigo,pop2010)

pop_2020 <- get_pop(
  from = "2020-01-01",
  to = "2020-12-31",
  region = cp_ee,
  fun = "mean") %>% 
  select(codigo,pop2020)

pop_total <- pop_2020 %>% 
  left_join(pop_2010,by = "codigo") %>% 
  mutate(
    delta_pop = (pop2020 - pop2010)*100/pop2010
  )

rm(pop_2020)
rm(pop_2010)


# Deforestation -----------------------------------------------------------

def_2010 <- get_def(
  from = "2010-01-01",
  to = "2010-12-31",
  region = cp_ee,
  scale = 30
) %>% 
  rename(def_2010 = lossyear)

def_2021 <- get_def(
  from = "2021-01-01",
  to = "2021-12-31",
  region = cp_ee,
  scale = 30) %>% 
  rename(def_2021 = lossyear)


def_total <- def_2021 %>% 
  left_join(def_2010,by = "codigo") %>% 
  mutate(
    delta_def = (def_2021 - def_2010)*100/def_2010
  )

rm(def_2021)
rm(def_2010)


# GSH ---------------------------------------------------------------------
cp_sf <- cp %>% 
  st_transform(32718) %>%
  st_buffer(dist = 5000) %>%
  st_transform(4326)

write_sf(cp_sf,"cp_buffer.gpkg")
ghs_total <- st_read("../raw_data/GHS.gpkg") %>% 
  st_set_geometry(NULL)


#  Night Lights -----------------------------------------------------------

ln_2014 <- get_viirs(
  from = "2014-01-01",
  to = "2014-12-31",
  fun = "mean",
  region = cp_ee
) %>% 
  rename(ln_2014 = ntl2014)

ln_2021 <- get_viirs(
  from = "2021-01-01",
  to = "2021-12-31",
  fun = "mean",
  region = cp_ee
) %>% 
  rename(ln_2021 = ntl2021)

ln_total <- ln_2021 %>% 
  left_join(ln_2014,by = "codigo") %>% 
  mutate(
    delta_ln = (ln_2021 - ln_2014)*100/ln_2014
  )

rm(ln_2021)
rm(ln_2010)

# Modeling spatial data ---------------------------------------------------
m1 <- left_join(
  cp,
  pp_total,
  "codigo"
)

m2 <- left_join(
  m1,
  ro_total,
  "codigo"
)

m3 <- left_join(
  m2,
  soil_total,
  "codigo"
)

m4 <- left_join(
  m3,
  tmax_total,
  "codigo"
)

m5 <- left_join(
  m4,
  tmin_total,
  "codigo"
)

m6 <- left_join(
  m5,
  etp_total,
  "codigo"
)

m7 <- left_join(
  m6,
  humidity_total,
  "codigo"
)

m8 <- left_join(
  m7,
  pop_total,
  "codigo"
)

m9 <- left_join(
  m8,
  def_total %>% select(-c(village.x,village.y)),
  "codigo"
)

m10 <- left_join(
  m9,
  ghs_total,
  "codigo"
)

m11 <- left_join(
  m10,
  ln_total %>% select(-c(village.x,village.y)),
  "codigo"
)

write_csv(
  m11 %>% 
    mutate(
      lat = st_coordinates(geom)[,2],
      lon = st_coordinates(geom)[,1])%>% 
    st_set_geometry(NULL)
  ,"../processed_data/db_variables.csv"
)

write_sf(m10,"../processed_data/db_variables.gpkg")
