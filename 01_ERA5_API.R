
######### working code for ERA5 API download


library(ecmwfr)
library(terra)









##### THIS IS DAVID'S KEY, PLEASE CHANGE!

wf_set_key("8938d21f-2336-42c4-8fe5-5783996193b0")




#day = c(
#  "01", "02", "03",
#  "04", "05", "06",
#  "07", "08", "09",
#  "10", "11", "12",
#  "13", "14", "15",
#  "16", "17", "18",
#  "19", "20", "21",
#  "22", "23", "24",
#  "25", "26", "27",
#  "28", "29", "30",
#  "31"),
#time = c("00:00", "01:00", "02:00",
#         "03:00", "04:00", "05:00",
#         "06:00", "07:00", "08:00",
#         "09:00", "10:00", "11:00",
#         "12:00", "13:00", "14:00",
#         "15:00", "16:00", "17:00",
#         "18:00", "19:00", "20:00",
#         "21:00", "22:00", "23:00"),






request <- list(
  dataset_short_name = "reanalysis-era5-land",
  product_type = "reanalysis",
  variable = c(
    "2m_temperature",
    "total_precipitation"),
  date = "2000-01-01/2000-01-04",
  time = c("00:00", "01:00"),
  data_format = "netcdf",
  download_format = "unarchived",
  area = c(55, -130, 25, -70),
  target = "era5-demo.nc"
)



file <- wf_request(
  request  = request,  # the request
  transfer = TRUE,     # download the file
  path     = "."       # store data in current working directory
)






r <- terra::rast(file)
terra::plot(r, main = "ERA-5 Reanalysis 2m Temperature")
maps::map("world", add = TRUE)

