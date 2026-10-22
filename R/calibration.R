# What the GBD and WHO data can and cannot offer as calibration targets for
# DTPBoost in the 117 VIMC countries. Feeds calibration_targets.qmd.

# ISO3 codes as listed for the VIMC analysis. GHO codes Kosovo as XKX, and
# GBD has no Kosovo estimates (it is included in Serbia).
vimc_countries <- function() {
  iso3 <- c(
    "AGO", "CAF", "CMR", "COD", "COG", "STP", "TCD", "ARM", "AZE", "DZA", "EGY", "GEO", "IRQ",
    "JOR", "MAR", "PSE", "SDN", "SYR", "TUN", "YEM", "BDI", "COM", "DJI", "ERI", "ETH", "KEN",
    "MDG", "MOZ", "MWI", "RWA", "SOM", "SSD", "TZA", "UGA", "ZMB", "ZWE", "BEN", "BFA", "CIV",
    "CPV", "GHA", "GIN", "GMB", "GNB", "LBR", "MLI", "MRT", "NER", "NGA", "SEN", "SLE", "TGO",
    "LSO", "NAM", "SWZ", "ZAF", "AFG", "BGD", "BTN", "IND", "IRN", "KGZ", "LKA", "MDV", "NPL",
    "PAK", "TJK", "TKM", "UZB", "CHN", "IDN", "KHM", "LAO", "MMR", "MNG", "PHL", "PRK", "THA",
    "TLS", "VNM", "ALB", "BIH", "BLR", "MDA", "MKD", "SRB", "UKR", "XK", "BLZ", "BOL", "COL",
    "CUB", "DMA", "ECU", "GRD", "GTM", "GUY", "HND", "HTI", "JAM", "LCA", "NIC", "PER", "PRY",
    "SLV", "VCT", "VEN", "FJI", "FSM", "KIR", "MHL", "PNG", "SLB", "TON", "TUV", "VUT", "WSM"
  )
  stopifnot(length(iso3) == 117, !anyDuplicated(iso3))
  tibble(iso3 = iso3, iso3_gho = if_else(iso3 == "XK", "XKX", iso3))
}

case_causes <- c("Diphtheria", "Pertussis", "Tetanus")

# Short English names (countrycode's defaults include "Congo - Kinshasa" etc.)
vimc_country_name <- function(iso3) {
  countrycode(iso3, "iso3c", "country.name", custom_match = c(
    XKX = "Kosovo", COD = "DR Congo", COG = "Congo", MMR = "Myanmar", PSE = "Palestine",
    CIV = "Côte d'Ivoire", STP = "São Tomé and Príncipe", FSM = "Micronesia", PRK = "DPR Korea",
    SWZ = "Eswatini", MKD = "North Macedonia", VCT = "St Vincent and the Grenadines",
    LCA = "St Lucia", CPV = "Cabo Verde", TLS = "Timor-Leste"
  ))
}

# WHO case series for the VIMC countries; nulls stay NA (no report), zeros stay 0
vimc_gho_cases <- function(gho_cases, vimc) {
  gho_cases |>
    filter(iso3 %in% vimc$iso3_gho, cause %in% case_causes)
}

vimc_analysis_data <- function(analysis_data, vimc) {
  filter(analysis_data, iso3 %in% vimc$iso3_gho)
}

# Data tier from the number of years with a positive WHO count
data_tier <- function(years_positive) {
  case_when(
    years_positive >= 15 ~ "A: 15+ positive years",
    years_positive >= 5 ~ "B: 5-14 positive years",
    TRUE ~ "C: < 5 positive years"
  )
}

# One row per VIMC country and cause: how much the WHO series can support
reporting_completeness <- function(vimc_cases, vimc, years) {
  vimc_cases |>
    filter(year %in% years) |>
    group_by(iso3, cause) |>
    summarise(
      years_reported = sum(!is.na(reported_cases)),
      years_zero = sum(reported_cases == 0, na.rm = TRUE),
      years_positive = sum(reported_cases > 0, na.rm = TRUE),
      cases = sum(reported_cases, na.rm = TRUE),
      .groups = "drop"
    ) |>
    right_join(crossing(iso3 = vimc$iso3_gho, cause = case_causes), by = c("iso3", "cause")) |>
    mutate(
      across(c(years_reported, years_zero, years_positive, cases), \(x) coalesce(x, 0)),
      tier = data_tier(years_positive)
    )
}

completeness_summary <- function(completeness, n_years) {
  completeness |>
    group_by(cause) |>
    summarise(
      countries = n(),
      most_years_reported = sum(years_reported >= 0.8 * n_years),
      few_years_reported = sum(years_reported < 10),
      mostly_zero = sum(years_zero >= 0.5 * years_reported & years_reported > 0),
      never_positive = sum(years_positive == 0),
      tier_a = sum(startsWith(tier, "A")),
      tier_b = sum(startsWith(tier, "B")),
      tier_c = sum(startsWith(tier, "C")),
      .groups = "drop"
    )
}

# How concentrated each country's diphtheria reports are in a few years
diphtheria_burstiness <- function(vimc_cases, years) {
  vimc_cases |>
    filter(cause == "Diphtheria", year %in% years, !is.na(reported_cases)) |>
    group_by(iso3) |>
    arrange(desc(reported_cases), .by_group = TRUE) |>
    summarise(
      total = sum(reported_cases),
      years_reported = n(),
      years_positive = sum(reported_cases > 0),
      median_year = median(reported_cases),
      top1_share = first(reported_cases) / total,
      top3_share = sum(head(reported_cases, 3)) / total,
      .groups = "drop"
    ) |>
    filter(total > 0)
}

burstiness_summary <- function(burstiness, n_countries, min_total = 100) {
  big <- filter(burstiness, total >= min_total)
  ranked <- arrange(burstiness, desc(total))
  tibble(
    countries_any = nrow(burstiness),
    countries_none = n_countries - nrow(burstiness),
    countries_big = nrow(big),
    median_top1 = median(big$top1_share),
    median_top3 = median(big$top3_share),
    over_half_one_year = sum(big$top1_share > 0.5),
    median_year_zero = sum(burstiness$median_year == 0),
    top10_share = sum(head(ranked$total, 10)) / sum(ranked$total),
    top10 = paste(head(ranked$iso3, 10), collapse = ", "),
    total = sum(burstiness$total)
  )
}

# GBD 2023 country-years equal to the WHO count, by calendar year (all
# countries). If the floor were applied every year these would spread evenly.
floored_by_year <- function(analysis_data, estimation_years) {
  analysis_data |>
    filter(gbd_floored) |>
    count(cause, year) |>
    complete(cause = c("Diphtheria", "Pertussis"), year = 1990:2023, fill = list(n = 0)) |>
    mutate(estimation_year = year %in% estimation_years)
}

# Per-country implied reporting rate (GHO / GBD) over a window. Floored years
# are dropped because they are copies of the WHO count.
vimc_country_rates <- function(vimc_data, years) {
  vimc_data |>
    filter(year %in% years, !is.na(reporting_rate), !gbd_floored) |>
    group_by(iso3, location, who_region, cause) |>
    summarise(
      country_years = n(),
      zero_years = sum(reporting_rate == 0),
      geo_mean_rate = if (any(reporting_rate > 0)) exp(mean(log(reporting_rate[reporting_rate > 0]))) else NA_real_,
      sd_log10 = if (sum(reporting_rate > 0) >= 4) sd(log10(reporting_rate[reporting_rate > 0])) else NA_real_,
      dtp3_mean = mean(dtp3, na.rm = TRUE),
      .groups = "drop"
    )
}

vimc_rate_summary <- function(country_rates) {
  country_rates |>
    group_by(cause) |>
    summarise(
      country_years = sum(country_years),
      zero_share = sum(zero_years) / sum(country_years),
      countries = sum(!is.na(geo_mean_rate)),
      p10 = quantile(geo_mean_rate, 0.1, na.rm = TRUE),
      median = median(geo_mean_rate, na.rm = TRUE),
      p90 = quantile(geo_mean_rate, 0.9, na.rm = TRUE),
      median_sd_log10 = median(sd_log10, na.rm = TRUE),
      spearman_dtp3 = cor(log(geo_mean_rate), dtp3_mean, method = "spearman", use = "complete.obs"),
      .groups = "drop"
    )
}

# Does a country that reports one disease well report the others well?
cross_disease_rates <- function(country_rates) {
  wide <- country_rates |>
    filter(!is.na(geo_mean_rate)) |>
    select(iso3, location, who_region, cause, geo_mean_rate) |>
    pivot_wider(names_from = cause, values_from = geo_mean_rate)
  pairs <- tibble(x = c("Tetanus", "Tetanus", "Pertussis"), y = c("Pertussis", "Diphtheria", "Diphtheria"))
  stats <- pairs |>
    rowwise() |>
    mutate(
      n = sum(!is.na(wide[[x]]) & !is.na(wide[[y]])),
      spearman = cor(wide[[x]], wide[[y]], method = "spearman", use = "complete.obs")
    ) |>
    ungroup()
  list(wide = wide, stats = stats)
}

# Population implied by GBD incidence number / rate (per 100,000)
vimc_population <- function(vimc_data, year_of = 2023) {
  vimc_data |>
    filter(cause == "Pertussis", year == year_of, incidence_rate_val > 0) |>
    transmute(iso3, location = vimc_country_name(iso3), who_region,
              population = incidence_n_val / incidence_rate_val * 1e5)
}

# Diphtheria reports by year for the countries that reported most, keeping
# the difference between no report (NA) and a reported zero
diphtheria_tiles <- function(vimc_cases, burstiness, years, min_total = 100) {
  keep <- burstiness |>
    filter(total >= min_total) |>
    arrange(total)
  vimc_cases |>
    filter(cause == "Diphtheria", year %in% years, iso3 %in% keep$iso3) |>
    complete(iso3, year = years) |>
    mutate(
      country = factor(vimc_country_name(iso3), levels = vimc_country_name(keep$iso3)),
      status = case_when(
        is.na(reported_cases) ~ "No report",
        reported_cases == 0 ~ "Zero",
        TRUE ~ "Cases"
      )
    )
}

# Everything per country in one table, written to output/tables
vimc_country_table <- function(vimc, vimc_cases, completeness, country_rates, burstiness, vimc_data, gho_coverage) {
  # GHO gives Kosovo no WHO region; WHO reports it with the European Region
  regions <- distinct(vimc_cases, iso3, who_region) |>
    mutate(who_region = if_else(iso3 == "XKX", "Europe", who_region))
  comp <- completeness |>
    select(iso3, cause, years_reported, years_positive, tier) |>
    mutate(cause = tolower(cause)) |>
    pivot_wider(names_from = cause, values_from = c(years_reported, years_positive, tier),
                names_glue = "{cause}_{.value}")
  rates <- country_rates |>
    transmute(iso3, cause = tolower(cause), geo_mean_rate) |>
    pivot_wider(names_from = cause, values_from = geo_mean_rate, names_glue = "{cause}_rate_2010_2019")
  gbd2019 <- vimc_data |>
    filter(year == 2019) |>
    transmute(iso3, cause = tolower(cause), incidence = incidence_n_val, deaths = deaths_n_val) |>
    pivot_wider(names_from = cause, values_from = c(incidence, deaths), names_glue = "{cause}_gbd2019_{.value}")
  floors <- vimc_data |>
    filter(gbd_floored) |>
    count(iso3, cause) |>
    mutate(cause = tolower(cause)) |>
    pivot_wider(names_from = cause, values_from = n, names_glue = "{cause}_gbd_floored_years", values_fill = 0)
  dtp3 <- gho_coverage |> filter(year == 2023) |> select(iso3, dtp3_2023 = dtp3)

  vimc |>
    transmute(iso3 = iso3_gho, country = vimc_country_name(iso3_gho)) |>
    left_join(regions, by = "iso3") |>
    left_join(comp, by = "iso3") |>
    left_join(rates, by = "iso3") |>
    left_join(gbd2019, by = "iso3") |>
    left_join(floors, by = "iso3") |>
    left_join(select(burstiness, iso3, diphtheria_top3_share = top3_share), by = "iso3") |>
    left_join(dtp3, by = "iso3") |>
    mutate(across(ends_with("floored_years"), \(x) coalesce(x, 0L)))
}

# ---- Figures -----------------------------------------------------------------

plot_floored_years <- function(floored) {
  ggplot(floored, aes(year, n, fill = estimation_year)) +
    geom_col(width = 0.8) +
    scale_fill_manual(values = c(`TRUE` = pal_cause[["Diphtheria"]], `FALSE` = zero_fill),
                      labels = c(`TRUE` = "Year ending in 0 or 5, or 2022", `FALSE` = "Other years"),
                      name = NULL) +
    facet_wrap(~cause, ncol = 1, scales = "free_y") +
    scale_x_continuous(breaks = seq(1990, 2020, 5)) +
    labs(
      title = "GBD 2023 country-years equal to the WHO count",
      subtitle = "All 204 countries. Diphtheria floors fall almost only on a few years; pertussis floors do not.",
      x = NULL, y = "Country-years within 1% of WHO count", caption = gbd_caption
    ) +
    theme_dtp()
}

plot_diphtheria_tiles <- function(tiles) {
  ggplot(tiles, aes(year, country)) +
    geom_tile(data = filter(tiles, status == "Cases"), aes(fill = reported_cases),
              colour = surface, linewidth = 0.3) +
    geom_tile(data = filter(tiles, status == "Zero"), fill = zero_fill, colour = surface, linewidth = 0.3) +
    geom_tile(data = filter(tiles, status == "No report"), fill = surface, colour = axis_col,
              linewidth = 0.2, width = 0.75, height = 0.75) +
    scale_fill_gradientn(colours = seq_blue, trans = "log10", name = "Reported cases",
                         labels = scales::label_comma(), breaks = c(1, 10, 100, 1e3, 1e4)) +
    scale_x_continuous(breaks = seq(2000, 2025, 5), expand = c(0, 0)) +
    labs(
      title = "Diphtheria reported to WHO, VIMC countries with at least 100 cases since 2000",
      subtitle = "Grey: reported zero. Outlined blank: no report (null in GHO).",
      x = NULL, y = NULL, caption = "Source: WHO Global Health Observatory (WHS3_41)."
    ) +
    theme_dtp() +
    theme(panel.grid.major = element_blank(), legend.key.width = unit(1.4, "cm"))
}

plot_vimc_rates <- function(country_rates) {
  d <- filter(country_rates, !is.na(geo_mean_rate))
  ggplot(d, aes(geo_mean_rate, cause)) +
    geom_boxplot(outlier.shape = NA, width = 0.5, linewidth = 0.4, colour = ink_secondary) +
    geom_jitter(aes(colour = cause), height = 0.15, size = 1.3, alpha = 0.7, show.legend = FALSE) +
    scale_colour_manual(values = pal_cause) +
    scale_x_log10(labels = pct_label, breaks = 10^(-5:1)) +
    labs(
      title = "Implied reporting rate per VIMC country, 2010-2019",
      subtitle = "Geometric mean of WHO reported / GBD modelled over years with a non-zero rate; floored years dropped",
      x = "Reporting rate (log scale)", y = NULL, caption = gbd_caption
    ) +
    theme_dtp()
}

plot_cross_disease <- function(cross) {
  w <- cross$wide
  panel <- function(x, y) {
    tibble(xv = w[[x]], yv = w[[y]], who_region = w$who_region, pair = paste(y, "vs", x),
           xlab = x, ylab = y) |>
      filter(!is.na(xv), !is.na(yv))
  }
  d <- bind_rows(panel("Tetanus", "Pertussis"), panel("Tetanus", "Diphtheria"), panel("Pertussis", "Diphtheria"))
  strip <- cross$stats |>
    transmute(pair = paste(y, "vs", x),
              strip = sprintf("%s vs %s\nSpearman %.2f (n = %d)", y, x, spearman, n))
  d <- left_join(d, strip, by = "pair")
  ggplot(d, aes(xv, yv)) +
    geom_abline(slope = 1, intercept = 0, colour = axis_col, linetype = "dashed") +
    geom_point(colour = ink_secondary, size = 1.4, alpha = 0.7) +
    scale_x_log10(labels = pct_label) +
    scale_y_log10(labels = pct_label) +
    facet_wrap(~strip, scales = "free") +
    labs(
      title = "Reporting completeness is only weakly shared across diseases",
      subtitle = "Each point is a VIMC country's 2010-2019 geometric-mean reporting rate; dashed line is equality",
      x = "Reporting rate, second-named disease", y = "Reporting rate, first-named disease",
      caption = gbd_caption
    ) +
    theme_dtp()
}

plot_population <- function(population, thresholds = c(1e5, 1e6)) {
  d <- population |>
    arrange(population) |>
    mutate(location = factor(location, levels = location))
  small <- filter(d, population < max(thresholds))
  ggplot(small, aes(population, location)) +
    geom_vline(xintercept = thresholds, colour = axis_col, linetype = "dashed") +
    geom_point(colour = pal_cause[["Pertussis"]], size = 2) +
    scale_x_log10(labels = scales::label_comma()) +
    labs(
      title = "VIMC countries with fewer than 1 million people",
      subtitle = "Population in 2023, from GBD incidence number / rate",
      x = "Population (log scale)", y = NULL, caption = "Source: GBD 2023 (IHME)."
    ) +
    theme_dtp()
}
