filepath <- "data/raw/cases-report/2023-08-07.csv"
col_names <- c(
  "year_noti", "week_noti", "diagnostic", "diagnostic_type", "ubigeo", "ccpp_code",
  "ccpp_name", "age", "age_type", "sex", "date_noti"
)
cases_raw <- readr::read_csv(
  filepath, col_types = readr::cols(.default = "c"), col_select = c(1:4, 6:11, 15),
  locale = readr::locale(encoding = "UTF-8")
)
names(cases_raw) <- col_names

# cases_raw |> 
#   group_by(year) |> 
#   summarise(
#     records = n(), ccpp_code = sum(!is.na(ccpp_code)), ccpp_name = sum(!is.na(ccpp))
#   ) |> 
#   View()

cie10 <- readr::read_csv(
  "data/raw/cases-report/cie10.csv", col_types = "cc", 
  locale = readr::locale(encoding = "latin1")
)

ccpp_name_stations = c(
  "12 DE ABRIL", "DOCE DE ABRIL", "SAN LUCAS", "QUISTOCOCHA", "QUISTOCOCHA KM. 9",
  "PAUJIL", "PAUJIL I ZONA", "PAUJIL KM. 35", "VARILLAL"
)

cases <- cases_raw |> 
  readr::type_convert(col_types = "iiccccciccc") |> 
  dplyr::filter(
    year_noti >= 2010, ubigeo == "160113", ccpp_name %in% ccpp_name_stations
  ) |> 
  dplyr::mutate(
    ccpp_name = dplyr::case_when(
      grepl("ABRIL", ccpp_name) ~ "12 DE ABRIL",
      grepl("QUISTO", ccpp_name) ~ "QUISTOCOCHA",
      grepl("PAUJIL", ccpp_name) ~ "EL PAUJIL",
      ccpp_name == "VARILLAL" ~ "EL VARILLAL",
      TRUE ~ as.character(ccpp_name)
    )
  ) |> 
  dplyr::mutate(
    date_month = stringr::str_pad(
      stringr::str_split_i(date_noti, "/", 1), width = 2, side = "left", 
      pad = "0"
    ),
    date_day = stringr::str_pad(
      stringr::str_split_i(date_noti, "/", 2), width = 2, side = "left", 
      pad = "0"
    ),
    date_year = stringr::str_split_i(date_noti, "/", 3)
  ) |> 
  tidyr::unite(day, c(date_year, date_month, date_day), sep = "-", remove = TRUE) |> 
  dplyr::mutate(day = as.Date(day)) |> 
  dplyr::mutate(
    week = lubridate::epiweek(day),
    month = lubridate::month(day),
    year = lubridate::epiyear(day)
  ) |> 
  dplyr::left_join(cie10, by = c("diagnostic" = "cie10")) |> 
  dplyr::mutate(
    disease = dplyr::case_when(
      grepl("Malaria", diagnostic_name) ~ "Malaria",
      grepl("Dengue", diagnostic_name) ~ "Dengue",
      TRUE ~ as.character(diagnostic_name)
    )
  ) |> 
  dplyr::filter(
    disease %in% c("Malaria", "Dengue", "Leptospirosis")
  )

ccpp_10km <- readr::read_csv(
  "data/raw/cases-report/ccpp-10km.csv", 
  col_types = "ccccccddcdddddddddddddddddddddddddddd",
  col_select = c(ubigeocp, nomcp)
)

cases_report = cases |> 
  dplyr::left_join(ccpp_10km, by = c("ccpp_name" = "nomcp")) |> 
  dplyr::rename(ccpp_ubigeo = ubigeocp)

cases_report_daily = cases_report |> 
  dplyr::count(
    ccpp_ubigeo, ccpp = ccpp_name, disease, year, month, week, day, 
    name = "value"
  )

cases_report_complete = cases_report_daily |> 
  dplyr::group_by(ccpp_ubigeo, ccpp, disease) |> 
  tidyr::complete(
    day = seq(min(cases_report_daily$day), max(cases_report_daily$day), by = "day"),
    fill = list(value = 0)
  ) |> 
  dplyr::mutate(
    week = lubridate::epiweek(day),
    month = lubridate::month(day),
    year = lubridate::epiyear(day)
  )

readr::write_csv(cases_report_complete, "data/app/cases-report.csv")
