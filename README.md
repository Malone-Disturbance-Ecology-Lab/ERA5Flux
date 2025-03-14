# ERA5_FLUX

The primary objective of this repo is to improve the utility of ERA5 data at flux site locations. 

Scripts are organized into the following groups
# 1. create df.sitemetadata file 00_sitemetadata
- df that contains site meta data (site code, lat, lon, start date, end data, varibles needed)
# 2. pre-Download for Files _01
- 01_start_end_time_padding (add 1 day to start and end dates for future time zone offset issues)
- 01_lat_lon_UTC_offset (add UTC offest to df.sitemetadata)
- 01_point_sample_check (pull land-sea_mask for one day)
- 01_ERA5_API (use ecmwfr pacakge with df.sitemetadata)
  
# ***DATA is Downloaded***

# 3. Data Processing for ERA5 _02
 notes for sam. 
- please arrange all the data including multiple variables and multiple years about one site into a CSV file, with the file name format: siteID_startYear_endYear_variableName.csv For example, US-Ho1_2001_2020_tp_t2m.csv
- please name ERA data timestamp column (valid_time) as "time"
- please use the variable name from ERA5 file to name the variable name
- please find the siteID for each data based on longitude and latitude in the nc file and metadata from step 1. 
- please provide the data in same units as ameriflux data. Here are the desired unites: solar radiation(ssrd) in wm-2, air temp (t2m) in celsius, precip in mm
- please convert the time from UTC timezone to local timezone (no daylight saving). You can use the function in the repo from step 1. 
- please gap-fill the first few rows if the time is shifted afterward, or gap-fill the last few rows if the time is shifted ahead. Please ensure that each csv file starts from the first hour of a year (e.g., 2000-01-01 00:00) and ends with the last hour of a year (e.g., 2020-12-31 23:00). 
- when outputting csv files, please format the time column (that include both date and time) as numbers such as 202001010000  so without any slashes. 

# 4. Flux Data Merging_03
- one function titled Merge_ERA5_FLUX
  - input variables (character): filename_FLUX, filename_ERA5
  - input variables (vector of character): varname_FLUX, varname_ERA5
  - input variables (vector of character): blending_rules
  - output variables: adding new columns to the FLUX file
- requirement of these input variables
  - varname_FLUX and varname_ERA5 should have the same length. These names of the same row should be matched.
  - blending_rules should have the same length with varname_FLUX and varname_ERA5. users should give rules for each variable.
  - options for blending_rules: "replace", "lm", "lm_no_intercept", "automatic"

*scripts are provided for both python and R.
