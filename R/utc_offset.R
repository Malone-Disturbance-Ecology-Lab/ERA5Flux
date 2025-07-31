#' @title Check Daylight Saving Time
#'
#' @description
#' This function will check if a given time point is in Daylight Saving Time (DST). If so, it will adjust the time to the standard (non-DST) time.
#'
#' @param lat (numeric) Latitude coordinate in decimal degrees.
#' @param lon (numeric) Longitude coordinate in decimal degrees.
#' @param timepoint (character) Time point in either %Y-%m-%d or %Y/%m/%d format.
#'
#' @return (list) A list containing a boolean representing the DST status and the standard time if DST is in effect.
#'
#' @export
#'
#' @examples
#' # This will get the current time
#' timepoint <- lubridate::now()
#' # Check whether the time is in DST at latitude 25.4, longitude -80.5 and get the standard time if so
#' is_DST <- check_DST(lat = 25.4, lon = -80.5, timepoint)
#'
check_DST <- function(lat = NULL,
                      lon = NULL,
                      timepoint = NULL) {
  # Error out if no lat is provided
  if (base::is.null(lat)) stop("No latitude provided")

  # Error out if no lon is provided
  if (base::is.null(lon)) stop("No longitude provided")

  # Error out if no time point is provided
  if (base::is.null(timepoint)) stop("No time point provided")

  # Get the timezone based on lat, lon
  timezone <- lutz::tz_lookup_coords(lat = lat, lon = lon, method = "accurate")

  # Convert the provided timepoint to the correct time zone
  timepoint <- base::as.POSIXct(timepoint, tz = timezone)

  # Check if the given time point is in Daylight Saving Time
  is_DST <- lubridate::dst(timepoint)  # TRUE if in DST, FALSE if not

  # If it is in DST, adjust the time to the standard (non-DST) time
  if (is_DST) {
    # Subtract the DST offset to get standard time (non-DST)
    standard_time <- timepoint - hours(1)
  } else {
    # If not in DST, no adjustment is needed
    standard_time <- timepoint
  }

  # Return a list with DST status and the standard time if DST is in effect
  return(base::list(is_DST = is_DST, standard_time = standard_time))
}

#' @title Coordinated Universal Time (UTC) Offset
#'
#' @description
#' Offset is the difference between UTC and local time without considering Daylight Saving Time. This function will produce an hour offset number converting local to UTC.
#'
#' @param lat (numeric) Latitude coordinate in decimal degrees.
#' @param lon (numeric) Longitude coordinate in decimal degrees.
#'
#' @return (numeric) The UTC offset.
#'
#' @export
#'
#' @examples
#' # Get the UTC offset at latitude 25.4, longitude -80.5
#' offset <- utc_offset(lat = 25.4, lon = -80.5)
#'
utc_offset <- function(lat = NULL,
                       lon = NULL) {
  # Error out if no lat is provided
  if (base::is.null(lat)) stop("No latitude provided")

  # Error out if no lon is provided
  if (base::is.null(lon)) stop("No longitude provided")

  # Get timezone for the given coordinates
  timezone <- lutz::tz_lookup_coords(lat = lat, lon = lon, method = "accurate")

  if (base::is.na(timezone)) {
    stop("Timezone not found for given coordinates.")
  }

  # Get the current time in UTC
  time_utc <- lubridate::now(tz = "UTC")  # No DST
  #time_utc <- as.POSIXct("2025-06-21 12:00:00", tz = "UTC") ## WITH DST
  #print(time_utc)

  # Convert UTC time to local time with proper timezone
  local_time_result <- lubridate::with_tz(time_utc, tzone = timezone)  # Keeps time zone
  #print(local_time_result)

  # Check if the current time is in Daylight Saving Time (DST)
  result <- check_DST(lat, lon, local_time_result)
  #print(paste("Is it DST? ", result$is_DST))
  #print(paste("Standard time (if not in DST):", result$standard_time))
  local_revised <- result$standard_time

  conversion <- lubridate::force_tz(local_revised, "UTC")
  #print(conversion)
  # Calculate the difference in hours, respecting time zones
  offset_hours <- base::as.numeric(difftime(conversion, time_utc, units = "hours"))

  base::print(offset_hours)
  return(offset_hours)
}

#' @title Date Conversion
#'
#' @description
#' This function will produce a converted time, either UTC -> local, or local -> UTC.
#'
#' @param lat (numeric) Latitude coordinate in decimal degrees.
#' @param lon (numeric) Longitude coordinate in decimal degrees.
#' @param time (character) Time in %Y-%m-%d %H:%M:%S format.
#' @param flag (numeric) Set flag to 0 for local to UTC, set flag to 1 for UTC to local.
#'
#' @return A POSIXct object.
#'
#' @export
#'
#' @note IT TAKES INTO ACCOUNT Daylight Saving Time!!
#'
#' @examples
#' # Convert local to UTC
#' utc_result_winter <- date_conversion(25.2, -80.4, "2018-01-16 22:02:37", 0)
#' # Convert UTC to local
#' local_result <- date_conversion(25.2, -80.4, "2018-01-16 22:02:37", 1)
#'
#' @author Boya ("Paul") Zhang
#'
date_conversion <- function(lat = NULL,
                            lon = NULL,
                            time = NULL,
                            flag = NULL) {
  # Error out if no lat is provided
  if (base::is.null(lat)) stop("No latitude provided")

  # Error out if no lon is provided
  if (base::is.null(lon)) stop("No longitude provided")

  # Error out if no time is provided
  if (base::is.null(time)) stop("No time provided")

  # Error out if no flag is provided
  if (base::is.null(flag)) stop("No flag provided")

  # Get timezone for the given coordinates
  timezone <- lutz::tz_lookup_coords(lat = lat, lon = lon, method = "accurate")
  print(timezone)
  if (flag == 1) {
    # Convert UTC to Local Time
    time <- base::as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S", tz = "UTC")
    local_time_result <- lubridate::with_tz(time, timezone)
    return(local_time_result)
  } else if (flag == 0) {
    # Convert Local Time to UTC
    time <- base::as.POSIXct(time, format = "%Y-%m-%d %H:%M:%S")
    utc_time_result <- lubridate::with_tz(time, "UTC")
    return(utc_time_result)
  } else {
    stop("Invalid flag. Please use 'utc_to_local' or 'local_to_utc'.")
  }
}






