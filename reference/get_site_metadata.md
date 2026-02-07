# Get AmeriFlux Site Metadata

This function is designed to build an AmeriFlux site metadata file. The
site metadata file consists of site code, latitude, longitude, start
date, end data, and variables needed. When downloading AmeriFlux data,
select sites, download data and "requested_files_manifest" file. Then
extract all files to a data folder. Variables need to be added by the
user.

## Usage

``` r
get_site_metadata(folder = NULL, selected_variables = NULL)
```

## Arguments

- folder:

  (character) Path to the folder containing extracted AmeriFlux data and
  "requested_files_manifest" file.

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
site_metadata <- get_site_metadata(folder = "path_to_data_folder",
                                   selected_variables = my_variables)
} # }
```
