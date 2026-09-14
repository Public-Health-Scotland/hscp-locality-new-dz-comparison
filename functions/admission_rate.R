admission_rate <- function(admissions_totals, locality_pop) {
  locality_pop |>
    filter(sex == "all") |>
    select(dz_version:hscp_locality, total_pop) |>
    left_join(admissions_totals, by = c("hscp_locality", "hscp2019name", "dz_version", "year" = "fy_start")) |>
    mutate(admissions_per_1k = (admissions / total_pop) * 1000)
}
