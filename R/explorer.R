# Interactive explorer: a single HTML page (explorer/template.html) with the
# pipeline's data embedded as JSON. Columnar arrays keep the payload small.

explorer_causes <- c("Diphtheria", "Pertussis", "Tetanus")

build_explorer_data <- function(analysis_data, classified, gho_cases, gbd_location_map, gho_coverage) {
  regions <- distinct(gho_cases, iso3, who_region)
  countries <- gbd_location_map |>
    left_join(regions, by = "iso3") |>
    arrange(location) |>
    mutate(i = row_number() - 1L)
  idx <- setNames(countries$i, countries$iso3)

  agreement <- c(agreement_levels, "Not comparable (reporting break)")

  # One row per GBD country-cause-year (1990 onwards)
  rows <- analysis_data |>
    filter(!is.na(incidence_n_val)) |>
    left_join(select(classified, iso3, cause, year, agreement), by = c("iso3", "cause", "year")) |>
    mutate(agreement = if_else(exclude, agreement[length(agreement)], as.character(agreement))) |>
    arrange(cause, year, iso3)

  flags <- sort(unique(na.omit(rows$flag)))

  # WHO counts for years GBD doesn't cover, for the country profiles
  gho_extra <- gho_cases |>
    filter(iso3 %in% countries$iso3, !is.na(reported_cases)) |>
    anti_join(distinct(rows, iso3, cause, year), by = c("iso3", "cause", "year")) |>
    arrange(cause, iso3, year)

  coverage <- gho_coverage |>
    filter(iso3 %in% countries$iso3, !is.na(dtp3)) |>
    arrange(iso3, year)

  r1 <- function(x, digits = 1) ifelse(is.na(x), NA, round(x, digits))

  list(
    generated = format(Sys.Date()),
    causes = explorer_causes,
    agreement = agreement,
    flags = flags,
    countries = list(iso3 = countries$iso3, name = countries$location, region = countries$who_region),
    rows = list(
      c = unname(idx[rows$iso3]),
      d = match(rows$cause, explorer_causes) - 1L,
      y = rows$year,
      gbd = r1(rows$incidence_n_val),
      lo = r1(rows$incidence_n_lower),
      hi = r1(rows$incidence_n_upper),
      deaths = r1(rows$deaths_n_val),
      rep = rows$reported_cases,
      nt = rows$reported_neonatal,
      dtp3 = rows$dtp3,
      a = match(rows$agreement, agreement) - 1L,
      f = match(rows$flag, flags) - 1L
    ),
    gho_extra = list(
      c = unname(idx[gho_extra$iso3]),
      d = match(gho_extra$cause, c(explorer_causes, "Neonatal tetanus")) - 1L,
      y = gho_extra$year,
      rep = gho_extra$reported_cases
    ),
    coverage = list(c = unname(idx[coverage$iso3]), y = coverage$year, dtp3 = coverage$dtp3)
  )
}

# Write the explorer. `standalone = TRUE` adds the document preamble so the
# file opens directly in a browser; FALSE leaves the page body for hosts that
# supply their own (e.g. a Claude artifact).
write_explorer <- function(data, template, path, standalone = TRUE) {
  html <- paste(readLines(template, warn = FALSE, encoding = "UTF-8"), collapse = "\n")
  json <- jsonlite::toJSON(data, auto_unbox = TRUE, na = "null", digits = NA)
  marker <- "/*__EXPLORER_DATA__*/null"
  parts <- strsplit(html, marker, fixed = TRUE)[[1]]
  if (length(parts) != 2) stop("Expected exactly one data marker in ", template)
  html <- paste0(parts[1], json, parts[2])
  if (standalone) {
    html <- paste0(
      '<!doctype html>\n<html lang="en">\n<meta charset="utf-8">\n',
      '<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">\n',
      html, "\n</html>\n"
    )
  }
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  writeLines(html, path, useBytes = TRUE)
  path
}
