##' this function is designed build a site meta data file 
##' 
##' site metadata file consists of site code, lat, lon, start date, end data, varibles needed
##' 
##' NOTE FOR USER: when downloading AmeriFlux data, select sites, download data and requested_files_manifest file
##'                extract all files to data folder
##'                variables need to be added by user

##' @author David Reed
##' 


library(readxl)
library(tidyverse)



##
rm(list=ls())

## code for mac machines with server mapped to Z drive
setwd('/Volumes/Malonelab/Research/ERA5_FLUX/data_flux')
## code for windows machines with server mapped to Z drive
#setwd('z:/Research/ERA5_FLUX/data_flux')


manifest.file <- list.files( pattern="requested_files_manifest")

fluxmanifest  <- read.csv(paste(manifest.file, sep=""), skip = 3, header = TRUE)

site_codes <- unique(fluxmanifest$SITE_ID)

# Proper initialization
lat <- rep(NA, length(site_codes))
lon <- rep(NA, length(site_codes))
startdate <- rep(NA, length(site_codes))
enddate <- rep(NA, length(site_codes))
variables <- rep(NA, length(site_codes))

# Hard coding in variables
variableselect <- c("2m_temperature", "total_precipitation", "surface_solar_radiation_downwards")
print("variables selected:")
print(paste(variableselect, collapse = ", "))

# Loop over all sites
for(i in 1:length(site_codes)) {
  flux.folder <- dir(".", pattern= site_codes[i])
  flux.file <- list.files(path=paste0(flux.folder, '/'), pattern="BASE")
  bif.file <- list.files(path=paste0(flux.folder, '/'), pattern="BIF")
  
  flux.bif  <- read_excel(paste0(flux.folder,'/',bif.file))
  lat[i] <- flux.bif$DATAVALUE[which(flux.bif$VARIABLE=="LOCATION_LAT")]
  lon[i] <- flux.bif$DATAVALUE[which(flux.bif$VARIABLE=="LOCATION_LONG")]
  
  fluxdata <- read_csv(paste0(flux.folder,'/',flux.file), skip = 2, col_select = 1)
  startdate[i] <- fluxdata$TIMESTAMP_START[1]
  enddate[i] <- fluxdata$TIMESTAMP_START[length(fluxdata$TIMESTAMP_START)]
  
  variables[i] <- paste(variableselect, collapse = ", ")
}

# Create the metadata dataframe
df.sitemetadata <- data.frame(
  site_codes,
  lat,
  lon,
  startdate,
  enddate,
  variables
)







df.sitemetadata

