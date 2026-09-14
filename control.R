### Load packages
pacman::p_load(
  tidyverse,
  openxlsx2,
  odbc,
  dbplyr,
  data.table
)

### Source functions
list.files("functions", full.names = T) |>
  walk(source)

### Define HSCPS
hscps <- c(
  "North Lanarkshire",
  "South Lanarkshire"
)

# lookup ------------------------------------------------------------------

### create locality lookups for 2011 and 2022 datazones
lookup_DZ11 <- create_2011_lookup(hscps)
lookup_DZ22 <- create_2022_lookup(hscps)
# can also define filepaths to 2022 lookups with lookup_files = c("path1.xlsx", ...)


# demographics ------------------------------------------------------------

### population by datazone
population_DZ11 <- get_dz11_population()
population_DZ22 <- get_dz22_population()

### locality demographics
demographics_DZ11 <- dz_to_locality_pop(population_DZ11, lookup_DZ11, join_by = "datazone2011")
demographics_DZ22 <- dz_to_locality_pop(population_DZ22, lookup_DZ22, join_by = "datazone2022")

locality_demographics <- combine_dz(demographics_DZ11, demographics_DZ22)

# save to temp folder
saveRDS(locality_demographics, "temp/locality_demographics.rds")


# Hospital admissions -----------------------------------------------------

smr_admissions <- get_smr_admissions(hscps)

admissions_DZ11 <- admissions_by_locality(smr_admissions, lookup_DZ11, join_by = "datazone2011")
admissions_DZ22 <- admissions_by_locality(smr_admissions, lookup_DZ22, join_by = "datazone2022")

locality_admissions <- combine_dz(admissions_DZ11, admissions_DZ22) %>%
  filter(!is.na(hscp_locality))

# save to temp folder
saveRDS(locality_admissions, "temp/locality_admissions.rds")
