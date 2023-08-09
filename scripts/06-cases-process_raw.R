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

cases |> 
  dplyr::group_by(ccpp_name, disease) |> 
  dplyr::count()
