#' @title Blend ERA5 and AmeriFlux Data
#'
#' @author Ammara Talib and Junna Wang
#'
#' @description
#' This function is used to blend data from AmeriFlux and data from ERA5, ensuring they both have the same start and end timestamps. Please first make sure to run the merge function (`merge_ERA5_FLUX()`) first, because output of merge function will be used as input of this blending function.
#'
#' @param merged_data (data.frame) A data frame that has a datetime stamp column named "time" with the format: "%Y-%m-%d %H:%M:%S". The time step of the "time" column is the same with that of AmeriFlux file. It also includes the columns of AmeriFlux and ERA5 data that were merged together.
#' @param varname_FLUX (character) A vector of variable names in AmeriFlux BASE data to be blended with ERA5 data.
#' @param varname_ERA5 (character) A vector of variable names in ERA5 data to be blended with AmeriFlux BASE data.
#' @param blending_rule (character) There are four types of blending rules that can be used to blend AmeriFlux and ERA5 variables:
#' - "lm": Linear regression with slope. Fits a linear model with slope, FLUX ~ ERA5, then only fills missing values in FLUX with predicted values from ERA5.
#' - "lm_no_intercept": Linear regression without slope. Fits a linear model without slope, FLUX ~ ERA5, then only fills missing values in FLUX with predicted values from ERA5.
#' - "replace": Replace Ameriflux variable with ERA5 variable.
#' - "automatic": Checks for non-missing FLUX values. If ≥50% present then uses "lm" approach. If <50% present then fallback to "replace".
#'
#' @note Please note that the length of `varname_FLUX` must be the same as the length of `varname_ERA5`; at the same location, `varname_FLUX` and `varname_ERA5` should refer to the same variable despite the fact that AmeriFlux and ERA5 may use different names for the same variable. For example, for incoming shortwave radiation, ERA5 uses "ssrd", but AmeriFlux uses "SW_IN".
#'
#' @return (data.frame) A data frame with the following characteristics:
#' - Time step of the "time" column is the same with that of AmeriFlux file.
#' - It also includes the columns of `varname_FLUX`, the columns of `varname_ERA5`.
#' - Variable column with the blending rule applied on it. Name of the blended column is similar to AmeriFlux column name but with addition of "_f".
#'
#' @examples
#'
#' # First example
#' # Please first make sure to run the merge function (`merge_ERA5_FLUX()`) first, because output of merge function will be used as input of this blending function
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
#' # Specify the blending rule(s)
#' blending_rule <- c('lm_no_intercept')
#' # Blend AmeriFlux and ERA5 data together
#' merg_blend <- blend_ERA5_Flux(merged_data, varname_FLUX, varname_ERA5, blending_rule)
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
#' # Specify the blending rule(s)
#' blending_rule <- c('replace', 'automatic')
#' # Blend AmeriFlux and ERA5 data together
#' merg_blend <- blend_ERA5_Flux(merged_data, varname_FLUX, varname_ERA5, blending_rule)
#'
blend_ERA5_Flux <- function(merged_data = NULL,
                            varname_FLUX = NULL,
                            varname_ERA5 = NULL,
                            blending_rule = NULL) {

  # Error out if no merged data is provided
  if (base::is.null(merged_data)) stop("No merged data provided")

  # Error out if no AmeriFlux variable(s) is provided
  if (base::is.null(varname_FLUX)) stop("No AmeriFlux variable(s) provided")

  # Error out if no ERA5 variable(s) is provided
  if (base::is.null(varname_ERA5)) stop("No ERA5 variable(s) provided")

  # Error out if no blending rule(s) is provided
  if (base::is.null(blending_rule)) stop("No blending rule(s) provided")

  for (i in base::seq_along(varname_FLUX)) {
    flux_var <- varname_FLUX[i]
    era5_var <- varname_ERA5[i]
    rule <- blending_rule[i]  # Extract corresponding rule for the variable

    base::message("Processing: ", flux_var, " using rule: ", rule)

    # Initialize the new "_f" column with the original flux_var values
    merged_data[[paste0(flux_var, "_f")]] <- merged_data[[flux_var]]

    if (rule == "replace") {
      # Replace the whole flux variable with ERA5 (copy ERA5 values to new column)
      merged_data[[paste0(flux_var, "_f")]] <- merged_data[[era5_var]]
    }

    if (rule == "lm") {
      # Remove rows with NA in either varname_FLUX or varname_ERA5
      complete_cases <- merged_data[!base::is.na(merged_data[[flux_var]]) & !base::is.na(merged_data[[era5_var]]), ]

      if (base::nrow(complete_cases) > 1) {
        formula_str <- base::paste(flux_var, "~", era5_var)
        base::message("Fitting linear model with formula: ", formula_str)

        lm_model <- stats::lm(as.formula(formula_str), data = complete_cases)

        # Only use model predictions to fill missing values in flux_var
        missing_flux_idx <- base::which(base::is.na(merged_data[[flux_var]]))  # Identify all missing flux_var entries

        if (base::length(missing_flux_idx) > 0) {
          # Predict missing flux values based on ERA5 data and fill them
          predictions <- stats::predict(lm_model,
                                        newdata = setNames(data.frame(merged_data[[era5_var]][missing_flux_idx]), era5_var))

          # Ensure the predictions fill only the missing values in the new "_f" column
          merged_data[[base::paste0(flux_var, "_f")]][missing_flux_idx] <- predictions
        }
      }
    }

    if (rule == "lm_no_intercept") {
      complete_cases <- merged_data[!base::is.na(merged_data[[flux_var]]) & !base::is.na(merged_data[[era5_var]]), ]

      if (base::nrow(complete_cases) > 1) {
        formula_str <- base::paste(flux_var, "~", era5_var, "+ 0")  # Linear model without intercept
        base::message("Fitting linear model without intercept with formula: ", formula_str)

        lm_model_no_intercept <- stats::lm(as.formula(formula_str), data = complete_cases)

        # Only use model predictions to fill missing values in flux_var
        missing_flux_idx <- base::which(base::is.na(merged_data[[flux_var]]))  # Identify all missing flux_var entries

        if (base::length(missing_flux_idx) > 0) {
          # Predict missing flux values based on ERA5 data and fill them
          predictions <- stats::predict(lm_model_no_intercept,
                                        newdata = setNames(data.frame(merged_data[[era5_var]][missing_flux_idx]), era5_var))

          # Ensure the predictions fill only the missing values in the new "_f" column
          merged_data[[base::paste0(flux_var, "_f")]][missing_flux_idx] <- predictions
        }
      }
    }

    if (rule == "automatic") {
      total_count <- base::nrow(merged_data)
      non_na_count <- base::sum(!base::is.na(merged_data[[flux_var]]))

      if ((non_na_count / total_count) >= 0.5) {
        # Remove rows with NA in either varname_FLUX or varname_ERA5
        complete_cases <- merged_data[!base::is.na(merged_data[[flux_var]]) & !base::is.na(merged_data[[era5_var]]), ]

        if (base::nrow(complete_cases) > 1) {
          formula_str <- base::paste(flux_var, "~", era5_var)
          base::message("Fitting linear model with formula: ", formula_str)

          lm_model <- stats::lm(as.formula(formula_str), data = complete_cases)

          # Only use model predictions to fill missing values in flux_var
          missing_flux_idx <- base::which(base::is.na(merged_data[[flux_var]]))  # Identify all missing flux_var entries

          if (base::length(missing_flux_idx) > 0) {
            # Predict missing flux values based on ERA5 data and fill them
            predictions <- stats::predict(lm_model,
                                          newdata = setNames(data.frame(merged_data[[era5_var]][missing_flux_idx]), era5_var))

            # Ensure the predictions fill only the missing values in the new "_f" column
            merged_data[[base::paste0(flux_var, "_f")]][missing_flux_idx] <- predictions
          }
        }
      } else {
        base::message("More than 50% missing in ", flux_var, ", replacing with ", era5_var)
        # If more than 50% of FLUX data is missing, replace the entire FLUX variable with ERA5
        merged_data[[base::paste0(flux_var, "_f")]] <- merged_data[[era5_var]]
      }
    }
  }

  return(merged_data)
}

