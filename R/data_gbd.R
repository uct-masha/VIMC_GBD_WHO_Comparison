# GBD 2023 Results Tool exports. Exports are size-capped, so years were
# downloaded as several files; every IHME-GBD_*.csv in data/raw/gbd is stacked.

read_gbd_exports <- function(files) {
  lapply(files, read_csv, show_col_types = FALSE) |>
    bind_rows() |>
    distinct(measure, location, sex, age, cause, metric, year, .keep_all = TRUE)
}

# GBD location names that countrycode doesn't resolve on its own
gbd_manual_iso3 <- c(
  "Micronesia (Federated States of)" = "FSM",
  "Türkiye" = "TUR"
)

gbd_locations <- function(gbd_raw) {
  locations <- tibble(location = unique(gbd_raw$location)) |>
    mutate(iso3 = coalesce(
      unname(gbd_manual_iso3[location]),
      countrycode(location, "country.name", "iso3c", warn = FALSE)
    ))

  unmatched <- filter(locations, is.na(iso3))
  if (nrow(unmatched) > 0) {
    stop("GBD locations without ISO3: ", paste(unmatched$location, collapse = "; "))
  }
  if (anyDuplicated(locations$iso3)) {
    stop("Several GBD locations map to the same ISO3 code")
  }
  locations
}

# One row per country-cause-year, with incidence and deaths (number and rate)
# and their uncertainty intervals as columns, e.g. incidence_n_val.
clean_gbd <- function(gbd_raw, locations) {
  gbd_raw |>
    left_join(locations, by = "location") |>
    mutate(
      measure = tolower(measure),
      metric = if_else(metric == "Number", "n", "rate")
    ) |>
    select(iso3, location, cause, year, measure, metric, val, lower, upper) |>
    pivot_wider(
      names_from = c(measure, metric),
      values_from = c(val, lower, upper),
      names_glue = "{measure}_{metric}_{.value}"
    )
}
