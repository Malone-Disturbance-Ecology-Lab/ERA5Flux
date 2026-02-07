# Merge ERA5 and AmeriFlux Data

This function is used to merge data from AmeriFlux and data from ERA5,
ensuring they both have the same start and end timestamps.

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

  (character) The file path to a CSV file of meterological data
  downloaded from ERA5
  https://cds.climate.copernicus.eu/datasets/reanalysis-era5-single-levels?tab=overview.
  Please note that the original ERA5 files are in .nc format. You may
  want to convert these files into CSV format using the function
  [`netcdf_to_csv()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/netcdf_to_csv.md).

- varname_FLUX:

  (character) A vector of variable names in AmeriFlux BASE data to be
  merged with ERA5 data.

- varname_ERA5:

  (character) A vector of variable names in ERA5 data to be merged with
  AmeriFlux BASE data.

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
AmeriFlux and ERA5 may use different names for the same variable. For
example, for incoming shortwave radiation, ERA5 uses "ssrd", but
AmeriFlux uses "SW_IN".

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

# Merge AmeriFlux and ERA5 data together
merged_data <- merge_ERA5_Flux(filename_FLUX, filename_ERA5, varname_FLUX, varname_ERA5)
#> Error in file(file, "rt"): invalid 'description' argument
head(merged_data)
#> Error: object 'merged_data' not found
```
