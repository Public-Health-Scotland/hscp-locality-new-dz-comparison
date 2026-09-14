get_smr_admissions <- function(hscps) {
  #### 1. Set up ----

  hscp_code <- suppressMessages(phslookups::get_hscp_locality(
    col_select = c(hscp2019name, hscp2019)
  )) |>
    distinct() |>
    filter(hscp2019name %in% hscps) |>
    pull(hscp2019)

  # Set dates

  # start & end of extract
  start_date <- as.Date("2011-04-01")
  end_date <- as.Date("2025-04-01")

  # additional 12 months back as including by discharge
  smr_from <- start_date %m-% months(12)

  #### 2. Extract SMR01 Data ----

  # Connect to SMRA tables using odbc connection
  channel <- suppressWarnings(
    dbConnect(
      odbc(),
      dsn = "SMRA",
      uid = rstudioapi::showPrompt(title = "USERNAME", message = "Enter LDAP username:"),
      pwd = rstudioapi::askForPassword("Enter LDAP password:")
    )
  )

  smr01 <- tbl(channel, in_schema("ANALYSIS", "SMR01_PI"))

  smr_query <- smr01 %>%
    select(
      LINK_NO, ADMISSION_DATE,
      DISCHARGE_DATE, CIS_MARKER, SPECIALTY, LOCATION,
      SIGNIFICANT_FACILITY, ADMISSION_TYPE, DR_POSTCODE,
      AGE_IN_YEARS, HBTREAT_CURRENTDATE, ADMISSION,
      DISCHARGE, URI, HSCP_2019, DATAZONE_2011, DATAZONE_2022
    ) %>%
    filter(
      DISCHARGE_DATE >= as.Date(smr_from),
      ADMISSION_DATE < as.Date(end_date),
      HSCP_2019 %in% hscp_code
    )

  # SMR01 Extract
  smr01_extract <- collect(smr_query) %>%
    # tidy up variable names
    janitor::clean_names()

  # Close odbc connection
  dbDisconnect(channel)


  #### 3. Group up to SMR01 CIS stays --------

  # Arrange
  smr01_extract <- smr01_extract %>%
    arrange(link_no, cis_marker, admission_date, discharge_date, desc(admission_type))

  # Convert to data table, aggregate to stay level
  # Take minimum & maximum dates, first of everything else
  smr01_extract <- as.data.table(smr01_extract)
  smr01_extract <- smr01_extract[, .(
    admission_date = min(admission_date),
    discharge_date = max(discharge_date),
    age = first(age_in_years),
    specialty = first(specialty),
    location = first(location),
    significant_facility = first(significant_facility),
    admission_type = first(admission_type),
    hbtreat_currentdate = first(hbtreat_currentdate),
    admission = first(admission),
    discharge = first(discharge),
    uri = first(uri),
    hscp2019 = first(hscp_2019),
    datazone2011 = first(datazone_2011),
    datazone2022 = first(datazone_2022)
  ),
  by = c("link_no", "cis_marker")
  ]

  # Convert back to data frame & sort
  smr01_extract <- as.data.frame(smr01_extract) %>%
    ungroup() %>%
    arrange(link_no, cis_marker, admission_date, discharge_date, desc(admission_type)) %>%
    #### 4. Select emergency admissions ----

    # select the required data
    # select discharges within months reported
    filter(discharge_date %within% interval(start_date, end_date)) %>%
    # select emergency admissions
    filter(admission_type >= 20 & admission_type <= 22 |
      admission_type >= 30 & admission_type <= 39) %>%
    # format month variable
    mutate(month_year = format(discharge_date, "%b-%y"))
}
