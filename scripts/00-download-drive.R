library(googledrive)
drive_auth(email = "diego.villa@upch.pe")

RAW_PATH = "data/raw"
if (!dir.exists(RAW_PATH)) dir.create(RAW_PATH, recursive = TRUE)

WEATHER_ID = "1pEzonxD4C542EyOZrxyjUf1ewmoul18w"
weather_folders = drive_ls(as_id(WEATHER_ID))

for (i in 1:nrow(weather_folders)) {
  folder_name = weather_folders$name[i]
  folder_id = weather_folders$id[i]
  folder_path = fs::path(RAW_PATH, "weather-stations", folder_name)
  if (!dir.exists(folder_path)) dir.create(folder_path, recursive = TRUE)
  files = drive_ls(as_id(folder_id))
  for (j in 1:nrow(files)) {
    file_name = files$name[j] |> 
      fs::path_ext_remove() |> 
      stringr::str_replace_all("_", "-")
    file_id = files$id[j]
    file_path = fs::path(folder_path, paste0(file_name, ".xlsx"))
    drive_download(as_id(file_id), file_path, overwrite = TRUE)
  }
}

QUALITY_ID = "15DNVewXKyVdJewC-KtJowypETJnYmVmE"
quality_folders = drive_ls(as_id(QUALITY_ID))

for (i in 1:nrow(quality_folders)) {
  folder_name = quality_folders$name[i]
  folder_id = quality_folders$id[i]
  folder_path = fs::path(RAW_PATH, "quality-stations", folder_name)
  # if (!dir.exists(folder_path)) dir.create(folder_path, recursive = TRUE)
  subfolders = drive_ls(as_id(folder_id))
  for (j in 1:nrow(subfolders)) {
    subfolder_name = stringr::str_replace_all(subfolders$name[j], "_", "-")
    subfolder_id = subfolders$id[i]
    subfolder_path = fs::path(folder_path, subfolder_name)
    if (!dir.exists(subfolder_path)) dir.create(subfolder_path, recursive = TRUE)
    files = drive_ls(as_id(subfolder_id), pattern = "*.csv")
    for (k in 1:nrow(files)) {
      file_name = files$name[k]
      file_id = files$id[k]
      file_path = fs::path(subfolder_path, file_name)
      drive_download(as_id(file_id), file_path, overwrite = TRUE)
    }
  }
}

