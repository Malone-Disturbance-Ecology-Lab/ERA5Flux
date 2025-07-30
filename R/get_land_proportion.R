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
#' \dontrun{
#' land_proportion <- get_land_proportion("file_path_to_the_nc_file", 25.2, -80.3)
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
  #print(land_value)
  return(land_value)
}
