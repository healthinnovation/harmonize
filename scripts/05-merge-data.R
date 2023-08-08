in_path = "data/processed/"
out_path = "data/shiny"
in_directories = in_path |> 
  fs::dir_ls(recurse = TRUE, type = "file") |> 
  fs::path_dir() |> 
  unique()

col_types_weather = "DTddddddcddcddddddddddddddddddcc"
col_types_quality = paste(c("DTccc", rep("d", 37), "cc"), collapse = "")

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
  out_filepath = fs::path(out_path, paste(type, "csv", sep = "."))
  if (!dir.exists(fs::path_dir(out_filepath))) {
    dir.create(fs::path_dir(out_filepath), recursive = TRUE)
  }
  readr::write_csv(dataset, out_filepath, na = "")
  print(out_filepath)
}
