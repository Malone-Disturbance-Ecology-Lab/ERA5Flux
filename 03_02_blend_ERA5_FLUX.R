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
blend_ERA5_Flux <- function(merged_data, varname_FLUX, varname_ERA5, blending_rule) {
  for (i in seq_along(varname_FLUX)) {
    flux_var <- varname_FLUX[i]
    era5_var <- varname_ERA5[i]
    rule <- blending_rule[i]  # Extract corresponding rule for the variable
    
    message("Processing: ", flux_var, " using rule: ", rule)
    
    # Initialize the new "_f" column with the original flux_var values
    merged_data[[paste0(flux_var, "_f")]] <- merged_data[[flux_var]]
    
    if (rule == "replace") {
      # Replace the whole flux variable with ERA5 (copy ERA5 values to new column)
      merged_data[[paste0(flux_var, "_f")]] <- merged_data[[era5_var]]
    }
    
    if (rule == "lm") {
      # Remove rows with NA in either varname_FLUX or varname_ERA5
      complete_cases <- merged_data[!is.na(merged_data[[flux_var]]) & !is.na(merged_data[[era5_var]]), ]
      
      if (nrow(complete_cases) > 1) {  
        formula_str <- paste(flux_var, "~", era5_var)
        message("Fitting linear model with formula: ", formula_str)
        
        lm_model <- lm(as.formula(formula_str), data = complete_cases)
        
        # Only use model predictions to fill missing values in flux_var
        missing_flux_idx <- which(is.na(merged_data[[flux_var]]))  # Identify all missing flux_var entries
        
        if (length(missing_flux_idx) > 0) {
          # Predict missing flux values based on ERA5 data and fill them
          predictions <- predict(lm_model, 
                                 newdata = setNames(data.frame(merged_data[[era5_var]][missing_flux_idx]), era5_var))
          
          # Ensure the predictions fill only the missing values in the new "_f" column
          merged_data[[paste0(flux_var, "_f")]][missing_flux_idx] <- predictions
        }
      }
    }
    
    if (rule == "lm_no_intercept") {
      complete_cases <- merged_data[!is.na(merged_data[[flux_var]]) & !is.na(merged_data[[era5_var]]), ]
      
      if (nrow(complete_cases) > 1) {  
        formula_str <- paste(flux_var, "~", era5_var, "+ 0")  # Linear model without intercept
        message("Fitting linear model without intercept with formula: ", formula_str)
        
        lm_model_no_intercept <- lm(as.formula(formula_str), data = complete_cases)
        
        # Only use model predictions to fill missing values in flux_var
        missing_flux_idx <- which(is.na(merged_data[[flux_var]]))  # Identify all missing flux_var entries
        
        if (length(missing_flux_idx) > 0) {
          # Predict missing flux values based on ERA5 data and fill them
          predictions <- predict(lm_model_no_intercept, 
                                 newdata = setNames(data.frame(merged_data[[era5_var]][missing_flux_idx]), era5_var))
          
          # Ensure the predictions fill only the missing values in the new "_f" column
          merged_data[[paste0(flux_var, "_f")]][missing_flux_idx] <- predictions
        }
      }
    }
    
    if (rule == "automatic") {
      total_count <- nrow(merged_data)
      non_na_count <- sum(!is.na(merged_data[[flux_var]]))
      
      if ((non_na_count / total_count) >= 0.5) {
        # Remove rows with NA in either varname_FLUX or varname_ERA5
        complete_cases <- merged_data[!is.na(merged_data[[flux_var]]) & !is.na(merged_data[[era5_var]]), ]
        
        if (nrow(complete_cases) > 1) {  
          formula_str <- paste(flux_var, "~", era5_var)
          message("Fitting linear model with formula: ", formula_str)
          
          lm_model <- lm(as.formula(formula_str), data = complete_cases)
          
          # Only use model predictions to fill missing values in flux_var
          missing_flux_idx <- which(is.na(merged_data[[flux_var]]))  # Identify all missing flux_var entries
          
          if (length(missing_flux_idx) > 0) {
            # Predict missing flux values based on ERA5 data and fill them
            predictions <- predict(lm_model, 
                                   newdata = setNames(data.frame(merged_data[[era5_var]][missing_flux_idx]), era5_var))
            
            # Ensure the predictions fill only the missing values in the new "_f" column
            merged_data[[paste0(flux_var, "_f")]][missing_flux_idx] <- predictions
          }
        }
      } else {
        message("More than 50% missing in ", flux_var, ", replacing with ", era5_var)
        # If more than 50% of FLUX data is missing, replace the entire FLUX variable with ERA5
        merged_data[[paste0(flux_var, "_f")]] <- merged_data[[era5_var]]
      }
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
blending_rule <- c('lm_no_intercept', 'lm')                  # c('lm_no_intercept', 'lm'),  other rules # automatic, # lm_no_intercept

# call the merge function
merged_data <- merge_ERA5_Flux(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)

# call the blending function
merg_blend <- blend_ERA5_Flux(merged_data, varname_FLUX, varname_ERA5, blending_rule)

# 
write.csv(merg_blend , "merg_blend.csv", row.names = FALSE)
