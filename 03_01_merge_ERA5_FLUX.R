rm(list = ls())  # Removes all objects from the environment
########################################
## this script is used to merge data from AmeriFlux and data from ERA5 together
## Authors: Ammara Talib and Junna Wang
## 3/13/2025
########################################
## we assume ERA5 is hourly data, with the current time zone correction and full dates. 

#########
library(librarian)
shelf('amerifluxr', 'tidyr', 'lubridate')


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
        data_ERA5_intp[, i + 1] <- rep(data_ERA5[, varname_ERA5[i]], each = 2)
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

# Example function call; just for testing the function
# filename_FLUX <- 'data_merge/AMF_BR-Sa1_BASE-BADM_5-5.zip'   # 'data_merge/AMF_US-EvM_BASE-BADM_2-5.zip', "data_merge/AMF_BR-Sa1_BASE-BADM_5-5.zip"
# filename_ERA5 <- 'data_merge/BR-Sa1_tp_2002_2011.csv'    # 'data_merge/US-EvM_ERA_2020_2023_hr.csv', "data_merge/BR-Sa1_tp_2002_2011.csv"
# varname_FLUX <- c("P")  # c('SW_IN', 'TA'), "P"
# varname_ERA5 <- c("tp")  #c('ssrd', 't2m'), "tp"
# #
# merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
