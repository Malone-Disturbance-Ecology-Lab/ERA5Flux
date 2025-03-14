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

setwd('/Volumes/Malonelab/Research/ERA5_FLUX/data_flux')
## code for windows machines with server mapped to Z drive
#setwd('z:/Research/ERA5_FLUX/data_flux')


manifest.file <- list.files( pattern="requested_files_manifest")

fluxmanifest  <- read.csv(paste(manifest.file, sep=""), skip = 3, header = TRUE)


site_codes <-unique(fluxmanifest$SITE_ID)
lat <- NaN
lon <- NaN
startdate <- NaN
enddata <- NaN

## need to make loop for all sites
for(i in 1:length(site_codes)){
  
  #print(site_codes[i]) 

  
  flux.folder <- dir(".", pattern= site_codes[1])
  flux.file <- list.files(path=paste(flux.folder,'/', sep=""), pattern="BASE")
  bif.file <- list.files(path=paste(flux.folder,'/', sep=""), pattern="BIF")
  
  
  flux.bif  <- read_excel(paste(flux.folder,'/',bif.file, sep=""))
  
  
  
  
  lat[i] <- flux.bif$DATAVALUE[which(flux.bif$VARIABLE=="LOCATION_LAT")]
  lon[i]  <- flux.bif$DATAVALUE[which(flux.bif$VARIABLE=="LOCATION_LONG")]
  
  
  
  
  
  fluxdata <- read_csv(paste(flux.folder,'/',flux.file, sep=""), skip = 2, col_select =  1) 
  
  startdate[i] <- fluxdata$TIMESTAMP_START[1]
  enddata[i] <- fluxdata$TIMESTAMP_START[length(fluxdata$TIMESTAMP_START)]
  
  
  rm( flux.folder, flux.file, flux.bif , fluxdata)


}

rm (fluxmanifest)




df.sitemetadata <- data.frame(
  site_codes,
  lat,
  lon,
  startdate,
  enddata
)



