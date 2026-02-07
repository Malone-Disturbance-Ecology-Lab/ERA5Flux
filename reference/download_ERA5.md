# Download ERA5 Data

This function uses the `ecmwfr` package to download ERA5 data for each
site specified in the AmeriFlux site metadata data frame. The temporal
and geographical coverage of the downloaded data will match the
AmeriFlux site metadata data frame.

## Usage

``` r
download_ERA5(
  my_key = NULL,
  site_metadata = NULL,
  mask = NULL,
  download_path = NULL
)
```

## Arguments

- my_key:

  (character) A secret ECMWF API key.

- site_metadata:

  (data.frame) A data frame that has the AmeriFlux site metadata. Create
  the metadata with
  [`get_site_metadata()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/get_site_metadata.md).

- mask:

  (character) File path to the ERA5 land-sea mask. Get the mask with
  [`get_land_sea_mask()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/get_land_sea_mask.md).

- download_path:

  (character) Path to the folder where the ERA5 data will get downloaded
  to.

## Value

(character) Paths to the downloaded files.

## Note

If you haven't done so already, you may need to accept the data license
agreement first before you can download the data. Visit the Copernicus
Climate Data Store User Profile page at
https://cds.climate.copernicus.eu/profile to accept the appropriate
license(s). `download_ERA5()` also requires a valid Climate Data Store
API key. When you're logged into the [Copernicus Climate Data
Store](https://cds.climate.copernicus.eu/), you can grab your API key by
clicking on your name for your account in the top right corner,
scrolling down to the "API key" section, and copying the API key.

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

# Download the corresponding ERA5 data
download_ERA5(my_key = "my_own_ECMWF_key",
              site_metadata = site_metadata,
              mask = "path_to_ERA5_land_sea_mask",
              download_path = "path_to_ERA5_download_folder")
} # }
```
