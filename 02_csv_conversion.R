
# Required packages
library(ncdf4)
library(lutz)
library(lubridate)
library(dplyr)
library(purrr)
library(readr)

#' netcdf_df_formatter
#'
#' @param nc_file_path file path to ERA5 netcdf file
#'
#' @return dataframe if the following characteristics:
#' 
#' Datetime stamp column named "time".
#' UTC timezones converted to local time.
#' SiteID is determined from lat and lon coordinates in df.sitemetadata.
#' Time column formatted as yyyyMMddHHmm, time zone determined using coordinates
#' Variables names from ERA5 dataset maintained
#' ERA5 units converted to Ameriflux units:
#' 
#' Solar radiation (ssrd) from Jm-2 to Wm-2.
#' 
#' Air Temperature (t2m) from Kelvin to celsius.
#' 
#' Total precipitation (tp) from meters to millimeters.
#' 



#' @examples
#' 
nc_file_path <- system.file("data_stream-oper_stepType-accum1.nc", package = "ERA5_FLUX")
netcdf_df_formatter(nc_file_path)
#' 
netcdf_df_formatter <- function(nc_file_path) {
  nc <- nc_open(nc_file_path)
  
  all_vars <- names(nc$var)
  data_vars <- setdiff(all_vars, c("number", "expver"))
  
  valid_time <- ncvar_get(nc, "valid_time")
  if (length(valid_time) == 0) {
    nc_close(nc)
    return(data.frame())
  }
  
  time_units <- ncatt_get(nc, "valid_time", "units")$value
  time_origin <- sub("seconds since ", "", time_units)
  utc_time <- as.POSIXct(valid_time, origin = time_origin, tz = "UTC")
  
  lat <- ncvar_get(nc, "latitude")
  lon <- ncvar_get(nc, "longitude")
  tz_name <- lutz::tz_lookup_coords(lat, lon, method = "accurate")
  local_time <- with_tz(utc_time, tz_name)
  
  formatted_time <- format(local_time, "%Y%m%d%H%M")
  df <- data.frame(time = formatted_time)
  
  time_diff_sec <- if (length(utc_time) > 1) {
    as.numeric(difftime(utc_time[2], utc_time[1], units = "secs"))
  } else {
    3600
  }
  
  for (varname in data_vars) {
    var_data <- ncvar_get(nc, varname)
    if (length(dim(var_data)) > 1) {
      var_data <- as.vector(var_data)
    }
    
    if (varname == "t2m") {
      var_data <- var_data - 273.15
    } else if (varname == "ssrd") {
      var_data <- var_data / time_diff_sec
    } else if (varname == "tp") {
      var_data <- var_data * 1000
    } else if (varname == "d2m") {
      var_data <- var_data - 273.15
    }
    
    df[[varname]] <- var_data
  }
  
  nc_close(nc)
  return(df)
}



#' netcdf_to_csv
#'
#' @param site_folder - (character) a folder for one site with netcdf data. The netcdf files can be of different variables and if different years so long as it is for one site.
#' @param output_filepath - (character) filepath to where the output csv should be written
#' @param site_name - (character) name of the site that will be concantenated onto csv filename (e.g. Us_TaS)

#' @note This function requires netcdf_df_formatter to work.
#' 
#' @return .csv file of netcdf data within site folder of the characteristics described in the netcdf_df_formatter() function. The .csv file is located within the site_folder and has the file name format: siteID_startYear_endYear_variableName.csv For example, US-Ho1_2001_2020_tp_t2m.csv
#' 
#' @note This function grabs each netcdf file and runs netcdf_df_formatter on it. It builds a list of variables across all dataframes in the folder and joins data by time, filtering to return only full years of data.
#' 
#' @export
#'
#' @examples
#' 
#' 
#' 
#' USE THIS WAY: nc_path <- system.file("data_US-TaS", "example.nc", package = "ERA5.FLUX")
site_folder <- "~/ERA5_FLUX/data_US-TaS/"
site_name <- "US_TaS"
netcdf_to_csv(site_folder,output_filepath,"US_TaS")
#'
#'
#'@note Each csv file starts from the first hour of a year (e.g., 2000-01-01 00:00) and ends with the last hour of a year (e.g., 2020-12-31 23:00).
#'


netcdf_to_csv <- function(site_folder,output_filepath, site_name){
  # Get list of .nc files
  nc_files <- list.files(site_folder, pattern = "\\.nc$", full.names = TRUE)
  
  df_list <- list()
  found_vars <- c()
  
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
  
  # Merge all data frames by time
  if (length(df_list) > 0) {
    df_all <- reduce(df_list, full_join, by = "time")
    
    # Deduplicate columns (e.g., t2m.x, t2m.y)
    final_df <- df_all["time"]  # Start with time column only
    for (v in found_vars) {
      matching_cols <- grep(paste0("^", v, "($|\\.)"), names(df_all), value = TRUE)
      if (length(matching_cols) == 1) {
        final_df[[v]] <- df_all[[matching_cols]]
      } else {
        # Prioritize first non-NA value across duplicated columns
        stacked <- df_all[, matching_cols]
        final_df[[v]] <- apply(stacked, 1, function(row) {
          first_non_na <- row[!is.na(row)]
          if (length(first_non_na)) first_non_na[1] else NA
        })
      }
    }
    
    final_df <- final_df[!duplicated(final_df$time), ]
    final_df <- final_df[order(final_df$time), ]
    
    # Filter to full years only
    final_df$time_dt <- as.POSIXct(final_df$time, format = "%Y%m%d%H%M",)
    
    start_year <- year(min(final_df$time_dt, na.rm = TRUE))+1
    end_year <- year(max(final_df$time_dt, na.rm = TRUE))-1
    
    start_bound <- as.POSIXct(paste0(start_year, "-01-01 00:00"))
    end_bound <- as.POSIXct(paste0(end_year, "-12-31 23:00"))
    
    final_df <- final_df[final_df$time_dt >= start_bound & final_df$time_dt <= end_bound, ]
    final_df$time <- format(final_df$time_dt, "%Y%m%d%H%M")
    final_df$time_dt <- NULL
    
    # Create filename and save
    var_suffix <- paste(sort(found_vars), collapse = "_")
    filename <- paste0(site_name, start_year, "_", end_year, "_", var_suffix, ".csv")
    
    write.csv(final_df, file = file.path(output_filepath, filename), row.names = FALSE)
    cat("Saved:", filename, "\n")
  } else {
    cat("No valid NetCDF data found.\n")
  }
  
}


