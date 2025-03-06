# ERA5_FLUX

The primary objective of this repo is to improve the utility of ERA5 data at flux site locations. 

Scripts are organized into the following groups
1. create df.sitemetadata file 00_sitemetadata
- df that contains site meta data (site code, lat, lon, start date, end data, varibles needed)
2. pre-Download for Files _01
- 01_start_end_time_padding (add 1 day to start and end dates for future time zone offset issues)
- 01_lat_lon_UTC_offset (add UTC offest to df.sitemetadata)
- 01_point_sample_check (pull land-sea_mask for one day)
- 01_ERA5_API (use ecmwfr pacakge with df.sitemetadata)
3. Data Processing for ERA5 _02
4. Flux Data Merging
- one function titled Merge_ERA5_FLUX
  - input variables (character): filename_FLUX, filename_ERA5
  - input variables (vector of character): varname_FLUX, varname_ERA5
  - input variables (vector of character): blending_rules
  - output variables: adding new columns to the FLUX file
- requirement of these input variables
  - varname_FLUX and varname_ERA5 should have the same length. These names of the same row should be matched.
  - blending_rules should have the same length with varname_FLUX and varname_ERA5. users should give rules for each variable.
  - options for blending_rules: "replace", "lm_ERA5", "lm_FLUX", "lm_ERA5_no_intercept", "lm_FLUX_no_intercept"

*scripts are provided for both python and R.
