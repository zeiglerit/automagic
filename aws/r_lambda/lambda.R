library(jsonlite)
library(httr)
library(dplyr)
library(lubridate)

handler <- function(event, context) {
  latitude <- as.numeric(event$latitude)
  longitude <- as.numeric(event$longitude)
  days <- as.integer(event$days)

  url <- "https://api.open-meteo.com/v1/forecast"
  query <- list(
    latitude = latitude,
    longitude = longitude,
    daily = "temperature_2m_max,temperature_2m_min",
    timezone = "auto",
    past_days = days
  )

  response <- GET(url, query = query)
  if (status_code(response) != 200) {
    return(list(error = paste("API failed:", status_code(response))))
  }

  data <- fromJSON(content(response, "text", encoding = "UTF-8"))
  temps <- data$daily

  df <- data.frame(
    date = as_date(temps$time),
    temp_max = temps$temperature_2m_max,
    temp_min = temps$temperature_2m_min
  )

  summary <- df %>%
    summarise(
      avg_high = mean(temp_max),
      avg_low = mean(temp_min),
      max_temp = max(temp_max),
      min_temp = min(temp_min)
    )

  return(toJSON(summary, auto_unbox = TRUE))
}