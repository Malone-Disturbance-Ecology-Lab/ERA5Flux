# Export NetCDF to CSV

Takes a directory of ERA5 .nc data as an argument and exports the data
in CSV format. This function grabs each NetCDF file and runs
[`netcdf_df_formatter()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/netcdf_df_formatter.md)
on it. It builds a list of variables across all data frames in the
folder and joins data by time, filtering to return only full years of
data.

## Usage

``` r
netcdf_to_csv(
  site_folder = NULL,
  output_filepath = NULL,
  site_name = NULL,
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

- full_year:

  (bool) Filter to include only complete years, such that the data will
  star with the first hour of year and ends with the last hour of a
  year. Otherwise, return data as is.

## Value

.csv file of NetCDF data within the site folder. The .csv file has the
file name format: siteID_startYear_endYear_variableName.csv. For
example, US-Ho1_2001_2020_tp_t2m.csv. SiteID is determined from lat and
lon coordinates in df.sitemetadata. Each CSV file starts from the first
hour of a year (e.g., 2000-01-01 00:00) and ends with the last hour of a
year (e.g., 2020-12-31 23:00) if full_year == TRUE.

## Examples

``` r
# Point to a folder containing ERA5 .nc files
site_folder <- system.file("extdata", "example_path_to_ERA5_download_folder", package = "ERA5Flux")
# Specify a site name
site_name <- "US_GL2"
# Create a temporary directory to export our output to
output_filepath <- tempdir()

# Convert NetCDF data to a CSV file
netcdf_to_csv(site_folder, output_filepath, site_name, full_year = FALSE)
#> Saved: US_GL2_2024_2025_ssrd.csv 

# Read the CSV back in
data <- read.csv(list.files(output_filepath, pattern = "US_GL2", full.names = TRUE))
head(data)
#>           time     ssrd
#> 1 202412311900 663.4275
#> 2 202412312000   0.0000
#> 3 202412312100   0.0000
#> 4 202412312200   0.0000
#> 5 202412312300   0.0000
#> 6 202501010000   0.0000
```
