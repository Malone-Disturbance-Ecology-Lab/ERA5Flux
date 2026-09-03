# Get AmeriFlux Site Metadata

This function is designed to build an AmeriFlux site metadata data
frame. The data frame consists of site code, latitude, longitude, start
date, end date, and ERA5 variables needed. This data frame will be used
to create the ERA5 download request. To get started with this metadata
function, you must have AmeriFlux data downloaded already. When
downloading AmeriFlux data, select sites, download data and the
"requested_files_manifest" text file. Then extract all files to a data
folder, where the extracted data for each site has its own respective
subfolder. ERA5 variables need to be added by the user. Please see the
vignette for more help.

## Usage

``` r
get_site_metadata(folder = NULL, selected_variables = NULL)
```

## Arguments

- folder:

  (character) Path to the folder containing extracted AmeriFlux data and
  "requested_files_manifest" text file.

- selected_variables:

  (character) A vector of variable names.

## Value

(data.frame) A data frame containing the site metadata.

## Author

David Reed

## Examples

``` r
if (FALSE) { # \dontrun{
# Specify your variables
my_variables <- c("2m_temperature", "total_precipitation", "surface_solar_radiation_downwards")
# Create the AmeriFlux site metadata
site_metadata <- get_site_metadata(folder = "my_own_path_to_AmeriFlux_folder",
                                   selected_variables = my_variables)
} # }
```
