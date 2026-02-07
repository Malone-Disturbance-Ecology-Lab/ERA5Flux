# Date Conversion

This function will produce a converted time, either UTC -\> local, or
local -\> UTC.

## Usage

``` r
date_conversion(lat = NULL, lon = NULL, time = NULL, flag = NULL)
```

## Arguments

- lat:

  (numeric) Latitude coordinate in decimal degrees.

- lon:

  (numeric) Longitude coordinate in decimal degrees.

- time:

  (character) Time in %Y-%m-%d %H:%M:%S format.

- flag:

  (numeric) Set flag to 0 for local to UTC, set flag to 1 for UTC to
  local.

## Value

A POSIXct object.

## Note

IT TAKES INTO ACCOUNT Daylight Saving Time!!

## Author

Boya ("Paul") Zhang

## Examples

``` r
# Convert local to UTC
utc_result_winter <- date_conversion(25.2, -80.4, "2018-01-16 22:02:37", 0)
#> [1] "America/New_York"
utc_result_winter
#> [1] "2018-01-16 22:02:37 UTC"

# Convert UTC to local
local_result <- date_conversion(25.2, -80.4, "2018-01-16 22:02:37", 1)
#> [1] "America/New_York"
local_result
#> [1] "2018-01-16 17:02:37 EST"
```
