# -*- coding: utf-8 -*-
"""
Created on Fri Feb 21 14:30:27 2025

@author: ammara
"""


import cdsapi
import datetime
import os


def fetch_cds_data(area, year_range, month_range, day_range, time_range, output_file):
    # Set the API credentials as environment variables
    os.environ['CDSAPI_URL'] = 'https://cds.climate.copernicus.eu/api'
    os.environ['CDSAPI_KEY'] = '0a2b0eec-ed62-4a42-8fb8-83ca726ef382'  # Replace with your actual CDS API key
    
    # Initialize CDS API client
    client = cdsapi.Client()
    
    dataset = "reanalysis-era5-single-levels"
    request = {
        "product_type": ["reanalysis"],
        "variable": [
            "2m_dewpoint_temperature",
            "2m_temperature",
            "surface_solar_radiation_downwards"
        ],
        "year": [str(year) for year in range(year_range[0], year_range[1] + 1)],
        "month": [f"{month:02d}" for month in range(month_range[0], month_range[1] + 1)],
        "day": [f"{day:02d}" for day in range(day_range[0], day_range[1] + 1)],
        "time": [f"{hour:02d}:00" for hour in range(time_range[0], time_range[1] + 1)],
        "data_format": "netcdf",
        "download_format": "unarchived",
        "area": area
    }
    
    client.retrieve(dataset, request).download(target=output_file)
    print(f"Data downloaded successfully to {output_file}")

# Example usage
fetch_cds_data(
    area=[25.36, -81.1, 25.35, -81.01], # bigger absolute value of lat and long should come first
    year_range=(2004, 2007), # range of years # if you want exact lat long like ameriflux then make your middel lat long as close to ameri as possible 
    month_range=(1, 12), # range of months
    day_range=(1, 31), # range of days
    time_range=(0, 23),
    output_file="output.nc"
)


##########################################################################################################




















