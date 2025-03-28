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

### apply blending function on merged data 
blend_ERA5_FLUX <- function(merged_data, varname_FLUX, varname_ERA5, blending_rule) {
  message("Using columns: ", varname_FLUX, " and ", varname_ERA5)
  
  if (blending_rule == "replace") {
    merged_data[[paste0(varname_FLUX, "_replace")]] <- merged_data[[varname_ERA5]]
  }
  
  if (blending_rule == "lm") {
    complete_cases <- merged_data[!is.na(merged_data[[varname_FLUX]]) & !is.na(merged_data[[varname_ERA5]]), ]
    # we may need to switch the variable name here, Junna. Do we want to have the formula "varname_FLUX ~ varname_ERA5"?
    # ammara: yes we can do that I am fine with it. I just changed it in the code
    if (nrow(complete_cases) > 1) {  
      formula_str <- paste(varname_FLUX, "~", varname_ERA5)
      message("Fitting linear model with formula: ", formula_str)
      lm_model <- lm(as.formula(formula_str), data = complete_cases)
      # ammara I also switched the variable in line below
      merged_data[[paste0(varname_FLUX, "_lm")]] <- predict(lm_model, 
                                                            newdata = setNames(data.frame(merged_data[[varname_ERA5]]), varname_ERA5))
      
      merged_data[[paste0(varname_FLUX, "_lm")]][is.na(merged_data[[paste0(varname_FLUX, "_lm")]])] <- 
        predict(lm_model, newdata = setNames(data.frame(mean(complete_cases[[varname_ERA5]], na.rm = TRUE)), varname_ERA5))# ammara made a change here
    } else {
      ## if there is no enough FLUX data to do linear regrassion
      ## Should we use varname_ERA5? because not enough of FLUX data? Junna
      merged_data[[paste0(varname_FLUX, "_lm")]] <- merged_data[[varname_FLUX]]
    }
  }
  
  if (blending_rule == "lm_no_intercept") {
    complete_cases <- merged_data[!is.na(merged_data[[varname_FLUX]]) & !is.na(merged_data[[varname_ERA5]]), ]
    
    if (nrow(complete_cases) > 1) {  
      formula_str <- paste(varname_FLUX, "~", varname_ERA5, "+ 0")
      message("Fitting linear model without intercept with formula: ", formula_str)
      lm_model_no_intercept <- lm(as.formula(formula_str), data = complete_cases)
      
      merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]] <- predict(lm_model_no_intercept, 
                                                                         newdata = setNames(data.frame(merged_data[[varname_ERA5]]), varname_ERA5)) # ammara changed to varname_ERA5
      
      merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]][is.na(merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]])] <- 
        predict(lm_model_no_intercept, newdata = setNames(data.frame(mean(complete_cases[[varname_ERA5]], na.rm = TRUE)), varname_ERA5)) # ammara changed to varname_ERA5
    } else {
      ## Should we use varname_ERA5? because not enough of FLUX data? Junna # ammara yes I made that change above
      merged_data[[paste0(varname_FLUX, "_lm_no_intercept")]] <- merged_data[[varname_FLUX]]
      
    }
  }
  
  if (blending_rule == "automatic") {
    na_rows <- is.na(merged_data[[varname_FLUX]])
    mean_FLUX <- mean(merged_data[[varname_FLUX]], na.rm = TRUE)
    
    na_subset <- merged_data[na_rows, ]
    na_subset[[varname_FLUX]] <- mean_FLUX
    
    if (exists("lm_model")) {  # Ensure lm_model exists
      predicted_values <- predict(lm_model, newdata = setNames(data.frame(na_subset[[varname_ERA5]]), varname_ERA5))# ammara changed to varname_ERA5
      merged_data[[paste0(varname_FLUX, "_automatic")]] <- merged_data[[varname_FLUX]]
      merged_data[[paste0(varname_FLUX, "_automatic")]][na_rows] <- predicted_values
    } else {
      message("Linear model not available for 'automatic' blending. Keeping original values.")
      merged_data[[paste0(varname_FLUX, "_automatic")]] <- merged_data[[varname_FLUX]]
    }
  }
  return(merged_data)
}

# source merge function
source("03_01_merge_ERA5_FLUX.R")

# define your own FLUX and ERA5 dataset and variables to merge
filename_FLUX <- 'data_merge/AMF_US-EvM_BASE-BADM_2-5.zip'   # 'data_merge/AMF_US-EvM_BASE-BADM_2-5.zip', "data_merge/AMF_BR-Sa1_BASE-BADM_5-5.zip"
filename_ERA5 <- 'data_merge/US-EvM_ERA_2020_2023_hr.csv'    # 'data_merge/US-EvM_ERA_2020_2023_hr.csv', "data_merge/BR-Sa1_tp_2002_2011.csv"
varname_FLUX <- c('SW_IN', 'TA')                             # c('SW_IN', 'TA'), "P"
varname_ERA5 <- c('ssrd', 't2m')                             # c('ssrd', 't2m'), "tp"
blending_rule <- c('lm_no_intercept', 'lm')                  # c('lm_no_intercept', 'lm'), 'replace'

# call the merge function
merged_data <- merge_ERA5_FLUX(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)

# call the blending function
merg_blend <- blend_ERA5_FLUX(merged_data, varname_FLUX, varname_ERA5, blending_rule)

# 
write.csv(merg_blend , "merg_blend.csv", row.names = FALSE)
