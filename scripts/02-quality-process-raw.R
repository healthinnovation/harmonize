read_raw = function(filepath, col_names) {
  raw_data = readr::read_csv(
    filepath, col_names = col_names, col_types = readr::cols(.default = "c"), 
    na = c("", "nan")
    # locale = readr::locale(encoding = "latin1")
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

clean_raw = function(raw_data, ccpp_name, ccpp_ubigeo, col_types) {
  interim_data = raw_data |>
    tidyr::drop_na(mac_address) |> 
    dplyr::filter(mac_address != "mac_address") |> 
    dplyr::mutate(
      dttm = lubridate::ymd_hms(UTCDateTime, tz = "America/Lima", quiet = TRUE),
      gas = stringr::str_split_i(gas, pattern = "\032", i = 1),
      ccpp_ubigeo = ccpp_ubigeo,
      ccpp_name = ccpp_name,
      .keep = "unused",
    ) |> 
    dplyr::filter(gas != "nan") |> 
    dplyr::mutate(gas = as.numeric(gas)) |> 
    dplyr::relocate(dttm, .before = everything()) |> 
    readr::type_convert(col_types = col_types)
  interim_data
}

write = function(data, in_filepath, in_path, out_path) {
  paste(stringr::str_split(in_filepath, "[/_]")[[1]][-5], collapse = "/")
  filepath_raw = paste(
    stringr::str_split(in_filepath, "[/]")[[1]][-5], collapse = "/"
  )
  filepath = stringr::str_replace(filepath_raw, in_path, out_path)
  if (!dir.exists(fs::path_dir(filepath))) {
    dir.create(fs::path_dir(filepath), recursive = TRUE)
  }
  readr::write_csv(data, filepath, na = "")
  print(filepath)
}

process = function(in_filepath, col_names = NULL, col_types = NULL, in_path, out_path) {
  raw = read_raw(in_filepath, col_names = col_names)
  interim_data = clean_raw(
    raw$raw_data, raw$ccpp_name, raw$ccpp_ubigeo, col_types = col_types
  )
  write(interim_data, in_filepath, in_path, out_path)
}

col_names = c(
  "UTCDateTime", "mac_address", "firmware_ver", "hardware", "current_temp_f", 
  "current_humidity", "current_dewpoint_f", "pressure", "adc", "mem", "rssi", 
  "uptime", "pm1_0_cf_1", "pm2_5_cf_1", "pm10_0_cf_1", "pm1_0_atm", "pm2_5_atm", 
  "pm10_0_atm", "pm2.5_aqi_cf_1", "pm2.5_aqi_atm", "p_0_3_um", "p_0_5_um", 
  "p_1_0_um", "p_2_5_um", "p_5_0_um", "p_10_0_um", "pm1_0_cf_1_b", "pm2_5_cf_1_b", 
  "pm10_0_cf_1_b", "pm1_0_atm_b", "pm2_5_atm_b", "pm10_0_atm_b", "pm2.5_aqi_cf_1_b", 
  "pm2.5_aqi_atm_b", "p_0_3_um_b", "p_0_5_um_b", "p_1_0_um_b", "p_2_5_um_b", 
  "p_5_0_um_b", "p_10_0_um_b", "gas"
)

col_types = paste(c(rep("c", 4), rep("d", 36), "dcc"), collapse = "")

in_path = "data/raw/quality-stations/"
in_filepaths = fs::dir_ls(in_path, recurse = TRUE, type = "file")

#--------------

filepath = "data/raw/quality-stations/1601130055_12-de-abril/2023-06-30/20230624.csv"
data_raw = read_raw(filepath, col_names = col_names)
data_raw$raw_data |> dplyr::filter(is.na(mac_address))
clean_data = clean_raw(
  data_raw$raw_data, data_raw$ccpp_name, data_raw$ccpp_ubigeo, col_types = col_types
)

#---------------

out_path = "data/interim/quality-stations/"

purrr::walk(
  in_filepaths,
  \(x) process(
    x, col_names = col_names, col_types = col_types, in_path = in_path, 
    out_path = out_path
  )
)

