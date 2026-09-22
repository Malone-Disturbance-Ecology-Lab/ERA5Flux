#' @title Get Land Proportion
#'
#' @description
#' This function is designed to return land proportion given a latitude and longitude.
#'
#' @param nc_file (character) File path to the .nc file.
#' @param lat (numeric) Latitude coordinate in decimal degrees.
#' @param lon (numeric) Longitude coordinate in decimal degrees.
#'
#' @return (data.frame) A data frame containing the land proportion.
#'
#' @export
#'
#' @examples
#' \donttest{
#' # Create a temporary directory to download to
#' temp_path <- tempdir()
#' # Download the land-sea mask
#' get_land_sea_mask(file_name = "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc",
#'                   download_path = temp_path)
#'
#' # Get land proportion for a given latitude and longitude
#' get_land_proportion(nc_file = file.path(temp_path, "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc"),
#'                     lat = 25.2,
#'                     lon = -80.3)
#' }
#'
#' @note In cycles of the ECMWF Integrated Forecasting System (IFS) from CY41R1 (introduced in May 2015) onwards, grid boxes where this parameter has a value above 0.5 can be comprised of a mixture of land and inland water but not ocean. Grid boxes with a value of 0.5 and below can only be comprised of a water surface. In the latter case, the lake cover is used to determine how much of the water surface is ocean or inland water.
#' @note In cycles of the IFS before CY41R1, grid boxes where this parameter has a value above 0.5 can only be comprised of land and those grid boxes with a value of 0.5 and below can only be comprised of ocean. In these older model cycles, there is no differentiation between ocean and inland water.
#'
#' @author Boya ("Paul") Zhang
#'
get_land_proportion <- function(nc_file = NULL,
                                lat = NULL,
                                lon = NULL) {
  # Error out if no file path is provided
  if (base::is.null(nc_file)) stop("No file path provided")

  # Error out if no lat is provided
  if (base::is.null(lat)) stop("No latitude provided")

  # Error out if no lon is provided
  if (base::is.null(lon)) stop("No longitude provided")

  # Error out if netCDF file path is not a character string
  if (!base::is.character(nc_file)) stop("netCDF file path must be a character string")

  # Error out if latitude is not numeric
  if (!base::is.numeric(lat)) stop("Latitude must be numeric")

  # Error out if longitude is not numeric
  if (!base::is.numeric(lon)) stop("Longitude must be numeric")

  if (lon < 0) {
    lon <- lon + 360
  }
  lat_nearest <- base::round(lat * 10) / 10
  lon_nearest <- base::round(lon * 10) / 10

  land_sea_mask <- terra::rast(nc_file)
  if (base::is.null(land_sea_mask)) {
    stop("Error: Failed to read the NetCDF file.")
  }
  land_value <- terra::extract(land_sea_mask, base::cbind(lon_nearest, lat_nearest))

  return(land_value)
}
