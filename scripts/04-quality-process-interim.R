in_path = "data/interim/quality-stations/"
out_path = "data/processed/"
in_directories = in_path |> 
  fs::dir_ls(recurse = TRUE, type = "file") |> 
  fs::path_dir() |> 
  unique()

col_types = paste(c("Tccc", rep("d", 37), "cc"), collapse = "")

for (i in seq_along(in_directories)) {
  in_filepaths = fs::dir_ls(in_directories[i], recurse = TRUE, type = "file")
  datasets = purrr::map(
    in_filepaths,
    \(x) readr::read_csv(x, col_types = col_types)
  )
  names(datasets) = names(datasets) |> 
    fs::path_file() |> 
    fs::path_ext_remove() |> 
    lubridate::ymd()
  dataset = datasets |> 
    dplyr::bind_rows(.id = "cutoff_date") |> 
    dplyr::distinct()
  ccpp = stringr::str_split(in_directories[i], "[/]")[[1]][4]
  type = stringr::str_split(in_directories[i], "[/]")[[1]][3]
  out_filepath = fs::path(out_path, type, paste(ccpp, "csv", sep = "."))
  if (!dir.exists(fs::path_dir(out_filepath))) {
    dir.create(fs::path_dir(out_filepath), recursive = TRUE)
  }
  readr::write_csv(dataset, out_filepath, na = "")
  print(out_filepath)
  
  missings = naniar::miss_var_summary(dataset)
  dataset_numeric = dplyr::select(dataset, dplyr::where(is.numeric))
  nearzero_summ = dataset_numeric |>
    caret::nearZeroVar(saveMetrics = TRUE) |>
    tibble::rownames_to_column(var = "variable")
  diagnostics = missings |>
    dplyr::left_join(nearzero_summ, by = "variable") |>
    dplyr::rename(
      freq_rate = freqRatio, pct_unique = percentUnique, zero_var = zeroVar,
      nearzero_var = nzv
    )
  diagnostics_path = fs::path(
    "data/diagnostics/", type, paste(ccpp, "csv", sep = ".")
  )
  if (!dir.exists(fs::path_dir(diagnostics_path))) {
    dir.create(fs::path_dir(diagnostics_path), recursive = TRUE)
  }
  readr::write_csv(diagnostics, diagnostics_path, na = "")
  print(diagnostics_path)
}
