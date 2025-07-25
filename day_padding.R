# 
##' .. this function is designed to pad 1 day for the beginning and ending day. ..
##'
##' @title day_padding, this function will produce a new starting and ending day.
##' @param input start and end day
##' @return new start and end day
##' @author Boya ("Paul") Zhang

##' 
rm(list=ls())
day_padding <- function(start_day, end_day) {
  # Convert string to Date format
  start_date <- as.Date(start_day)
  end_date <- as.Date(end_day)
  
  # Adjust dates
  new_start <- start_date - 1
  new_end <- end_date + 1
  
  # Return as character format
  return(list(start_day = as.character(new_start), end_day = as.character(new_end)))
}

result <- day_padding("2024-01-01", "2025-12-31")
