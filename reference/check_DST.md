# Check Daylight Saving Time

This function will check if a given time point is in Daylight Saving
Time (DST). If so, it will adjust the time to the standard (non-DST)
time.

## Usage

``` r
check_DST(lat = NULL, lon = NULL, timepoint = NULL)
```

## Arguments

- lat:

  (numeric) Latitude coordinate in decimal degrees.

- lon:

  (numeric) Longitude coordinate in decimal degrees.

- timepoint:

  (character) Time point in either %Y-%m-%d HH:MM:SS or %Y/%m/%d
  HH:MM:SS format.

## Value

(list) A list containing a boolean representing the DST status and the
standard time if DST is in effect.

## Examples

``` r
# This will get the current time
timepoint <- lubridate::now()
# Check whether the time is in DST at latitude 25.4, longitude -80.5 and get the standard time if so
is_DST <- check_DST(lat = 25.4, lon = -80.5, timepoint)
is_DST
#> $is_DST
#> [1] FALSE
#> 
#> $standard_time
#> [1] "2026-02-06 19:43:00 EST"
#> 
```
