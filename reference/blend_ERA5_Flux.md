# Blend ERA5 and AmeriFlux Data

This function is used to blend data from AmeriFlux and data from ERA5,
ensuring they both have the same start and end timestamps. Please first
make sure to run the merge function
([`merge_ERA5_Flux()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/merge_ERA5_Flux.md))
first, because output of merge function will be used as input of this
blending function.

## Usage

``` r
blend_ERA5_Flux(
  merged_data = NULL,
  varname_FLUX = NULL,
  varname_ERA5 = NULL,
  blending_rule = NULL
)
```

## Arguments

- merged_data:

  (data.frame) A data frame that has a datetime stamp column named
  "time" with the format: "%Y-%m-%d %H:%M:%S". The time step of the
  "time" column is the same with that of AmeriFlux file. It also
  includes the columns of AmeriFlux and ERA5 data that were merged
  together.

- varname_FLUX:

  (character) A vector of variable names in AmeriFlux BASE data to be
  blended with ERA5 data.

- varname_ERA5:

  (character) A vector of variable names in ERA5 data to be blended with
  AmeriFlux BASE data.

- blending_rule:

  (character) A vector of blending rules to use. There are four types of
  blending rules that can be used to blend AmeriFlux and ERA5 variables:

  - "lm": Linear regression with slope. Fits a linear model with slope,
    FLUX ~ ERA5, then only fills missing values in FLUX with predicted
    values from ERA5.

  - "lm_no_intercept": Linear regression without slope. Fits a linear
    model without slope, FLUX ~ ERA5, then only fills missing values in
    FLUX with predicted values from ERA5.

  - "replace": Replace Ameriflux variable with ERA5 variable.

  - "automatic": Checks for non-missing FLUX values. If ≥50% present
    then uses "lm" approach. If \<50% present then fallback to
    "replace".

## Value

(data.frame) A data frame with the following characteristics:

- Time step of the "time" column is the same with that of AmeriFlux
  file.

- It also includes the columns of `varname_FLUX`, the columns of
  `varname_ERA5`.

- Variable column with the blending rule applied on it. Name of the
  blended column is similar to AmeriFlux column name but with addition
  of "\_f".

## Note

Please note that the length of `varname_FLUX` must be the same as the
length of `varname_ERA5`; at the same location, `varname_FLUX` and
`varname_ERA5` should refer to the same variable despite the fact that
AmeriFlux and ERA5 may use different names for the same variable. For
example, for incoming shortwave radiation, ERA5 uses "ssrd", but
AmeriFlux uses "SW_IN". Additionally, if you have multiple variables
like precipitation and soil temperature, you must specify a blending
rule for each one.

## Author

Ammara Talib and Junna Wang

## Examples

``` r
# Point to a folder containing ERA5 .nc files
site_folder <- system.file("extdata", "path_to_ERA5_download_folder", package = "ERA5Flux")
# Specify a site name
site_name <- "US_GL2"
# Create a temporary directory to export our output to
output_filepath <- tempdir()

# Convert NetCDF data to a CSV file
netcdf_to_csv(site_folder, output_filepath, site_name, full_year = FALSE)
#> No NetCDF files found in  

# Point to AmeriFlux CSV data
filename_FLUX <- system.file("extdata",
                             "example_unzipped_AmeriFlux_data",
                             "AMF_US-GL2_BASE-BADM_1-5",
                             "AMF_US-GL2_BASE_HH_1-5.csv",
                             package = "ERA5Flux")

# Point to ERA5 CSV data
filename_ERA5 <- list.files(output_filepath, pattern = "US_GL2", full.names = TRUE)

# List AmeriFlux variable(s) to be merged with ERA5
varname_FLUX <- c("SW_IN")
# List ERA5 variable(s) to be merged with AmeriFlux
varname_ERA5 <- c("ssrd")

# Run the merge function first, because its output will be used as input for this blending function
# Merge AmeriFlux and ERA5 data together
merged_data <- merge_ERA5_Flux(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#> Error in file(file, "rt"): invalid 'description' argument
head(merged_data)
#> Error: object 'merged_data' not found

# Specify the blending rule(s)
# If you have multiple variables, specify a rule for each variable
blending_rule <- c("replace")
# Blend AmeriFlux and ERA5 data together
merg_blend <- blend_ERA5_Flux(merged_data, varname_FLUX, varname_ERA5, blending_rule)
#> Error: object 'merged_data' not found
head(merg_blend)
#> Error: object 'merg_blend' not found
```
