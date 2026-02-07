# Get Land Proportion

This function is designed to return land proportion given a latitude and
longitude.

## Usage

``` r
get_land_proportion(nc_file = NULL, lat = NULL, lon = NULL)
```

## Arguments

- nc_file:

  (character) File path to the .nc file.

- lat:

  (numeric) Latitude coordinate in decimal degrees.

- lon:

  (numeric) Longitude coordinate in decimal degrees.

## Value

(data.frame) A data frame containing the land proportion.

## Note

In cycles of the ECMWF Integrated Forecasting System (IFS) from CY41R1
(introduced in May 2015) onwards, grid boxes where this parameter has a
value above 0.5 can be comprised of a mixture of land and inland water
but not ocean. Grid boxes with a value of 0.5 and below can only be
comprised of a water surface. In the latter case, the lake cover is used
to determine how much of the water surface is ocean or inland water.

In cycles of the IFS before CY41R1, grid boxes where this parameter has
a value above 0.5 can only be comprised of land and those grid boxes
with a value of 0.5 and below can only be comprised of ocean. In these
older model cycles, there is no differentiation between ocean and inland
water.

## Author

Boya ("Paul") Zhang

## Examples

``` r
if (FALSE) { # \dontrun{
land_proportion <- get_land_proportion("file_path_to_the_nc_file", 25.2, -80.3)
} # }
```
