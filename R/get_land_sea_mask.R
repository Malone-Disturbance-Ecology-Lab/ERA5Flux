#' @title Get Land-Sea Mask from ERA5
#'
#' @description
#' This function downloads the netCDF land-sea mask from ERA5. The mask is needed in order to run `download_ERA5()`. The mask can be found online here:
#' https://confluence.ecmwf.int/pages/viewpage.action?pageId=140385202#ERA5Land:datadocumentation-parameterlistingParameterlistings.
#'
#' @param file_name (character) Name of the land-sea mask. The default name is "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc".
#' @param download_path (character) Path to an existing folder where the land-sea mask will get downloaded to. The default location is the current working directory.
#'
#' @return Path to the downloaded land-sea mask (invisibly).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' get_land_sea_mask()
#' }
#'
get_land_sea_mask <- function(file_name = "lsm_1279l4_0.1x0.1.grb_v4_unpack.nc",
                              download_path = getwd()){
  # Specify the URL of the required land-sea mask
  data_url <- "https://confluence.ecmwf.int/download/attachments/140385202/lsm_1279l4_0.1x0.1.grb_v4_unpack.nc?version=1&modificationDate=1591983422208&api=v2&download=true"

  # Download the file
  curl::curl_download(url = data_url, destfile = file.path(download_path, file_name), quiet = F)
}
