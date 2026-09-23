# Get AmeriFlux Site Metadata

This function is designed to build an AmeriFlux site metadata data
frame. The data frame consists of site code, latitude, longitude, start
date, end date, and ERA5-Land variables needed. This data frame will be
used to create the ERA5-Land download request. To get started with this
metadata function, you must have AmeriFlux data downloaded already. When
downloading AmeriFlux data, select sites, download data and the
"requested_files_manifest" text file. Then extract all files to a data
folder, where the extracted data for each site has its own respective
subfolder. ERA5-Land variables need to be added by the user. Please see
the vignette for more help.

## Usage

``` r
get_site_metadata(folder = NULL, selected_variables = NULL)
```

## Arguments

- folder:

  (character) Path to the folder containing extracted AmeriFlux data and
  "requested_files_manifest" text file.

- selected_variables:

  (character) A vector of variable names. The possible options are:
  `2m_temperature`, `total_precipitation`, and
  `surface_solar_radiation_downwards`.

## Value

(data.frame) A data frame containing the site metadata.

## Author

David Reed

## Examples

``` r
# Specify the ERA5-Land variables you want to get
# Choose any combination from:
# 2m_temperature, total_precipitation, and surface_solar_radiation_downwards
my_variables <- c("surface_solar_radiation_downwards")

# Point to the folder containing the unzipped site folders and requested files manifest
# For the purposes of this example, an example data folder is used
# Please point to your own existing folder for your own workflow
my_AmeriFlux_folder <- system.file("extdata", "example_AmeriFlux", package = "ERA5Flux")

# Create the AmeriFlux site metadata
my_site_metadata <- get_site_metadata(folder = my_AmeriFlux_folder,
                                   selected_variables = my_variables)
#> selected variables: surface_solar_radiation_downwards
#> Now checking: US-GL2
#> Rows: 2832 Columns: 1
#> ── Column specification ────────────────────────────────────────────────────────
#> Delimiter: ","
#> dbl (1): TIMESTAMP_START
#> 
#> ℹ Use `spec()` to retrieve the full column specification for this data.
#> ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

my_site_metadata
#>   site_codes     lat      lon   startdate      enddate
#> 1     US-GL2 46.7167 -87.4000 2.02502e+11 202503312330
#>                           variables
#> 1 surface_solar_radiation_downwards
```
