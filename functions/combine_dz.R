combine_dz <- function(dz11, dz22) {
  list(
    "2011 datazones" = dz11,
    "2022 datazones" = dz22
  ) |>
    list_rbind(names_to = "dz_version")
}
