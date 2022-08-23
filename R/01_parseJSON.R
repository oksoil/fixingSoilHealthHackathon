# import libraries

library(dplyr)
library(jsonlite)
library(purrr)
library(tidyr)

# list all files in directory

files <- list.files(
  path = ".\\examples\\examples\\tomkat-historic",
  pattern = "*.json",
  full.names = TRUE
)

# import json file

data <- jsonlite::fromJSON(
  txt = files[4],
  flatten = TRUE
)

# unnest all lists and wrangle data

df <- data$Events %>%
  purrr::map(1) %>%
  dplyr::bind_rows(.id = SampleMetaData.ReportID) %>%
  tidyr::unnest(cols = c(
    LabMetaData.Reports,
    EventSamples.Soil.DepthRefs,
    EventSamples.Soil.SoilSamples
  )) %>%
  tidyr::unnest(
    cols = Depths,
    names_repair = "minimal"
  ) %>%
  tidyr::unnest(
    cols = NutrientResults,
    names_repair = "minimal"
  ) %>%
  dplyr::rename(
    EventDate = EventMetaData.EventDate,
    EventType.Soil = EventMetaData.EventType.Soil,
    SampleNumber = SampleMetaData.SampleNumber,
    PointID = SampleMetaData.ReportID,
    Geometry = SampleMetaData.Geometry.wkt
  )

# create unique SampleID from PointID and Date

df$SampleID <- paste0(df$EventDate, "_", df$PointID)

# parse coordinates into separate columns

df <- df %>%
  tidyr::separate(Geometry,
    into = c("long", "lat"),
    sep = " "
  )

df$long <- as.numeric(regmatches(
  df$long,
  gregexpr("(?>-)*[[:digit:]]+\\.*[[:digit:]]*",
    df$long,
    perl = TRUE
  )
))

df$lat <- as.numeric(regmatches(
  df$lat,
  gregexpr("(?>-)*[[:digit:]]+\\.*[[:digit:]]*",
    df$lat,
    perl = TRUE
  )
))

# TODO: iterate through all json files in the directory and append to one df
