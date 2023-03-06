library(dplyr)

raw_path = "data/raw/"
interim_path = "data/interim/"

# CCPP --------------------------------------------------------------------

ccpp_filename = "ccpp-10km.csv"
ccpp_raw_path = fs::path(raw_path, ccpp_filename)
ccpp_raw = readr::read_csv(
  ccpp_raw_path, col_types = "cccccccddc", col_select = -c(fid)
)
ccpp = janitor::clean_names(ccpp_raw)
ccpp_interim_path = fs::path(interim_path, paste0("01-", ccpp_filename))
readr::write_csv(ccpp, ccpp_interim_path, na = "")

# 2010 and 2019 malaria cumulative cases  ---------------------------------

malaria_filename = "ccpp-10km-malaria-cases-2010-2019.csv"
malaria_raw_path = fs::path(raw_path, malaria_filename)
malaria_raw = readr::read_csv(
  malaria_raw_path, col_types = "cccccdddcdddd", 
  col_select = -c(fid, absol.2019_2010, relat.2019_2010)
)

malaria = malaria_raw %>% 
  select(UBIGEOCP = CODIGO, POBLACION, `2010`, `2019`) %>% 
  janitor::clean_names() %>% 
  rename(cases_2010 = x2010, cases_2019 = x2019)

malaria_interim_path = fs::path(interim_path, paste0("02-", malaria_filename))
readr::write_csv(malaria, malaria_interim_path, na = "")

# Cumulative cases 2022 ---------------------------------------------------

cases_filename = "ccpp-10km-cases-2022.csv"
cases_raw_path = fs::path(raw_path, cases_filename)
cases_raw = readr::read_delim(
  cases_raw_path, delim = ";",
  col_types = "cccccccdddddcc", 
  col_select = -c(fid, `fid,UBIGEO,NOMCP,DEP,PROV,DIST,UBIGEOCP,LNG,LAT,GROUP`)
)

cases = cases_raw %>% 
  select(UBIGEOCP, DENGUE:LEPTOSPIROSIS) %>% 
  janitor::clean_names()

cases_interim_path = fs::path(interim_path, paste0("03-", cases_filename))
readr::write_csv(cases, cases_interim_path, na = "")

# Environmental variables -------------------------------------------------

environment_filename = "ccpp-10km-environment-2010-2021.csv"
environment_raw_path = fs::path(raw_path, environment_filename)
environment_raw = readr::read_csv(
  environment_raw_path, 
  col_types = "ccccccddcd", 
  col_select = -c(starts_with("delta"))
)

environment = environment_raw %>% 
  select(UBIGEOCP, pr2010:ln_2014) %>% 
  janitor::clean_names() %>%
  rename_with(~sub("([a-z])([0-9])", "\\1_\\2", .x))

environment_interim_path = fs::path(
  interim_path, paste0("04-", environment_filename)
)
readr::write_csv(environment, environment_interim_path, na = "")

