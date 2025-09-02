#' @title Download ERA5 Data
#'
#' @description
#' This function uses the `ecmwfr` package to download ERA5 data for each site specified in the AmeriFlux site metadata dataframe. The temporal and geographical coverage of the downloaded data will match the AmeriFlux site metadata dataframe.
#'
#' @param my_token (character) A secret ECMWF token.
#' @param site_metadata (data.frame) A data frame that has the AmeriFlux site metadata. Create the metadata with `get_site_metadata()`.
#' @param mask (character) File path to the ERA5 land-sea mask. Get the mask with `get_land_sea_mask()`.
#' @param download_path (character) Path to the folder where the ERA5 data will get downloaded to.
#'
#' @note If you haven't done so already, you may need to accept the data license agreement first before you can download the data. Visit the Copernicus Climate Data Store User Profile page at https://cds.climate.copernicus.eu/profile to accept the appropriate license(s).
#'
#' @importFrom lubridate %m+%
#'
#' @return (character) Paths to the downloaded files.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Specify your variables
#' my_variables <- c("2m_temperature", "total_precipitation", "surface_solar_radiation_downwards")
#' # Create the AmeriFlux site metadata
#' site_metadata <- get_site_metadata(folder = "path_to_data_folder",
#'                                    selected_variables = my_variables)
#'
#' # Download the corresponding ERA5 data
#' download_ERA5(my_token = "my_ECMWF_token",
#'               site_metadata = site_metadata,
#'               mask = "path_to_ERA5_land_sea_mask",
#'               download_path = "path_to_ERA5_download_folder")
#' }
#'
#' @author David Reed
#'
download_ERA5 <- function(my_token = NULL,
                          site_metadata = NULL,
                          mask = NULL,
                          download_path = NULL){
  # Error out if no token is provided
  if (base::is.null(my_token)) stop("No ECMWF token provided")

  # Error out if no AmeriFlux site metadata is provided
  if (base::is.null(site_metadata)) stop("No AmeriFlux site metadata provided. If you need to create the metadata, run `get_site_metadata()`.")

  # Error out if no land-sea mask is provided
  if (base::is.null(mask)) stop("No land-sea mask provided, if you need to download it, run `get_land_sea_mask()`")

  # Error out if no download path is provided
  if (base::is.null(download_path)) stop("No download path provided")

  # Set token
  ecmwfr::wf_set_key(key = my_token)

  for(i in 1:nrow(site_metadata)){
    # Get the UTC offset for each site
    site_metadata$UTC_offset[i] <- utc_offset(lat = base::as.numeric(site_metadata$lat[i]),
                                                lon = base::as.numeric(site_metadata$lon[i]))
  }

  for(i in 1:nrow(site_metadata)){
    # Get the land proportion for each site
    land_cover <- get_land_proportion(nc_file = mask,
                                      lat = base::as.numeric(site_metadata$lat[i]),
                                      lon = base::as.numeric(site_metadata$lon[i]))


    base::print(base::paste("The proporation of land at site", site_metadata$site_codes[i], "is:", land_cover$lsm))
  }

  ####### start of API code

  ### start of site-by-site loop
  ### i is site
  for(i in 1:nrow(site_metadata)){

    ## building area parameter from metadata lat and lon values
    #area <- c(55, -130, 25, -70)
    area <- c(base::round(base::as.numeric(site_metadata$lat[i]), digits = 2),
              base::round(base::as.numeric(site_metadata$lon[i]), digits = 2)-.01,
              base::round(base::as.numeric(site_metadata$lat[i]), digits = 2)-.01,
              base::round(base::as.numeric(site_metadata$lon[i]), digits = 2))

    start_day <- base::as.Date(base::substr(site_metadata$startdate[i], 1, 8),"%Y%m%d") - 1
    end_day <- base::as.Date(base::substr(site_metadata$enddate[i], 1, 8),"%Y%m%d") + 1

    #num_years <- as.numeric(substr(site_metadata$enddate[i], 1, 4))-as.numeric(substr(site_metadata$startdate[i], 1, 4))

    loop_date <- base::as.Date(base::paste(lubridate::year(start_day), lubridate::month(start_day),"01", sep = ""), "%Y%m%d")

    while (loop_date < end_day) {
      #print(loop_date)

      date <- base::paste(
        lubridate::year(loop_date),
        "-",
        lubridate::month(loop_date),
        "-",
        lubridate::day(loop_date),
        "/",
        lubridate::year(loop_date%m+% months(1)-1),
        "-",
        lubridate::month(loop_date%m+% months(1)-1),
        "-",
        lubridate::day(loop_date%m+% months(1)-1),
        sep = "")

      ##building final file name
      #target <- "era5-demo.nc"
      target <- base::paste(
        "ERA5-",
        site_metadata$site_codes[i],
        '-',
        lubridate::year(loop_date),
        '-',
        lubridate::month(loop_date),
        ".nc",
        sep = ""
      )

      #### build request file for ERA API
      request <- base::list(
        dataset_short_name = "reanalysis-era5-land",
        product_type = "reanalysis",
        variable = base::unlist(base::strsplit(site_metadata$variables[i], split = ", ")),
        date = date,
        time = c("00:00", "01:00", "02:00",
                 "03:00", "04:00", "05:00",
                 "06:00", "07:00", "08:00",
                 "09:00", "10:00", "11:00",
                 "12:00", "13:00", "14:00",
                 "15:00", "16:00", "17:00",
                 "18:00", "19:00", "20:00",
                 "21:00", "22:00", "23:00"),
        data_format = "netcdf",
        download_format = "unarchived",
        area = area,
        target = target
      )

      ### third loop that re-tries API request if it fails

      while(!base::file.exists(base::file.path(download_path, target))){
        try(
          file <- ecmwfr::wf_request(
            request  = request, # the request
            transfer = TRUE, # download the file
            time_out = 36000,
            ##code for windows users
            path = download_path # store data in user-specified folder
          ), silent = TRUE)

      } ###end of API loop

      loop_date <- loop_date %m+% months(1)

    } ### end of month-by-month

  } ### end of site-by-site loop

}
