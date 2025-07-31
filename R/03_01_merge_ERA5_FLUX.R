#' @title Merge ERA5 and AmeriFlux Data
#'
#' @author Ammara Talib and Junna Wang
#'
#' @description
#' This function is used to merge data from AmeriFlux and data from ERA5, ensuring they both have the same start and end timestamps.
#'
#' @param filename_FLUX (character) The file path to AmeriFlux BASE data downloaded from https://ameriflux.lbl.gov/.
#' @param filename_ERA5 (character) The file path to a CSV file of meterological data downloaded from ERA5 https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview. Please note that the original ERA5 files are in .nc format. You may want to convert these files into CSV format using the function `netcdf_to_csv()`.
#' @param varname_FLUX (character) A vector of variable names in AmeriFlux BASE data to be merged with ERA5 data.
#' @param varname_ERA5 (character) A vector of variable names in ERA5 data to be merged with AmeriFlux BASE data.
#'
#' @note Please note that the length of `varname_FLUX` must be the same as the length of `varname_ERA5`; at the same location, `varname_FLUX` and `varname_ERA5` should refer to the same variable despite the fact that AmeriFlux and ERA5 may use different names for the same variable. For example, for incoming shortwave radiation, ERA5 uses "ssrd", but AmeriFlux uses "SW_IN".
#'
#' @export
#'
#' @return (data.frame) A data frame with the following characteristics:
#' - Datetime stamp column named "time" with the format: "%Y-%m-%d %H:%M:%S".
#' - Time step of the "time" column is the same with that of AmeriFlux file.
#' - It also includes the columns of `varname_FLUX`, the columns of `varname_ERA5`.
#'
#' @examples
#'
#' # First example
#' # Point to AmeriFlux data
#' filename_FLUX <- system.file("extdata", "AMF_BR-Sa1_BASE-BADM_5-5.zip", package = "ERA5Flux")
#' # Point to ERA5 data
#' filename_ERA5 <- system.file("extdata", "BR-Sa1_tp_2002_2011.csv", package = "ERA5Flux")
#' # List AmeriFlux variable(s) to be merged with ERA5
#' varname_FLUX <- c("P")
#' # List ERA5 variable(s) to be merged with AmeriFlux
#' varname_ERA5 <- c("tp")
#' # Merge AmeriFlux and ERA5 data together
#' merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#'
#' # Second example
#' # Point to AmeriFlux data
#' filename_FLUX <- system.file("extdata", "AMF_US-EvM_BASE-BADM_2-5.zip", package = "ERA5Flux")
#' # Point to ERA5 data
#' filename_ERA5 <- system.file("extdata", "US-EvM_ERA_2020_2023_hr.csv", package = "ERA5Flux")
#' # List AmeriFlux variable(s) to be merged with ERA5
#' varname_FLUX <- c('SW_IN', 'TA')
#' # List ERA5 variable(s) to be merged with AmeriFlux
#' varname_ERA5 <- c('ssrd', 't2m')
#' # Merge AmeriFlux and ERA5 data together
#' merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#'
merge_ERA5_FLUX <- function(filename_FLUX = NULL,
                            filename_ERA5 = NULL,
                            varname_FLUX = NULL,
                            varname_ERA5 = NULL) {
  # Error out if no AmeriFlux file path is provided
  if (base::is.null(filename_FLUX)) stop("No AmeriFlux file path provided")

  # Error out if no ERA5 file path is provided
  if (base::is.null(filename_ERA5)) stop("No ERA5 file path provided")

  # Error out if no AmeriFlux variable(s) is provided
  if (base::is.null(varname_FLUX)) stop("No AmeriFlux variable(s) provided")

  # Error out if no ERA5 variable(s) is provided
  if (base::is.null(varname_ERA5)) stop("No ERA5 variable(s) provided")

  if (base::length(filename_FLUX) > 1 | base::length(filename_ERA5) > 1) {
    stop('This function works for one site each time.')
  }
  if (base::length(varname_FLUX) != base::length(varname_ERA5)) {
    stop('To-be-merged varname of FLUX should correspond to to-be-merged varname of ERA5')
  }

  # Read FLUX data
  data_BASE <- amerifluxr::amf_read_base(filename_FLUX, parse_timestamp = TRUE, unzip = TRUE)
  data_BASE[data_BASE <= -9999] <- NA  # Replace abnormal values with NA

  # Read ERA5 data
  data_ERA5 <- utils::read.csv(filename_ERA5)

  if (base::any(!varname_ERA5 %in% base::colnames(data_ERA5))) {
    stop('Wrong varnames were given for ERA5 data')
  }

  # Convert time column to datetime format
  data_ERA5$time <- lubridate::ymd_hm(data_ERA5$time)

  # Find time step of Ameriflux data
  dt <- base::as.numeric(base::difftime(lubridate::ymd_hm(data_BASE$TIMESTAMP_END[2]), lubridate::ymd_hm(data_BASE$TIMESTAMP_END[1]), units = 'hours'))

  # Interpolate ERA5 data to half-hourly intervals
  if (dt == 0.5) {
    data_ERA5_intp <- base::data.frame(time = base::seq(data_ERA5$time[1], data_ERA5$time[nrow(data_ERA5)] + 30*60, by = "30 min"))

    for (i in 1:base::length(varname_ERA5)) {
      if (varname_ERA5[i] == 'tp') {
        data_ERA5_intp[, i + 1] <- base::rep(data_ERA5[, varname_ERA5[i]] / 2, each = 2)
      } else {
        data_ERA5_intp[, i + 1] <- stats::approx(data_ERA5$time, data_ERA5[, varname_ERA5[i]], data_ERA5_intp$time, method = "linear", rule=2)$y
      }
      base::colnames(data_ERA5_intp)[i+1] <- varname_ERA5[i]
    }
  } else {
    data_ERA5_intp <- data_ERA5[, c("time", varname_ERA5)]
  }

  # Format time and add TIMESTAMP for data_BASE
  df_result <- data_ERA5_intp
  df_result$time <- base::format(df_result$time, "%Y-%m-%d %H:%M:%S")
  data_BASE$TIMESTAMP <- lubridate::ymd_hm(as.character(data_BASE$TIMESTAMP_START))
  data_BASE$time <- base::format(data_BASE$TIMESTAMP, "%Y-%m-%d %H:%M:%S")

  # Merge df_result and varname_FLUX variable from data_BASE
  for (i in 1:base::length(varname_FLUX)) {
    if (varname_FLUX[i] %in% base::names(data_BASE)) {
      df_result <- base::merge(df_result, data_BASE[, c("time", varname_FLUX[i])], by = "time", all = TRUE)
    } else {
      # if the FLUX variable names are not in the flux dataset, adding a column with NA values
      df_result[, varname_FLUX[i]] <- NA
    }
  }

  # Return the merged data
  return(df_result)
}
