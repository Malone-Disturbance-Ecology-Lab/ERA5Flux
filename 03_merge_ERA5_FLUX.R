rm(list = ls())  # Removes all objects from the environment
########################################
## this script is used to merge data from AmeriFlux and data from ERA5 by adding new columns to AmeriFlux file
## Authors: Ammara Talib and Junna Wang
## 3/13/2025
########################################
## need to discuss: filename_FLUX, zip file?
## how to know one variable is a vector or a value? the variable name part. 
## we assume ERA5 is hourly data, with the current time zone correction and full dates. 
## the last time step of ERA5. 

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
  
  if (!varname_ERA5 %in% colnames(data_ERA5)) {
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
        data_ERA5_intp[, i + 1] <- approx(data_ERA5$time, data_ERA5[, varname_ERA5[i]], data_ERA5_intp$time, method = "linear")$y
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

# Example function call
filename_FLUX <- "data_merge/AMF_BR-Sa1_BASE-BADM_5-5.zip"   # 'data_merge/AMF_US-EvM_BASE-BADM_2-5.zip'
filename_ERA5 <- "data_merge/BR-Sa1_tp_2002_2011.csv"        # 'data_merge/US-EvM_ERA_2020_2023_hr.csv'
varname_FLUX <- "P"   # c('SW_IN')
varname_ERA5 <- "tp"  # c('ssrd')
blending_rule <- 'replace'
#
merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)

### apply blending function on merged data 
blend_ERA5_FLUX <- function(merged_data, varname_FLUX, varname_ERA5, blending_rule) {
  message("Using columns: ", varname_FLUX, " and ", varname_ERA5)
  
  if (blending_rule == "replace") {
    merged_data[[paste0(varname_FLUX, "_replace")]] <- merged_data[[varname_ERA5]]
  }
  
  if (blending_rule == "lm") {
    complete_cases <- merged_data[!is.na(merged_data[[varname_FLUX]]) & !is.na(merged_data[[varname_ERA5]]), ]
    # we may need to switch the variable name here, Junna
    if (nrow(complete_cases) > 1) {  
      formula_str <- paste(varname_ERA5, "~", varname_FLUX)
      message("Fitting linear model with formula: ", formula_str)
      lm_model <- lm(as.formula(formula_str), data = complete_cases)
      
      merged_data[[paste0(varname_FLUX, "_lm")]] <- predict(lm_model, 
                                                            newdata = setNames(data.frame(merged_data[[varname_FLUX]]), varname_FLUX))
      
      merged_data[[paste0(varname_FLUX, "_lm")]][is.na(merged_data[[paste0(varname_FLUX, "_lm")]])] <- 
        predict(lm_model, newdata = setNames(data.frame(mean(complete_cases[[varname_FLUX]], na.rm = TRUE)), varname_FLUX))
    } else {
      ## if there is no enough FLUX data to do linear regrassion
      ## Should we use varname_ERA5? because not enough of FLUX data? Junna
      merged_data[[paste0(varname_FLUX, "_lm")]] <- merged_data[[varname_FLUX]]
    }
  }
  
  if (blending_rule == "lm_no_intercept") {
    complete_cases <- merged_data[!is.na(merged_data[[varname_FLUX]]) & !is.na(merged_data[[varname_ERA5]]), ]
    
    if (nrow(complete_cases) > 1) {  
      formula_str <- paste(varname_ERA5, "~", varname_FLUX, "+ 0")
      message("Fitting linear model without intercept with formula: ", formula_str)
      lm_model_no_intercept <- lm(as.formula(formula_str), data = complete_cases)
      
      merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]] <- predict(lm_model_no_intercept, 
                                                                         newdata = setNames(data.frame(merged_data[[varname_FLUX]]), varname_FLUX))
      
      merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]][is.na(merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]])] <- 
        predict(lm_model_no_intercept, newdata = setNames(data.frame(mean(complete_cases[[varname_FLUX]], na.rm = TRUE)), varname_FLUX))
    } else {
      ## Should we use varname_ERA5? because not enough of FLUX data? Junna
      merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]] <- merged_data[[varname_FLUX]]
    }
  }
  
  if (blending_rule == "automatic") {
    na_rows <- is.na(merged_data[[varname_FLUX]])
    mean_FLUX <- mean(merged_data[[varname_FLUX]], na.rm = TRUE)
    
    na_subset <- merged_data[na_rows, ]
    na_subset[[varname_FLUX]] <- mean_FLUX
    
    if (exists("lm_model")) {  # Ensure lm_model exists
      predicted_values <- predict(lm_model, newdata = setNames(data.frame(na_subset[[varname_FLUX]]), varname_FLUX))
      merged_data[[paste0(varname_FLUX, "_automatic")]] <- merged_data[[varname_FLUX]]
      merged_data[[paste0(varname_FLUX, "_automatic")]][na_rows] <- predicted_values
    } else {
      message("Linear model not available for 'automatic' blending. Keeping original values.")
      merged_data[[paste0(varname_FLUX, "_automatic")]] <- merged_data[[varname_FLUX]]
    }
  }
  return(merged_data)
}


merg_blend <- blend_ERA5_FLUX(merged_data, varname_FLUX, varname_ERA5, blending_rule)

# I think our final result should be adding more columns to AMF data, Junna 
write.csv(merg_blend , "merg_blend.csv", row.names = FALSE)


