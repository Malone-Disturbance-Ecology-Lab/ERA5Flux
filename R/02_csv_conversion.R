#' @title NetCDF Reformatter
#'
#' @description
#' Reformats ERA5 .nc data into a data frame.
#'
#' @param nc_file_path (character) File path to ERA5 NetCDF file.
#'
#' @return (data.frame) Data frame of the following characteristics:
#'
#' - Datetime stamp column named "time".
#' - UTC timezones converted to local time.
#' - SiteID is determined from lat and lon coordinates in df.sitemetadata.
#' - Time column formatted as yyyyMMddHHmm, time zone determined using coordinates.
#' - Variables names from ERA5 dataset maintained.
#' - ERA5 units converted to Ameriflux units:
#'    - Solar radiation (ssrd) from Jm-2 to Wm-2.
#'    - Air Temperature (t2m) from Kelvin to Celsius.
#'    - Total precipitation (tp) from meters to millimeters.
#'
#' @export
#'
#' @examples
#' # Point to a NetCDF file
#' nc_file_path <- system.file("extdata", "path_to_ERA5_download_folder",
#'                             "ERA5-US-GL2-2025-1.nc", package = "ERA5Flux")
#' # Reformat the NetCDF
#' result <- netcdf_df_formatter(nc_file_path)
#' head(result)


netcdf_df_formatter <- function(nc_file_path = NULL) {
  # Error out if no file path is provided
  if (base::is.null(nc_file_path)) stop("No file path provided")

  # Open NetCDF file
  nc <- ncdf4::nc_open(nc_file_path)

  # Get all variable names, excluding metadata fields
  all_vars <- base::names(nc$var)
  data_vars <- base::setdiff(all_vars, c("number", "expver"))

  # Extract time variable
  valid_time <- ncdf4::ncvar_get(nc, "valid_time")
  if (base::length(valid_time) == 0) {
    ncdf4::nc_close(nc)
    return(base::data.frame())
  }

  # Convert NetCDF time to POSIXct in UTC
  time_units <- ncdf4::ncatt_get(nc, "valid_time", "units")$value
  time_origin <- base::sub("seconds since ", "", time_units)
  utc_time <- base::as.POSIXct(valid_time, origin = time_origin, tz = "UTC")

  # Get coordinates and determine local time zone
  lat <- ncdf4::ncvar_get(nc, "latitude")
  lon <- ncdf4::ncvar_get(nc, "longitude")
  tz_name <- lutz::tz_lookup_coords(lat, lon, method = "accurate")
  local_time <- lubridate::with_tz(utc_time, tz_name)

  # Format timestamp as YYYYMMDDHHMM
  formatted_time <- base::format(local_time, "%Y%m%d%H%M")
  df <- base::data.frame(time = formatted_time)

  # Calculate time interval in seconds
  time_diff_sec <- if (base::length(utc_time) > 1) {
    base::as.numeric(base::difftime(utc_time[2], utc_time[1], units = "secs"))
  } else {
    3600
  }

  # Loop through each variable and format as vector
  for (varname in data_vars) {
    var_data <- ncdf4::ncvar_get(nc, varname)
    if (base::length(dim(var_data)) > 1) {
      var_data <- base::as.vector(var_data)
    }

    # Apply unit conversions
    if (varname == "t2m") {
      var_data <- var_data - 273.15
    } else if (varname == "ssrd") {
      var_data <- var_data / time_diff_sec
    } else if (varname == "tp") {
      var_data <- var_data * 1000
    } else if (varname == "d2m") {
      var_data <- var_data - 273.15
    }

    # Add variable to data frame
    df[[varname]] <- var_data
  }

  # Close NetCDF file and return data frame
  ncdf4::nc_close(nc)
  return(df)
}








#' @title Export NetCDF to CSV
#'
#' @description
#' Takes a directory of ERA5 .nc data as an argument and exports the data in CSV
#' format. This function grabs each NetCDF file and runs `netcdf_df_formatter()`
#' on it. It builds a list of variables across all data frames in the folder
#' and joins data by time, filtering to return only full years of data.
#'
#' @param site_folder (character) A folder for one site with NetCDF data. The
#' NetCDF files can be of different variables and of different years so long as
#' it is for one site.
#'
#' @param output_filepath (character) File path to where the output CSV should
#' be written.
#'
#' @param site_name (character) Name of the site that will be concatenated onto
#'  CSV file name (e.g. US_GL2).
#'
#' @param full_year (bool) Filter to include only complete years, such that the
#' data will star with the first hour of year and ends with the last hour of a
#' year. Otherwise, return data as is.
#'
#' @return .csv file of NetCDF data within the site folder. The .csv file has
#' the file name format: siteID_startYear_endYear_variableName.csv. For example,
#'  US-Ho1_2001_2020_tp_t2m.csv. SiteID is determined from lat and lon
#'  coordinates in df.sitemetadata. Each CSV file starts from the first hour of
#'  a year (e.g., 2000-01-01 00:00) and ends with the last hour of a year
#'  (e.g., 2020-12-31 23:00) if full_year == TRUE.
#'
#' @export
#'
#' @examples
#' # Point to a folder containing ERA5 .nc files
#' site_folder <- system.file("extdata", "path_to_ERA5_download_folder", package = "ERA5Flux")
#' # Specify a site name
#' site_name <- "US_GL2"
#' # Create a temporary directory to export our output to
#' output_filepath <- tempdir()
#'
#' # Convert NetCDF data to a CSV file
#' netcdf_to_csv(site_folder, output_filepath, site_name, full_year = FALSE)
#'
#' # Read the CSV back in
#' data <- read.csv(list.files(output_filepath, pattern = "US_GL2", full.names = TRUE))
#' head(data)
#'

netcdf_to_csv <- function(site_folder = NULL,
                          output_filepath = NULL,
                          site_name = NULL,
                          full_year = FALSE) {

  if (is.null(site_folder)) stop("No site folder path provided")
  if (is.null(output_filepath)) stop("No output file path provided")
  if (is.null(site_name)) stop("No site name provided")

  # Find .nc files
  nc_files <- list.files(site_folder, pattern = "\\.nc$", full.names = TRUE)
  if (length(nc_files) == 0) {
    cat("No NetCDF files found in", site_folder, "\n")
    return(invisible(NULL))
  }

  df_list <- list()
  found_vars <- character()

  # Loop through all NetCDF files
  for (f in nc_files) {
    df_part <- tryCatch({
      netcdf_df_formatter(f)
    }, error = function(e) {
      message("Error reading ", f, ": ", e$message)
      return(NULL)
    })

    if (!is.null(df_part) && is.data.frame(df_part) && nrow(df_part) > 0) {
      df_list[[length(df_list) + 1]] <- df_part
      found_vars <- union(found_vars, setdiff(names(df_part), "time"))
    }
  }

  if (length(df_list) == 0) {
    cat("No valid NetCDF data found.\n")
    return(invisible(NULL))
  }

  # Merge all data frames by "time"
  df_all <- purrr::reduce(df_list, dplyr::full_join, by = "time")

  # Deduplicate columns
  final_df <- df_all["time"]
  for (v in found_vars) {
    matching_cols <- grep(paste0("^", v, "($|\\.)"), names(df_all), value = TRUE)
    if (length(matching_cols) == 1) {
      final_df[[v]] <- df_all[[matching_cols]]
    } else {
      stacked <- df_all[, matching_cols]
      final_df[[v]] <- apply(stacked, 1, function(row) {
        first_non_na <- row[!is.na(row)]
        if (length(first_non_na)) first_non_na[1] else NA
      })
    }
  }

  # Remove duplicates & sort by time
  final_df <- final_df[!duplicated(final_df$time), ]
  final_df <- final_df[order(final_df$time), ]

  # ---- FULL YEAR FILTERING ----
  # Convert time first
  final_df$time_dt <- as.POSIXct(final_df$time, format = "%Y%m%d%H%M")

  if (full_year) {
    # compute start & end only after time_dt exists
    start_year <- lubridate::year(min(final_df$time_dt, na.rm = TRUE)) + 1
    end_year   <- lubridate::year(max(final_df$time_dt, na.rm = TRUE)) - 1

    start_bound <- as.POSIXct(paste0(start_year, "-01-01 00:00"))
    end_bound   <- as.POSIXct(paste0(end_year, "-12-31 23:00"))

    final_df <- final_df[final_df$time_dt >= start_bound &
                           final_df$time_dt <= end_bound, ]
  } else {
    start_year <- lubridate::year(min(final_df$time_dt, na.rm = TRUE))
    end_year   <- lubridate::year(max(final_df$time_dt, na.rm = TRUE))
  }

  final_df$time <- format(final_df$time_dt, "%Y%m%d%H%M")
  final_df$time_dt <- NULL

  # Save CSV
  var_suffix <- paste(sort(found_vars), collapse = "_")
  filename <- paste0(site_name, "_", start_year, "_", end_year, "_", var_suffix, ".csv")

  utils::write.csv(final_df, file.path(output_filepath, filename), row.names = FALSE)
  cat("Saved:", filename, "\n")

  invisible(final_df)
}


