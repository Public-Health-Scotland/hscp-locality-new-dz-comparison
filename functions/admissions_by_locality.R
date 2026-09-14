admissions_by_locality <- function(smr01_extract, lookup, join_by) {
  admissions_output <- smr01_extract %>%
    left_join(lookup, join_by) %>%
    mutate(
      fy_start = year(discharge_date) - (month(discharge_date) < 4),
      admissions = 1
    )

  admissions_output <- dtplyr::lazy_dt(admissions_output) %>%
    group_by(
      hscp2019name, hscp_locality, fy_start
    ) %>%
    summarise(admissions = sum(admissions)) %>%
    ungroup() %>%
    tibble::as.tibble()

  return(admissions_output)
}
