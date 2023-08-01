read_raw = function(filepath, col_names = NULL, col_types = NULL) {
  raw_data = readxl::read_excel(
    filepath, col_names = col_names, skip = 2, col_types = col_types,
    na = c("", "---", "------")
  )
  ccpp_name_raw = stringr::str_split(filepath, "[/_]")[[1]][5]
  ccpp_name = ccpp_name_raw |>
    stringr::str_replace_all("-", " ") |>
    toupper()
  ccpp_ubigeo = stringr::str_split(filepath, "[/_]")[[1]][4]
  return(
    list(raw_data = raw_data, ccpp_name = ccpp_name, ccpp_ubigeo = ccpp_ubigeo)
  )
}

clean_raw = function(raw_data, ccpp_name, ccpp_ubigeo) {
  interim_data = raw_data |>
    dplyr::mutate(
      time_text = as.character(hms::as_hms(time)),
      dttm_text = paste(as.character(date), time_text, sep = " "),
      dttm = lubridate::ymd_hms(dttm_text, tz = "America/Lima"),
      ccpp_ubigeo = ccpp_ubigeo,
      ccpp_name = ccpp_name,
      .keep = "unused"
    ) |>
    dplyr::relocate(dttm, .before = dplyr::everything()) |>
    dplyr::select(-c(time_text, dttm_text))
  interim_data
}

write = function(data, in_filepath, in_path, out_path) {
  filepath = fs::path_ext_set(
    stringr::str_replace(in_filepath, in_path, out_path), "csv"
  )
  if (!dir.exists(fs::path_dir(filepath))) {
    dir.create(fs::path_dir(filepath), recursive = TRUE)
  }
  readr::write_csv(data, filepath, na = "")
  print(filepath)
}

process = function(in_filepath, col_names = NULL, col_types = NULL, in_path, out_path) {
  raw = read_raw(in_filepath, col_names = col_names, col_types = col_types)
  interim_data = clean_raw(raw$raw_data, raw$ccpp_name, raw$ccpp_ubigeo)
  write(interim_data, in_filepath, in_path, out_path)
}

col_names = c(
  "date", "time", "temp_out", "high_temp", "low_temp", "out_humm",
  "dew_pt", "wind_speed", "wind_dir", "wind_run", "hi_speed", "hi_dir",
  "wind_chill", "heat_index", "thw_index", "bar", "rain", "rain_rate",
  "heat_dd", "cool_dd","in_temp", "in_hum", "in_dew", "in_heat", "in_emc",
  "in_air_density", "wind_samp", "wind_tx", "iss_recept", "arc_int"
)

col_types = c(
  "date", "date", rep("numeric", 6), "text", "numeric", "numeric", "text",
  rep("numeric", 18)
)

in_path = "data/raw/weather-stations/"
in_filepaths = fs::dir_ls(in_path, recurse = TRUE, type = "file")

out_path = "data/interim/weather-stations/"

purrr::walk(
  in_filepaths,
  \(x) process(
    x, col_names = col_names, col_types = col_types, in_path = in_path,
    out_path = out_path
  )
)
