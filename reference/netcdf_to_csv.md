# Export NetCDF to CSV

Takes a directory of ERA5 .nc data as an argument and exports the data
in CSV format. This function grabs each NetCDF file and runs
[`netcdf_df_formatter()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/netcdf_df_formatter.md)
on it. It builds a list of variables across all data frames in the
folder and joins data by time, with an option to filter to return only
full years of data.

## Usage

``` r
netcdf_to_csv(
  site_folder = NULL,
  output_filepath = NULL,
  site_name = NULL,
  site_lat = NULL,
  site_lon = NULL,
  full_year = FALSE
)
```

## Arguments

- site_folder:

  (character) A folder for one site with NetCDF data. The NetCDF files
  can be of different variables and of different years so long as it is
  for one site.

- output_filepath:

  (character) File path to where the output CSV should be written.

- site_name:

  (character) Name of the site that will be concatenated onto CSV file
  name (e.g. US_GL2).

- site_lat:

  (numeric) Latitude coordinate of site in decimal degrees.

- site_lon:

  (numeric) Longitude coordinate of site in decimal degrees.

- full_year:

  (bool) If TRUE, filter to include only complete years, such that the
  data will start with the first hour of year and end with the last hour
  of a year. Otherwise, return data as-is. The default is FALSE.

## Value

.csv file of NetCDF data within the site folder. The .csv file has the
file name format: siteID_startYear_endYear_variableName.csv. For
example, US_Ho1_2001_2020_tp_t2m.csv. Each CSV file starts from the
first hour of a year (e.g., 2001-01-01 00:00) and ends with the last
hour of a year (e.g., 2020-12-31 23:00) if full_year == TRUE.

## Examples

``` r
# Point to a folder containing ERA5 .nc files
site_folder <- system.file("extdata", "example_path_to_ERA5_download_folder", package = "ERA5Flux")
# Create a temporary directory to export our output to
output_filepath <- tempdir()

# Specify a site name
site_name <- "US_GL2"
# Specify the site latitude and longitude coordinates
site_lat <- 46.7167
site_lon <- -87.4

# Convert NetCDF data to a CSV file
netcdf_to_csv(site_folder, output_filepath, site_name, site_lat, site_lon, full_year = FALSE)
#> Saved: US_GL2_2024_2025_ssrd.csv 

# Read the CSV back in
data <- read.csv(list.files(output_filepath, pattern = "US_GL2", full.names = TRUE))
head(data)
#>           time    ssrd
#> 1 202411301900 1201.93
#> 2 202411302000    0.00
#> 3 202411302100    0.00
#> 4 202411302200    0.00
#> 5 202411302300    0.00
#> 6 202412010000    0.00
```
