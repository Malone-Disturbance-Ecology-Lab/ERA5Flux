# Download ERA5-Land Data

This function uses the `ecmwfr` package to download ERA5-Land data for
each site specified in the AmeriFlux site metadata data frame. The
temporal and geographical coverage of the downloaded data will match the
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

  (character) File path to the ERA5-Land land-sea mask. Get the mask
  with
  [`get_land_sea_mask()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/get_land_sea_mask.md).

- download_path:

  (character) Path to the folder where the ERA5-Land data will get
  downloaded to.

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

# Paste your own ECMWF API key
# You can generate your own key by creating an account at the Copernicus Climate Data Store
# Please see the vignette for more info
my_key <- "my_own_ECMWF_key"

# \donttest{
# Download the land-sea mask with get_land_sea_mask() if you haven't done so already
# Create a temporary directory to download to
temp_path <- tempdir()
# Download the land-sea mask
get_land_sea_mask(file_name = "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc",
                  download_path = temp_path)

# Set the path to your land-sea mask
my_path_to_mask <- file.path(temp_path, "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc")
# }

# Point to the folder where you want the ERA5-Land data to download to
# For the purposes of this example, a temporary directory is used
# Please point to your own existing folder for your own workflow
my_ERA5_download_path <- tempdir()

if (FALSE) { # \dontrun{
# Download the corresponding ERA5-Land data
download_ERA5(my_key = my_key,
              site_metadata = my_site_metadata,
              mask = my_path_to_mask,
              download_path = my_ERA5_download_path)
} # }
```
