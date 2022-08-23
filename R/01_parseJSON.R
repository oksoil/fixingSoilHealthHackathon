library(dplyr)
library(jsonlite)
library(purrr)
library(tidyr)
library(tibble)

files <- list.files(
  path = ".\\examples\\examples\\tomkat-historic",
  pattern = "*.json",
  full.names = TRUE
)

data <- jsonlite::fromJSON(
  txt = files[4],
  flatten = TRUE
)

df <- data$Events %>%
  purrr::map(1) %>%
  bind_rows(.id = SampleMetaData.ReportID) %>%
  tidyr::unnest(cols = c(LabMetaData.Reports,
                  EventSamples.Soil.DepthRefs,
                  EventSamples.Soil.SoilSamples)) %>%
  tidyr::unnest(cols = Depths,
         names_repair = "minimal") %>%
  tidyr::unnest(cols = NutrientResults,
         names_repair = "minimal")

#TODO: iterate through all json files in the directory and append to one df
