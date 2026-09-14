get_dz11_population <- function() {
  readRDS(
    "/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2011_pop_est_2011_2024.rds"
  ) |>
    select(year:total_pop) |>
    relocate(total_pop, .before = age0)
}

get_dz22_population <- function() {
  dz22_pop_1121 <- readRDS(
    "/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2022_pop_est_2011_2021.rds"
  ) |>
    select(year:total_pop) |>
    relocate(total_pop, .before = age0)

  dz22_pop_2224 <- readRDS(
    "/conf/linkage/output/lookups/Unicode/Populations/Estimates/DataZone2022_pop_est_2022_2024.rds"
  ) |>
    select(year:total_pop) |>
    relocate(total_pop, .before = age0)

  bind_rows(
    dz22_pop_1121,
    dz22_pop_2224
  )
}
