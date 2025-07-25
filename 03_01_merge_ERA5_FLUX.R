
# Required packages
library(librarian)
shelf('amerifluxr', 'tidyr', 'lubridate')

#' @title merge_ERA5_FLUX
#'
#' @author Ammara Talib and Junna Wang
#'
#' @description
#' this function is used to merge data from AmeriFlux and data from ERA5, ensuring they have the same start and end of timestamp and timestep with AmeriFlux data
#'
#' @param
#' filename_FLUX: the file name of AmeriFlux BASE data downloaded from https://ameriflux.lbl.gov/
#' filename_ERA5: a csv file of meterological data downloaded from ERA5 https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview
#'                please note that the original ERA5 files are in .nc format. You may want to convert these files into csv format using the function 02_csv_conversion.R
#' varname_FLUX: variable names in AmeriFlux BASE data to be merged with ERA5 data
#' varname_ERA5: variable names in ERA5 data to be merged with AmeriFlux BASE data
#'               please note that the length of varname_FLUX must be the same as the length of varname_ERA5; at the same location, varname_FLUX and varname_ERA5 should refer to the same variable despite AmeriFlux and ERA5 may use different names for the same variable. For example, for incoming shortwave radiation, ERA5 uses ssrd, but AmeriFlux uses SW_IN.
#'
#' @return dataframe with the following characteristics:
#'
#' Datetime stamp column named "time" with the format: "%Y-%m-%d %H:%M:%S";
#' time step of the "time" column is the same with that of AmeriFlux file;
#' It also includes the columns of varname_FLUX, the columns of varname_ERA5
#'
#' @examples
#'
#' # first example
#' filename_FLUX <- system.file("extdata", "AMF_BR-Sa1_BASE-BADM_5-5.zip", package = "ERA5Flux")
#' filename_ERA5 <- system.file("extdata", "BR-Sa1_tp_2002_2011.csv", package = "ERA5Flux")
#' varname_FLUX <- c("P")
#' varname_ERA5 <- c("tp")
#' merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#'
#' # second example
#' filename_FLUX <- system.file("extdata", "AMF_US-EvM_BASE-BADM_2-5.zip", package = "ERA5Flux")
#' filename_ERA5 <- system.file("extdata", "US-EvM_ERA_2020_2023_hr.csv", package = "ERA5Flux")
#' varname_FLUX <- c('SW_IN', 'TA')
#' varname_ERA5 <- c('ssrd', 't2m')
#' merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#'

merge_ERA5_FLUX <- function(filename_FLUX, filename_ERA5,
                            varname_FLUX, varname_ERA5) {
  if (length(filename_FLUX) > 1 | length(filename_ERA5) > 1) {
    stop('This function works for one site each time.')
  }
  if (length(varname_FLUX) != length(varname_ERA5)) {
    stop('To-be-merged varname of FLUX should correspond to to-be-merged varname of ERA5')
  }

  # Read FLUX data
  data_BASE <- amf_read_base(filename_FLUX, parse_timestamp = TRUE, unzip = TRUE)
  data_BASE[data_BASE <= -9999] <- NA  # Replace abnormal values with NA

  # Read ERA5 data
  data_ERA5 <- read.csv(filename_ERA5)

  if (any(!varname_ERA5 %in% colnames(data_ERA5))) {
    stop('Wrong varnames were given for ERA5 data')
  }

  # Convert time column to datetime format
  data_ERA5$time <- ymd_hm(data_ERA5$time)

  # Find time step of Ameriflux data
  dt <- as.numeric(difftime(ymd_hm(data_BASE$TIMESTAMP_END[2]), ymd_hm(data_BASE$TIMESTAMP_END[1]), units = 'hours'))

  # Interpolate ERA5 data to half-hourly intervals
  if (dt == 0.5) {
    data_ERA5_intp <- data.frame(time = seq(data_ERA5$time[1], data_ERA5$time[nrow(data_ERA5)] + 30*60, by = "30 min"))

    for (i in 1:length(varname_ERA5)) {
      if (varname_ERA5[i] == 'tp') {
        data_ERA5_intp[, i + 1] <- rep(data_ERA5[, varname_ERA5[i]] / 2, each = 2)
      } else {
        data_ERA5_intp[, i + 1] <- approx(data_ERA5$time, data_ERA5[, varname_ERA5[i]], data_ERA5_intp$time, method = "linear", rule=2)$y
      }
      colnames(data_ERA5_intp)[i+1] <- varname_ERA5[i]
    }
  } else {
    data_ERA5_intp <- data_ERA5[, c("time", varname_ERA5)]
  }

  # Format time and add TIMESTAMP for data_BASE
  df_result <- data_ERA5_intp
  df_result$time <- format(df_result$time, "%Y-%m-%d %H:%M:%S")
  data_BASE$TIMESTAMP <- ymd_hm(as.character(data_BASE$TIMESTAMP_START))
  data_BASE$time <- format(data_BASE$TIMESTAMP, "%Y-%m-%d %H:%M:%S")

  # Merge df_result and varname_FLUX variable from data_BASE
  for (i in 1:length(varname_FLUX)) {
    if (varname_FLUX[i] %in% names(data_BASE)) {
      df_result <- merge(df_result, data_BASE[, c("time", varname_FLUX[i])], by = "time", all = TRUE)
    } else {
      # if the FLUX variable names are not in the flux dataset, adding a column with NA values
      df_result[, varname_FLUX[i]] <- NA
    }
  }

  # Return the merged data
  return(df_result)
}

filename_FLUX <- system.file("extdata", "AMF_BR-Sa1_BASE-BADM_5-5.zip", package = "ERA5Flux")
filename_ERA5 <- system.file("extdata", "BR-Sa1_tp_2002_2011.csv", package = "ERA5Flux")
varname_FLUX <- c("P")
varname_ERA5 <- c("tp")
merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#'
#' # second example
#' filename_FLUX <- system.file("extdata", "AMF_US-EvM_BASE-BADM_2-5.zip", package = "ERA5Flux")
#' filename_ERA5 <- system.file("extdata", "US-EvM_ERA_2020_2023_hr.csv", package = "ERA5Flux")
#' varname_FLUX <- c('SW_IN', 'TA')
#' varname_ERA5 <- c('ssrd', 't2m')
#' merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
