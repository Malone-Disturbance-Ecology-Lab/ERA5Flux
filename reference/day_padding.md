# Pad Dates by 1 Day

This function is designed to pad 1 day for the beginning and ending
days. It will add 1 day to start and end dates for future time zone
offset issues.

## Usage

``` r
day_padding(start_day = NULL, end_day = NULL)
```

## Arguments

- start_day:

  (character) Start date in either %Y-%m-%d or %Y/%m/%d format.

- end_day:

  (character) End date in either %Y-%m-%d or %Y/%m/%d format.

## Value

(character) New start and end dates in either %Y-%m-%d or %Y/%m/%d
format, padded by 1 day each.

## Author

Boya ("Paul") Zhang

## Examples

``` r
# Pad starting and ending dates by 1 day
result <- day_padding("2024-01-01", "2025-12-31")
result
#> $start_day
#> [1] "2023-12-31"
#> 
#> $end_day
#> [1] "2026-01-01"
#> 
```
