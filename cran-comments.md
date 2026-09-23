## Resubmission

This is a resubmission. I have edited the package according to the feedback received from the initial submission. In this version, I have:

- Linked to the ERA5-Land and AmeriFlux webpages in the description field of the DESCRIPTION file.
- Replaced \\dontrun{} with \\donttest{} wherever possible, or removed \\dontrun{} outright. However, there is still 1 instance of \\dontrun{} in the `download_ERA5()` function because this function requires an API key, which is unique to each person. I believe using \\dontrun{} should be okay in this situation. If not, please let me know.
- Replaced instances of `print()` with `message()`, or deleted `print()` outright.

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
