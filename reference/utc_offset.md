# Coordinated Universal Time (UTC) Offset

Offset is the difference between UTC and local time without considering
Daylight Saving Time. This function will produce an hour offset number
converting local to UTC.

## Usage

``` r
utc_offset(lat = NULL, lon = NULL)
```

## Arguments

- lat:

  (numeric) Latitude coordinate in decimal degrees.

- lon:

  (numeric) Longitude coordinate in decimal degrees.

## Value

(numeric) The UTC offset.

## Examples

``` r
# Get the UTC offset at latitude 25.4, longitude -80.5
offset <- utc_offset(lat = 25.4, lon = -80.5)
#> [1] -5
```
