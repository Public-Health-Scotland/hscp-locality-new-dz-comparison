combine_dz <- function(dz11, dz22) {
  list(
    "2011 data zones" = dz11,
    "2022 data zones" = dz22
  ) |>
    list_rbind(names_to = "dz_version")
}
