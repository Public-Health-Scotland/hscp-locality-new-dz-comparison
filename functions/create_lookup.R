#' Create HSCP locality lookup for 2011 datazones from national reference file
#'
#' @param hscps vector of HSCP names
#'
#' @returns Data.frame with columns datazone2011, hscp_locality, and hscp2019name
#'
create_2011_lookup <- function(hscps) {
  read_rds("/conf/linkage/output/lookups/Unicode/Geography/HSCP Locality/HSCP Localities_DZ11_Lookup_20240513.rds") |>
    select(datazone2011, hscp_locality, hscp2019name) |>
    filter(hscp2019name %in% hscps)
}

#' Create HSCP locality lookup for 2022 datazones from returned locality spreadsheets from HSCPs
#'
#' @param hscps vector of HSCP names
#' @param lookup_files (optional) vector of paths to returned lookup. Use if path differs from that expected by the function.
#'
#' @returns Data.frame with columns datazone2011, hscp_locality, and hscp2019name
#'
create_2022_lookup <- function(hscps, lookup_files = NULL) {
  if (is.null(lookup_files)) {
    lookup_files <- str_glue(
      "/conf/LIST_analytics/West Hub/Geospatial Cross Team/2022 Datazone to HSCP Locality Lookups/Returned Lookup Files/{hscp} HSCP - 2022 Datazone to HSCP Locality Lookup.xlsx",
      hscp = hscps
    )
  }

  missing_files <- lookup_files[!file.exists(lookup_files)]

  if (length(missing_files) > 0) {
    stop(
      paste0(
        "The following lookup file(s) could not be found:\n",
        paste(missing_files, collapse = "\n")
      ),
      call. = FALSE
    )
  }

  lookups <- lookup_files |>
    map(\(x) read_xlsx(x, sheet = "2022 Datazone to HSCP Locality") |>
      select(datazone2022, hscp_locality, hscp2019name))

  lookups |> list_rbind()
}
