library(shiny)
library(tidyverse)
library(jsonlite)
library(shinydashboard)
library(reactable)
library(leaflet)
library(shinycssloaders)
library(shinyWidgets)
library(readr)
library(reactablefmtr)
library(shinyjs)


naics <- read_csv("data/2017_titles_descriptions.csv")

de.data <-
  fromJSON(
    URLencode(
      "https://data.delaware.gov/resource/s4ev-nzhm.json?$where=state = 'DE'"
    )
  )

de.data$geocoded_location$coordinates[sapply(de.data$geocoded_location$coordinates, is.null)] <-
  NA

de.data$lng <-
  unlist(lapply(de.data$geocoded_location$coordinates, `[`, 1))
de.data$lat <-
  unlist(lapply(de.data$geocoded_location$coordinates, `[`, 2))
de.data$geocoded_location <- NULL
de.data$job_description[is.na(de.data$job_description)] <-
  "No description available."
de.data$website <-
  gsub("http:\\/\\/|www.|https:\\/\\/",
       "http://",
       de.data$website)

f <- function(x)
  if_else(is.na(x), F, T)

vars.to.match <-
  "wbe|mbe|hispanic|nativeamer|asian|veteran|african|subasian|disabled"
de.data <- de.data %>% mutate_at(vars(matches(vars.to.match)), f)
de.data$company_name <- gsub("�", "'", de.data$company_name)
de.data$job_description <- gsub("�", "'", de.data$job_description)
de.data$city[de.data$city == "New Castle,"] <- "New Castle"
de.data$city[de.data$city == "Millsoboro"] <- "Millsboro"


de.data <- de.data %>%
  mutate(naics_root = substr(naicscode1, 1, 5))  %>%
  left_join(naics, by = c("naics_root" = "NAICS")) %>%
  rename('naics_title' = "2017 NAICS Short Title")