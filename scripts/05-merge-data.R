in_path = "data/processed"
out_path = "data/app"
in_directories = in_path |> 
  fs::dir_ls(recurse = TRUE, type = "file") |> 
  fs::path_dir() |> 
  unique()

col_types_weather = "DTddddddcddcddddddddddddddddddcc"
col_types_quality = paste(c("DTccc", rep("d", 37), "cc"), collapse = "")

dataset_stations = vector(mode = "list", length = 2L)

for (i in seq_along(in_directories)) {
  type = fs::path_file(in_directories[i])
  in_filepaths = fs::dir_ls(in_directories[i], recurse = TRUE, type = "file")
  if (type == "weather-stations") {
    datasets = purrr::map(
      in_filepaths,
      \(x) readr::read_csv(x, col_types = col_types_weather)
    )
  } else {
    datasets = purrr::map(
      in_filepaths,
      \(x) readr::read_csv(x, col_types = col_types_quality)
    )
  }
  dataset = datasets |> 
    dplyr::bind_rows() |> 
    dplyr::mutate(
      day = lubridate::date(dttm),
      week = lubridate::epiweek(dttm),
      month = lubridate::month(dttm),
      year = lubridate::epiyear(dttm)
    )
  dataset_stations[[i]] = dataset
}

weather_long_raw <- dataset_stations[[2]] |> 
  dplyr::select(
    ccpp_ubigeo, ccpp_name, day, week, month, year, temp_out, rain, out_humm
  ) |> 
  tidyr::pivot_longer(
    cols = temp_out:out_humm,
    names_to = "variable",
    values_to = "value"
  ) 

weather_long <- weather_long_raw |> 
  dplyr::group_by(ccpp_ubigeo, ccpp_name, year, month, week, day, variable) |> 
  dplyr::summarise(value = mean(value, na.rm = TRUE), .groups = "drop")

quality_long_raw <- dataset_stations[[1]] |> 
  dplyr::select(
    ccpp_ubigeo, ccpp_name, day, week, month, year, p_2_5_um, p_10_0_um
  ) |> 
  tidyr::pivot_longer(
    cols = p_2_5_um:p_10_0_um,
    names_to = "variable",
    values_to = "value"
  )

quality_long <- quality_long_raw |> 
  dplyr::group_by(ccpp_ubigeo, ccpp_name, year, month, week, day, variable) |> 
  dplyr::summarise(value = mean(value, na.rm = TRUE), .groups = "drop")

dataset_app <- dplyr::bind_rows(weather_long, quality_long)
readr::write_csv(dataset_app, paste(out_path, "dataset.csv", sep = "/"))
