read_raw = function(filepath, col_types = NULL) {
  raw_data = readr::read_csv(
    filepath, col_types = col_types, na = c("", "nan"),
    locale = readr::locale(encoding = "UTF-8")
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
      dttm = lubridate::ymd_hms(UTCDateTime, tz = "America/Lima", quiet = TRUE),
      gas = as.numeric(gsub(pattern = "\032", replacement = "", gas)),
      ccpp_ubigeo = ccpp_ubigeo,
      ccpp_name = ccpp_name,
      .keep = "unused",
    ) |> 
    dplyr::relocate(dttm, .before = everything())
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

process = function(in_filepath, col_types = NULL, in_path, out_path) {
  raw = read_raw(in_filepath, col_types = col_types)
  interim_data = clean_raw(raw$raw_data, raw$ccpp_name, raw$ccpp_ubigeo)
  write(interim_data, in_filepath, in_path, out_path)
}

col_types = paste(c(rep("c", 4), rep("d", 36), "c"), collapse = "")

in_path = "data/raw/quality-stations/"
in_filepaths = fs::dir_ls(in_path, recurse = TRUE, type = "file")

out_path = "data/interim/quality-stations/"

purrr::walk(
  in_filepaths,
  \(x) process(
    x, col_types = col_types, in_path = in_path, out_path = out_path
  )
)

