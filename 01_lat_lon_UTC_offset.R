##' .. this function is designed to calculate UTC offset given a local time . ..
##'
##' @title UTC_offset, this function will produce a hour offset number converting local to UTC.
##' @param input lat, lon, time (string format), flag (flag == 0 local to utc, flag == 1 utc to local)
##' @return UTC offset
##' @note install lutz package
##' @author Boya ("Paul") Zhang
##' 
##' 
##' 
library(lutz)
library(lubridate)
#library(tmaptools)
library(sf)
#library(tzlookup)
#library(httr)
library(data.table)
#library(timechange)
#library(purrr)

rm(list = ls())
dt <- data.table(  
  local_time = c("2018-01-16 22:02:37"),  
  utc_time =c("2018-01-16 22:02:37"),
  lat = c(25.0433),  
  long = c(-80.1918)  
)

lat <- 25.0433
lon <- -80.1918
time <- "2018-01-16 22:02:37"
flag <- 0 ### local to utc
date_conversion <- function(lat, lon, time, flag) {
 
  # Get timezone for the given coordinates
  timezone <- tz_lookup_coords(lat = lat, lon = lon, method = "accurate")
  print(timezone)
  if (flag == 1) {
    # Convert UTC to Local Time
    time <- as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    local_time_result <- with_tz(time, timezone)
    return(local_time_result)
  } else if (flag == 0) {
    # Convert Local Time to UTC
    time <- as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S")
    utc_time_result <- with_tz(time, "UTC")
    return(utc_time_result)
  } else {
    stop("Invalid flag. Please use 'utc_to_local' or 'local_to_utc'.")
  }
}

utc_result <- date_conversion(lat, lon, "2018-01-16 22:02:37", 0)
local_result <- date_conversion(lat, lon, "2018-01-16 22:02:37", 1)

####################### Block below used for dataframe with multiple rows ###########
############### converting utc to local ########
dt[, utc_time := as.POSIXct(utc_time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")]

# Get timezone for each coordinate
dt[, timezone := tz_lookup_coords(lat = lat, lon = long, method = "accurate")]

# Convert UTC time to local time using the determined timezone
dt[, local_time_result := with_tz(utc_time, timezone)]

####### converting local to utc #####
dt[, timezone := tz_lookup_coords(lat = lat, lon = long, method = "accurate")]  

dt[, local_time := as.POSIXct(local_time, format = "%Y-%m-%d %H:%M:%S", tz = timezone)]

dt[, utc_time_result := with_tz(local_time, "UTC")]

