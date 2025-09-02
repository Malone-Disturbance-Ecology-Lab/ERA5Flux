#' @title Get Land-Sea Mask from ERA5
#'
#' @description
#' This function downloads the netCDF land-sea mask from ERA5. The mask is needed in order to run `download_ERA5()`. The mask can be found online here:
#' https://confluence.ecmwf.int/pages/viewpage.action?pageId=140385202#ERA5Land:datadocumentation-parameterlistingParameterlistings.
#' If more than 120 seconds is needed to download the file, adjust the `timeout` parameter accordingly.
#'
#' @param download_path (character) Path to the folder where the land-sea mask will get downloaded to. The default location is the current working directory.
#' @param timeout (numeric) Number of seconds until the download times out. Default is 120 seconds but can be set higher to allow for more time to download.
#'
#' @return (integer) An integer code where 0 = success and non-zero = failure to download.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_land_sea_mask()
#' }
#'
get_land_sea_mask <- function(download_path = "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc",
                              timeout = 120){
  # Set the download timeout
  # Default is 120 seconds but can be set for longer to allow sufficient time to download the file
  withr::local_options(list(timeout = timeout))

  # Specify the URL of the required land-sea mask
  data_url <- "https://confluence.ecmwf.int/download/attachments/140385202/lsm_1279l4_0.1x0.1.grb_v4_unpack.nc?version=1&modificationDate=1591983422208&api=v2&download=true"

  # Download the file
  utils::download.file(url = data_url, destfile = download_path)
}
