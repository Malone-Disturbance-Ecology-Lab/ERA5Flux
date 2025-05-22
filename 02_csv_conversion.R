
# Required packages
library(ncdf4)
library(lutz)
library(lubridate)
library(dplyr)
library(purrr)

# NetCDF to data frame function
netcdf_to_local_csv <- function(nc_file_path) {
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

# Set base directory
site_folder <- "/Users/saj69/ERA5_FLUX/data_US-TaS"

# Get list of .nc files
nc_files <- list.files(site_folder, pattern = "\\.nc$", full.names = TRUE)

df_list <- list()
found_vars <- c()

for (f in nc_files) {
  df_part <- tryCatch({
    netcdf_to_local_csv(f)
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
  filename <- paste0("US-TaS_", start_year, "_", end_year, "_", var_suffix, ".csv")
  
  write.csv(final_df, file = file.path(site_folder, filename), row.names = FALSE)
  cat("Saved:", filename, "\n")
} else {
  cat("No valid NetCDF data found.\n")
}


####Check###

library(readr)
US_TaS_2017_2019_d2m_ssrd_t2m <- read_csv("ERA5_FLUX/data_US-TaS/US-TaS_2017_2019_d2m_ssrd_t2m.csv")
View(US_TaS_2017_2019_d2m_ssrd_t2m)
