#' @title Get AmeriFlux Site Metadata
#'
#' @description
#' This function is designed to build an AmeriFlux site metadata file. The site metadata file consists of site code, latitude, longitude, start date, end data, and variables needed.
#' When downloading AmeriFlux data, select sites, download data and "requested_files_manifest" file. Then extract all files to a data folder. Variables need to be added by the user.
#'
#' @param folder (character) Path to the folder containing extracted AmeriFlux data and "requested_files_manifest" file.
#'
#' @param selected_variables (character) A vector of variable names.
#'
#' @return (data.frame) A data frame containing the site metadata.
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
#' }
#'
#' @author David Reed
#'
get_site_metadata <- function(folder = NULL,
                              selected_variables = NULL){
  # Error out if no folder is provided
  if (base::is.null(folder)) stop("No folder path provided")

  # Error out if no variable is provided
  if (base::is.null(selected_variables)) stop("No variable provided")

  # Point to the "requested_files_manifest" file
  manifest.file <- base::list.files(folder, pattern = "requested_files_manifest")
  if(length(manifest.file) == 0){
    stop("'requested_files_manifest' file not found")
  }

  # Read it in
  fluxmanifest <- utils::read.csv(file.path(folder, manifest.file), skip = 3, header = TRUE)

  # Get the site codes
  site_codes <- base::unique(fluxmanifest$SITE_ID)

  # Proper initialization
  lat <- base::rep(NA, base::length(site_codes))
  lon <- base::rep(NA, base::length(site_codes))
  startdate <- base::rep(NA, base::length(site_codes))
  enddate <- base::rep(NA, base::length(site_codes))
  variables <- base::rep(NA, base::length(site_codes))

  # Hard coding in variables
  base::message("selected variables: ", base::paste(selected_variables, collapse = ", "))

  # Loop over all sites
  for(i in 1:length(site_codes)) {
    message("Now checking: ", site_codes[i])

    # Point to the site folder
    flux.folder <- base::dir(folder, pattern = site_codes[i])
    if(length(flux.folder) == 0){
      stop("AmeriFlux site folder for ", site_codes[i], " not found")
    }

    # Point to the BASE file
    flux.file <- base::list.files(path = file.path(folder, flux.folder), pattern = "BASE")
    if(length(flux.file) == 0){
      stop("BASE file not found")
    }

    # Point to the BIF file
    bif.file <- base::list.files(path = file.path(folder, flux.folder), pattern = "BIF")
    if(length(bif.file) == 0){
      stop("BIF file not found")
    }

    # Read in the BIF file
    flux.bif  <- readxl::read_excel(base::file.path(folder, flux.folder, bif.file))
    # Get the lat, lon
    lat[i] <- flux.bif$DATAVALUE[which(flux.bif$VARIABLE=="LOCATION_LAT")]
    lon[i] <- flux.bif$DATAVALUE[which(flux.bif$VARIABLE=="LOCATION_LONG")]

    # Read in the BASE file
    fluxdata <- readr::read_csv(base::file.path(folder, flux.folder, flux.file), skip = 2, col_select = 1)
    # Get the start, end dates
    startdate[i] <- fluxdata$TIMESTAMP_START[1]
    enddate[i] <- fluxdata$TIMESTAMP_START[base::length(fluxdata$TIMESTAMP_START)]

    # Save the user's selected variables
    variables[i] <- base::paste(selected_variables, collapse = ", ")
  }

  # Create the metadata dataframe
  df.sitemetadata <- base::data.frame(
    site_codes,
    lat,
    lon,
    startdate,
    enddate,
    variables
  )

  return(df.sitemetadata)
}
