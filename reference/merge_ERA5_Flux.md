# Merge ERA5-Land and AmeriFlux Data

This function is used to merge data from AmeriFlux and data from
ERA5-Land, ensuring they both have the same start and end timestamps.

## Usage

``` r
merge_ERA5_Flux(
  filename_FLUX = NULL,
  filename_ERA5 = NULL,
  varname_FLUX = NULL,
  varname_ERA5 = NULL
)
```

## Arguments

- filename_FLUX:

  (character) The file path to a CSV file of AmeriFlux BASE data
  downloaded from https://ameriflux.lbl.gov/.

- filename_ERA5:

  (character) The file path to a CSV file of ERA5-Land meterological
  data downloaded from
  https://cds.climate.copernicus.eu/datasets/reanalysis-era5-land.
  Please note that the original ERA5-Land files are in .nc format. You
  may want to convert these files into CSV format using the function
  [`netcdf_to_csv()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/netcdf_to_csv.md).

- varname_FLUX:

  (character) A vector of variable names in AmeriFlux BASE data to be
  merged with ERA5-Land data.

- varname_ERA5:

  (character) A vector of variable names in ERA5-Land data to be merged
  with AmeriFlux BASE data.

## Value

(data.frame) A data frame with the following characteristics:

- Datetime stamp column named "time" with the format: "%Y-%m-%d
  %H:%M:%S".

- Time step of the "time" column is the same with that of AmeriFlux
  file.

- It also includes the columns of `varname_FLUX`, the columns of
  `varname_ERA5`.

## Note

Please note that the length of `varname_FLUX` must be the same as the
length of `varname_ERA5`; at the same location, `varname_FLUX` and
`varname_ERA5` should refer to the same variable despite the fact that
AmeriFlux and ERA5-Land may use different names for the same variable.
For example, for incoming shortwave radiation, ERA5-Land uses "ssrd",
but AmeriFlux uses "SW_IN".

## Author

Ammara Talib and Junna Wang

## Examples

``` r
# Point to AmeriFlux CSV data
filename_FLUX <- system.file("extdata",
                             "example_AmeriFlux",
                             "AMF_US-GL2_BASE-BADM_2-5",
                             "AMF_US-GL2_BASE_HH_2-5.csv",
                             package = "ERA5Flux")

# Point to ERA5-Land CSV data
filename_ERA5 <- system.file("extdata",
                             "example_processed_ERA5",
                             "US_GL2_2024_2025_ssrd.csv",
                             package = "ERA5Flux")

# List AmeriFlux variable(s) to be merged with ERA5-Land
varname_FLUX <- c("SW_IN")
# List ERA5-Land variable(s) to be merged with AmeriFlux
varname_ERA5 <- c("ssrd")

# Merge AmeriFlux and ERA5-Land data together
merged_data <- merge_ERA5_Flux(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
head(merged_data)
#>                  time   ssrd SW_IN
#> 1 2024-12-31 19:00:00 670.36    NA
#> 2 2024-12-31 19:30:00 335.18    NA
#> 3 2024-12-31 20:00:00   0.00    NA
#> 4 2024-12-31 20:30:00   0.00    NA
#> 5 2024-12-31 21:00:00   0.00    NA
#> 6 2024-12-31 21:30:00   0.00    NA
```
