dz_to_locality_pop <- function(dz_pop, lookup, join_by) {
  dz_pop |>
    inner_join(lookup, by = join_by) |>
    group_by(year, hscp2019name, hscp_locality, sex) |>
    summarise(across(total_pop:age90plus, sum),
      .groups = "drop"
    ) |>
    mutate(
      age_under_18 = rowSums(pick(age0:age17)),
      age_18_to_64 = rowSums(pick(age18:age64)),
      age_65_plus = rowSums(pick(age64:age90plus)),
      .after = total_pop
    ) %>%
    bind_rows(
      . |>
        summarise(across(total_pop:age90plus, sum),
          .by = c(year, hscp2019name, hscp_locality),
          sex = "all"
        )
    ) |>
    mutate(sex = replace_values(
      sex,
      "F" ~ "male",
      "M" ~ "female"
    )) |>
    select(year:age_65_plus) |>
    arrange(year, hscp_locality)
}
