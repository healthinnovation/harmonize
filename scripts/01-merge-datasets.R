library(dplyr)

interim_path = "data/interim/"

file_paths = fs::dir_ls(interim_path)
datasets = purrr::map(file_paths, readr::read_csv)
dataset_merged = purrr::reduce(datasets, inner_join, by = "ubigeocp")

dataset = dataset_merged %>% 
  mutate(
    pr_avg = (pr_2010 + pr_2021) / 2,
    ro_avg = (ro_2010 + ro_2021) / 2,
    soil_avg = (soil_2010 + soil_2021) / 2,
    tmmx_avg = (tmmx_2010 + tmmx_2021) / 2,
    tmmn_avg = (tmmn_2010 + tmmn_2021) / 2,
    etp_avg = (etp_2010 + etp_2021) / 2,
    humidity_avg = (humidity_2010 + humidity_2021) / 2,
    pop_avg = (pop_2010 + pop_2020) / 2,
    def_avg = (def_2010 + def_2021) / 2,
    ghsl_avg = (ghsl_2010 + ghsl_2020) / 2,
    ln_avg = (ln_2014 + ln_2021) / 2,
    malaria_avg = (cases_2010 + cases_2019) / 2 * poblacion,
    pr_diff = pr_2021 - pr_2010,
    ro_diff = ro_2021 - ro_2010,
    soil_diff = soil_2021 - soil_2010,
    tmmx_diff = tmmx_2021 - tmmx_2010,
    tmmn_diff = tmmn_2021 - tmmn_2010,
    etp_diff = etp_2021 - etp_2010,
    humidity_diff = humidity_2021 - humidity_2010,
    pop_diff = pop_2020 - pop_2010,
    def_diff = def_2021 - def_2010,
    ghsl_diff = ghsl_2020 - ghsl_2010,
    ln_diff = ln_2021 - ln_2014,
    malaria_diff = (cases_2019 - cases_2010) / poblacion,
    across(dengue:leptospirosis, ~.x / poblacion)
  ) %>% 
  select(-matches("[0-9]"))

processed_path = "data/processed/"
output_filename = "ccpp-10km.csv"
output_path = fs::path(processed_path, output_filename)
readr::write_csv(dataset, output_path,  na = "")




