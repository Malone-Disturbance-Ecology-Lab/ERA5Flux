# Get Land-Sea Mask from ERA5

This function downloads the netCDF land-sea mask from ERA5. The mask is
needed in order to run
[`download_ERA5()`](https://malone-disturbance-ecology-lab.github.io/ERA5Flux/reference/download_ERA5.md).
The mask can be found online here:
https://confluence.ecmwf.int/pages/viewpage.action?pageId=140385202#ERA5Land:datadocumentation-parameterlistingParameterlistings.

## Usage

``` r
get_land_sea_mask(
  file_name = "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc",
  download_path = getwd()
)
```

## Arguments

- file_name:

  (character) Name of the land-sea mask. The default name is
  "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc".

- download_path:

  (character) Path to an existing folder where the land-sea mask will
  get downloaded to. The default location is the current working
  directory.

## Value

Path to the downloaded land-sea mask (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
get_land_sea_mask()
} # }
```
