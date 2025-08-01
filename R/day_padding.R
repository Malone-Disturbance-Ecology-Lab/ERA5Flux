#' @title Pad Dates by 1 Day
#'
#' @description
#' This function is designed to pad 1 day for the beginning and ending days. It will add 1 day to start and end dates for future time zone offset issues.
#'
#' @param start_day (character) Start date in either %Y-%m-%d or %Y/%m/%d format.
#' @param end_day (character) End date in either %Y-%m-%d or %Y/%m/%d format.
#' @return (character) New start and end dates in either %Y-%m-%d or %Y/%m/%d format, padded by 1 day each.
#'
#' @export
#'
#' @examples
#' # Pad starting and ending dates by 1 day
#' result <- day_padding("2024-01-01", "2025-12-31")
#' result
#'
#' @author Boya ("Paul") Zhang
#'
day_padding <- function(start_day = NULL,
                        end_day = NULL) {
  # Error out if no start day is provided
  if (base::is.null(start_day)) stop("No start day provided")

  # Error out if no end day is provided
  if (base::is.null(end_day)) stop("No end day provided")

  # Convert string to Date format
  start_date <- base::as.Date(start_day)
  end_date <- base::as.Date(end_day)

  # Adjust dates
  new_start <- start_date - 1
  new_end <- end_date + 1

  # Return as character format
  return(base::list(start_day = base::as.character(new_start), end_day = base::as.character(new_end)))
}
