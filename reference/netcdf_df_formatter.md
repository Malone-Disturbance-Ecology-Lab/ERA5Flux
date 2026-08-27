# NetCDF Reformatter

Reformats ERA5 .nc data into a data frame.

## Usage

``` r
netcdf_df_formatter(nc_file_path = NULL)
```

## Arguments

- nc_file_path:

  (character) File path to ERA5 NetCDF file.

## Value

(data.frame) Data frame of the following characteristics:

- Datetime stamp column named "time".

- UTC timezones converted to local time.

- SiteID is determined from lat and lon coordinates in df.sitemetadata.

- Time column formatted as yyyyMMddHHmm, time zone determined using
  coordinates.

- Variables names from ERA5 dataset maintained.

- ERA5 units converted to Ameriflux units:

  - Solar radiation (ssrd) from Jm-2 to Wm-2.

  - Air Temperature (t2m) from Kelvin to Celsius.

  - Total precipitation (tp) from meters to millimeters.

## Examples

``` r
# Point to a NetCDF file
nc_file_path <- system.file("extdata", "example_path_to_ERA5_download_folder",
                            "ERA5-US-GL2-2025-1.nc", package = "ERA5Flux")
# Reformat the NetCDF
result <- netcdf_df_formatter(nc_file_path)
head(result)
#>           time     ssrd
#> 1 202412311900 663.4275
#> 2 202412312000   0.0000
#> 3 202412312100   0.0000
#> 4 202412312200   0.0000
#> 5 202412312300   0.0000
#> 6 202501010000   0.0000
```
