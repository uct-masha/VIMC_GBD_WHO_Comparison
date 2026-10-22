# WHO GHO: reported case counts and DTP vaccine coverage.
# GHO publishes these as country-year totals only (no age or sex breakdown).

gho_case_indicators <- function() {
  tribble(
    ~code,      ~cause,
    "WHS3_41",  "Diphtheria",
    "WHS3_43",  "Pertussis",
    "WHS3_46",  "Tetanus",            # total tetanus, includes neonatal
    "WHS3_56",  "Neonatal tetanus"
  )
}

gho_coverage_indicators <- function() {
  tribble(
    ~code,                  ~dose,
    "VACCINECOVERAGE_DTP1", "dtp1",
    "WHS4_100",             "dtp3"
  )
}

fetch_gho_indicators <- function(codes) {
  lapply(codes, function(code) {
    as_tibble(fromJSON(paste0("https://ghoapi.azureedge.net/api/", code))$value)
  }) |>
    bind_rows()
}

clean_gho_cases <- function(raw, indicators) {
  raw |>
    filter(SpatialDimType == "COUNTRY") |>
    transmute(
      iso3 = SpatialDim,
      who_region = ParentLocation,
      code = IndicatorCode,
      year = as.integer(TimeDim),
      reported_cases = NumericValue
    ) |>
    left_join(indicators, by = "code")
}

clean_gho_coverage <- function(raw, indicators) {
  raw |>
    filter(SpatialDimType == "COUNTRY") |>
    left_join(indicators, by = c("IndicatorCode" = "code")) |>
    transmute(iso3 = SpatialDim, year = as.integer(TimeDim), dose, coverage = NumericValue) |>
    pivot_wider(names_from = dose, values_from = coverage)
}
