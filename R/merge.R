# Join GBD modelled incidence/deaths to GHO reported cases by country, cause,
# year, and compute the implied reporting rate (reported / modelled incidence).
#
# Only GBD years are kept. GHO "Total tetanus" is compared with GBD "Tetanus";
# neonatal tetanus has no matching GBD cause in the export.

merge_sources <- function(gbd, gho_cases, gho_coverage, reporting_issues, min_modelled_cases) {
  regions <- distinct(gho_cases, iso3, who_region)
  neonatal <- gho_cases |>
    filter(cause == "Neonatal tetanus") |>
    transmute(iso3, year, cause = "Tetanus", reported_neonatal = reported_cases)

  gbd |>
    left_join(
      gho_cases |>
        filter(cause != "Neonatal tetanus") |>
        select(iso3, cause, year, reported_cases),
      by = c("iso3", "cause", "year")
    ) |>
    left_join(neonatal, by = c("iso3", "cause", "year")) |>
    left_join(regions, by = "iso3") |>
    left_join(gho_coverage, by = c("iso3", "year")) |>
    flag_reporting_issues(reporting_issues) |>
    mutate(
      reporting_rate = if_else(
        !is.na(reported_cases) & incidence_n_val >= min_modelled_cases & !exclude,
        reported_cases / incidence_n_val,
        NA_real_
      ),
      rate_status = case_when(
        is.na(incidence_n_val) ~ "no GBD incidence",
        is.na(reported_cases) ~ "not reported to WHO",
        exclude ~ "known reporting break",
        incidence_n_val < min_modelled_cases ~ "modelled < threshold",
        reported_cases == 0 ~ "zero reported",
        TRUE ~ "ratio"
      )
    )
}

# Country-years where the WHO series is known to change meaning, from the
# research brief (docs/research_brief.md, items B4-B5). `exclude` drops the
# country-years from rate calculations; otherwise they are only labelled.
known_reporting_issues <- function() {
  tribble(
    ~iso3, ~cause,       ~from, ~to,  ~exclude, ~issue,
    "IND", "Tetanus",    2020,  2025, TRUE,     "India total tetanus loses non-neonatal cases from 2020; equals neonatal only from 2022",
    "PAK", "Pertussis",  1989,  1990, FALSE,    "Pakistan pertussis series collapses in 1989-1991 (source change suspected)",
    "CHN", "Pertussis",  2017,  2025, FALSE,    "China accepts PCR confirmation from 2017; new criteria from 2024"
  )
}

# GBD 2023 replaces diphtheria and pertussis estimates with the WHO count
# where its model falls below it, so ratios of ~1 are copies, not agreement.
flag_reporting_issues <- function(merged, reporting_issues, floor_tolerance = 0.01) {
  issues <- reporting_issues |>
    rowwise() |>
    reframe(iso3, cause, year = from:to, exclude, issue)

  merged |>
    left_join(issues, by = c("iso3", "cause", "year")) |>
    mutate(
      exclude = coalesce(exclude, FALSE),
      gbd_floored = cause %in% c("Diphtheria", "Pertussis") &
        coalesce(reported_cases, 0) > 0 &
        abs(reported_cases / incidence_n_val - 1) < floor_tolerance,
      flag = case_when(
        !is.na(issue) ~ issue,
        gbd_floored ~ "GBD estimate set to the WHO count (GBD 2023 floor)",
        TRUE ~ NA_character_
      )
    ) |>
    select(-issue)
}

# Countries present in one source but not the other
country_coverage_mismatch <- function(gbd, gho_cases) {
  gho_iso <- unique(gho_cases$iso3)
  gbd_iso <- unique(gbd$iso3)
  bind_rows(
    tibble(iso3 = setdiff(gho_iso, gbd_iso), in_source = "GHO only"),
    tibble(iso3 = setdiff(gbd_iso, gho_iso), in_source = "GBD only")
  ) |>
    mutate(country = countrycode(iso3, "iso3c", "country.name",
                                 custom_match = c(XKX = "Kosovo")))
}

rate_status_counts <- function(analysis_data) {
  analysis_data |>
    count(cause, rate_status) |>
    pivot_wider(names_from = rate_status, values_from = n, values_fill = 0)
}
