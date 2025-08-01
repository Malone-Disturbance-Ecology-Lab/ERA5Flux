% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utc_offset.R
\name{check_DST}
\alias{check_DST}
\title{Check Daylight Saving Time}
\usage{
check_DST(lat = NULL, lon = NULL, timepoint = NULL)
}
\arguments{
\item{lat}{(numeric) Latitude coordinate in decimal degrees.}

\item{lon}{(numeric) Longitude coordinate in decimal degrees.}

\item{timepoint}{(character) Time point in either \%Y-\%m-\%d or \%Y/\%m/\%d format.}
}
\value{
(list) A list containing a boolean representing the DST status and the standard time if DST is in effect.
}
\description{
This function will check if a given time point is in Daylight Saving Time (DST). If so, it will adjust the time to the standard (non-DST) time.
}
\examples{
# This will get the current time
timepoint <- lubridate::now()
# Check whether the time is in DST at latitude 25.4, longitude -80.5 and get the standard time if so
is_DST <- check_DST(lat = 25.4, lon = -80.5, timepoint)
is_DST

}
