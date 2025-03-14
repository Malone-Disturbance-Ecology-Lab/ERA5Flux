########################################
## this script is used to merge data from AmeriFlux and data from ERA5 by adding new columns to AmeriFlux file
## Authors: Ammara Talib and Junna Wang
## 3/13/2025
########################################
## need to discuss: filename_FLUX, zip file?
## how to know one variable is a vector or a value? the variable name part. 
## we assume ERA5 is hourly data, with the current time zone correction and full dates. 
## the last time step of ERA5. 

#########

merge_ERA5_FLUX <- function(filename_FLUX, filename_ERA5,
                            varname_FLUX, varname_ERA5,
                            blending_rules) {
  #
  if (length(filename_FLUX) > 1 | length(filename_ERA5) > 1) {
    stop('this function works for one site each time.')
  }
  #
  if (length(varname_FLUX) != length(varname_ERA5)) {
    stop('to-be-merged varname of FLUX should correspond to to-be-merged varname of ERA5')
  }  
  #
  # read amf
  data_BASE <- amf_read_base(filename_FLUX, parse_timestamp=TRUE, unzip = T)
  # set abnormal values (<=-9999) to NA
  data_BASE[data_BASE<=-9999] <- NA
  
  # read era5
  data_ERA5 <- read.csv(filename_ERA5)
  
  # check if variable names are in the data
  if (! varname_FLUX %in% colnames(data_BASE)) {
    stop('wrong varnames were given for FLUX data')
  }
  #
  if (! varname_ERA5 %in% colnames(data_ERA5)) {
    stop('wrong varnames were given for ERA5 data')
  }
  
  # find the Ameriflux time step
  dt <- as.numeric(difftime(ymd_hm(data_BASE$TIMESTAMP_END[2]), ymd_hm(data_BASE$TIMESTAMP_END[1]), units=c('hours')))
  
  # interpolate ERA5 to half hourly
  if (dt == 0.5) {
    data_ERA5_intp <- data.frame(time=seq(data_ERA5$time[1], data_ERA5$time[nrow(data_ERA5)], by = "30 min"))
    # this is related to variables. 
    
    
    
    
  }
  
  # merge the variables using different rules
  
  
  
  
  
}