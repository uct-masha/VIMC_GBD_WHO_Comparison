# Join GBD modelled incidence/deaths to GHO reported cases by country, cause,
# year, and compute the implied reporting rate (reported / modelled incidence).
#
# Only GBD years are kept. GHO "Total tetanus" is compared with GBD "Tetanus";
# neonatal tetanus has no matching GBD cause in the export.

merge_sources <- function(gbd, gho_cases, gho_coverage, min_modelled_cases) {
  regions <- distinct(gho_cases, iso3, who_region)

  gbd |>
    left_join(
      gho_cases |>
        filter(cause != "Neonatal tetanus") |>
        select(iso3, cause, year, reported_cases),
      by = c("iso3", "cause", "year")
    ) |>
    left_join(regions, by = "iso3") |>
    left_join(gho_coverage, by = c("iso3", "year")) |>
    mutate(
      reporting_rate = if_else(
        !is.na(reported_cases) & incidence_n_val >= min_modelled_cases,
        reported_cases / incidence_n_val,
        NA_real_
      ),
      rate_status = case_when(
        is.na(incidence_n_val) ~ "no GBD incidence",
        is.na(reported_cases) ~ "not reported to WHO",
        incidence_n_val < min_modelled_cases ~ "modelled < threshold",
        reported_cases == 0 ~ "zero reported",
        TRUE ~ "ratio"
      )
    )
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
