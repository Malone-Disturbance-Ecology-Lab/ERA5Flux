
######### working code for ERA5 API download


library(ecmwfr)
library(terra)
library(lubridate)

rm(list=ls())

##### THIS IS DAVID'S KEY, PLEASE CHANGE!

wf_set_key("8938d21f-2336-42c4-8fe5-5783996193b0")

### call 01_lat_lon_UTC_offset

#source('~/ERA5_FLUX/utc_offset.R')
source('/Users/bz294/Documents/ERA5Flux/utc_offset.R')
for(i in 1:nrow(df.sitemetadata)){
  
  df.sitemetadata$UTC_offset[i] <- utc_offset(as.numeric(df.sitemetadata$lat[i]), as.numeric(df.sitemetadata$lon[i])) 
  
}

### call 01_land_sea_mask

#source('~/ERA5_FLUX/get_land_proportion.R')
source('/Users/bz294/Documents/ERA5Flux/get_land_proportion.R')
#nc_file <- "/Volumes/Malonelab/Research/ERA5_FLUX/Data/lsm_1279l4_0.1x0.1.grb_v4_unpack.nc"  # Your NetCDF file
nc_file <- "z:/Research/ERA5_FLUX/Data/lsm_1279l4_0.1x0.1.grb_v4_unpack.nc"   # Your NetCDF file


for(i in 1:nrow(df.sitemetadata)){

  land_cover <- get_land_proportion(nc_file, as.numeric(df.sitemetadata$lat[i]), as.numeric(df.sitemetadata$lon[i]))
  
  print(paste("The proporation of land at site",df.sitemetadata$site_codes[i],"is:",land_cover$lsm))
  
}

####### start of API code

### start of site-by-site loop
### i is site
for(i in 1:nrow(df.sitemetadata)){
  
  
  ## building area parameter from metadata lat and lon values
  #area = c(55, -130, 25, -70)
  area = c(round(as.numeric(df.sitemetadata$lat[i]), digits = 2),
           round(as.numeric(df.sitemetadata$lon[i]), digits = 2)-.01,
           round(as.numeric(df.sitemetadata$lat[i]), digits = 2)-.01,
           round(as.numeric(df.sitemetadata$lon[i]), digits = 2))
  
  
  
  

  start_day = as.Date(substr(df.sitemetadata$startdate[i], 1, 8),"%Y%m%d") - 1
  end_day = as.Date(substr(df.sitemetadata$enddate[i], 1, 8),"%Y%m%d") + 1
  
  #num_years = as.numeric(substr(df.sitemetadata$enddate[i], 1, 4))-as.numeric(substr(df.sitemetadata$startdate[i], 1, 4))
  
  
  
  loop_date = as.Date(paste(year(start_day),month(start_day),"01",sep = ""),"%Y%m%d")
  
  
  
  while ( loop_date < end_day  ) {
    #print(loop_date)
    
    
    date = paste(
      year(loop_date),
      "-",
      month(loop_date),
      "-",
      day(loop_date),
      "/",
      year(loop_date%m+% months(1)-1),
      "-",
      month(loop_date%m+% months(1)-1),
      "-",
      day(loop_date%m+% months(1)-1),
      sep = "")
    
    
    ##building final file name
    #target = "era5-demo.nc"
    target = paste(
      "ERA5-",
      df.sitemetadata$site_codes[i],
      '-',
      year(loop_date),
      '-',
      month(loop_date),
      ".nc",
      sep = ""
    )
    
    
    
    #### build request file for ERA API
    request <- list(
      dataset_short_name = "reanalysis-era5-land",
      product_type = "reanalysis",
      variable = unlist(strsplit(df.sitemetadata$variables[i], split = ", ")),
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

    
    while(!file.exists(paste("z:/Research/ERA5_FLUX/data_ERA5/",target,sep = ""))){
      try(
        file <- wf_request(
          request  = request,  # the request
          transfer = TRUE,     # download the file
          time_out = 36000,
          ##code for windows users
          path     = "z:/Research/ERA5_FLUX/data_ERA5"       # store data in ERA5 folder on server directory
          ##code for mac users
          #path     = "/Volumes/Malonelab/Research/ERA5_FLUX/data_ERA5"       # store data in ERA5 folder on server directory
        ), silent=TRUE)
      
    } ###end of API loop
    
    
    
    
    
    
    loop_date = loop_date %m+% months(1)
    
  } ### end of month-by-month
  
  
  
} ### end of site-by-site loop



    
    
    

  #   
  #   
  #   if (j==1) {
  #   date = paste(
  #     as.numeric(substr(df.sitemetadata$startdate[i], 1, 4)),
  #     "-",
  #     substr(df.sitemetadata$startdate[i], 5, 6),
  #     "-",
  #     substr(df.sitemetadata$startdate[i], 7, 8),
  #     "/",
  #     current_year+1,
  #     "-",
  #     "12",
  #     "-",
  #     "31",
  #     sep = "")
  #   }
  #   else if (j==num_years) {
  #     date = paste(
  #       current_year,
  #       "-",
  #       "01",
  #       "-",
  #       "01",
  #       "/",
  #       current_year+1,
  #       "-",
  #       substr(df.sitemetadata$enddate[i], 5, 6),
  #       "-",
  #       substr(df.sitemetadata$enddate[i], 7, 8),
  #       sep = "")
  #   }
  #   else {
  #     date = paste(
  #       current_year,
  #       "-",
  #       "01",
  #       "-",
  #       "01",
  #       "/",
  #       current_year+1,
  #       "-",
  #       "12",
  #       "-",
  #       "31",
  #       sep = "")
  #   }
  # 
  # } #### end of date loop

  
  
  ### building a list of variable names
  #variable = c(
  #  "2m_temperature",
  #  "total_precipitation"),
  #variable = unlist(strsplit(df.sitemetadata$variables[i], split = ", "))
  ### varaible name is pulled from sitemetadata file
  
    
  
  
  
  
  
  
  
  









### ploting data to check
r <- terra::rast(file)
terra::plot(r, main = "ERA-5 Reanalysis 2m Temperature")
maps::map("world", add = TRUE)

