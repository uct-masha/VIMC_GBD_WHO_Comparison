# Reporting-rate analyses. Rates are analysed on the log10 scale, so a change
# from 1% to 10% counts the same as 10% to 100%. Zero-report years have no log
# rate; they are counted separately rather than imputed.

with_log_rate <- function(analysis_data) {
  analysis_data |>
    filter(rate_status %in% c("ratio", "zero reported")) |>
    mutate(log_rate = if_else(reporting_rate > 0, log10(reporting_rate), NA_real_))
}

slope_per_decade <- function(year, y, min_years) {
  ok <- !is.na(y)
  if (sum(ok) < min_years) return(NA_real_)
  unname(coef(lm(y[ok] ~ year[ok]))[2]) * 10
}

# ---- Within-country variability -------------------------------------------

country_rate_summary <- function(analysis_data, min_years) {
  with_log_rate(analysis_data) |>
    group_by(cause, iso3, location, who_region) |>
    summarise(
      years_evaluable = n(),
      years_zero_reported = sum(rate_status == "zero reported"),
      years_with_rate = sum(!is.na(log_rate)),
      median_rate = median(reporting_rate),
      min_rate = if (any(!is.na(log_rate))) min(reporting_rate[!is.na(log_rate)]) else NA_real_,
      max_rate = if (any(!is.na(log_rate))) max(reporting_rate[!is.na(log_rate)]) else NA_real_,
      sd_log10 = if (sum(!is.na(log_rate)) >= min_years) sd(log_rate, na.rm = TRUE) else NA_real_,
      log10_slope_per_decade = slope_per_decade(year, log_rate, min_years),
      .groups = "drop"
    ) |>
    mutate(fold_range = if_else(is.na(sd_log10), NA_real_, max_rate / min_rate)) |>
    arrange(cause, desc(sd_log10))
}

# Share of variance in log10 rate that lies within countries (over time)
# rather than between country means.
variance_split <- function(analysis_data, min_years) {
  with_log_rate(analysis_data) |>
    filter(!is.na(log_rate)) |>
    group_by(cause, iso3) |>
    filter(n() >= min_years) |>
    mutate(country_mean = mean(log_rate)) |>
    group_by(cause) |>
    summarise(
      countries = n_distinct(iso3),
      country_years = n(),
      ss_total = sum((log_rate - mean(log_rate))^2),
      ss_within = sum((log_rate - country_mean)^2),
      .groups = "drop"
    ) |>
    mutate(within_share = ss_within / ss_total) |>
    select(-ss_total, -ss_within)
}

cause_variability_summary <- function(country_summary, variance, analysis_data) {
  overall <- analysis_data |>
    filter(rate_status == "ratio") |>
    group_by(cause) |>
    summarise(
      median_rate = median(reporting_rate),
      pct_over_100 = mean(reporting_rate > 1),
      pct_within_5pct_of_100 = mean(abs(reporting_rate - 1) < 0.05),
      .groups = "drop"
    )

  country_summary |>
    filter(!is.na(sd_log10)) |>
    group_by(cause) |>
    summarise(
      median_sd_log10 = median(sd_log10),
      median_fold_range = median(fold_range),
      pct_countries_10x_range = mean(fold_range >= 10),
      median_slope_per_decade = median(log10_slope_per_decade),
      pct_rising = mean(log10_slope_per_decade > 0),
      .groups = "drop"
    ) |>
    left_join(variance, by = "cause") |>
    left_join(overall, by = "cause")
}

# ---- Disagreement ranking, pooled over recent years ------------------------
# Pooling smooths single-year outbreaks and reporting gaps.

disagreement_ranking <- function(analysis_data, from_year, min_modelled_cases) {
  analysis_data |>
    filter(year >= from_year, !is.na(reported_cases)) |>
    group_by(cause, iso3, location, who_region) |>
    summarise(
      years_reported = n(),
      reported = sum(reported_cases),
      modelled = sum(incidence_n_val),
      dtp3 = mean(dtp3, na.rm = TRUE),
      .groups = "drop"
    ) |>
    filter(modelled >= years_reported * min_modelled_cases) |>
    mutate(reporting_rate = reported / modelled) |>
    arrange(cause, reporting_rate)
}

# ---- DTP3 association ------------------------------------------------------
# Between countries (country means) and within countries (deviations from each
# country's own mean) are estimated separately.

dtp3_association <- function(analysis_data, min_years) {
  analysis_data |>
    filter(rate_status == "ratio", !is.na(dtp3)) |>
    mutate(log10_rate = log10(reporting_rate)) |>
    group_by(cause, iso3) |>
    mutate(
      within_rate = log10_rate - mean(log10_rate),
      within_dtp3 = dtp3 - mean(dtp3),
      n_country_years = n()
    ) |>
    group_by(cause) |>
    summarise(
      country_years = n(),
      countries = n_distinct(iso3),
      spearman_pooled = cor(dtp3, log10_rate, method = "spearman"),
      spearman_between = {
        cm <- tibble(iso3, dtp3, log10_rate) |> group_by(iso3) |> summarise(across(everything(), mean))
        cor(cm$dtp3, cm$log10_rate, method = "spearman")
      },
      pearson_within = cor(within_dtp3[n_country_years >= min_years], within_rate[n_country_years >= min_years]),
      .groups = "drop"
    )
}

# ---- Time trends -----------------------------------------------------------
# Sums over countries present in both sources, so totals are comparable.

global_trends <- function(gbd, gho_cases) {
  gbd <- filter(gbd, !is.na(incidence_n_val))
  gho <- filter(gho_cases, cause != "Neonatal tetanus", !is.na(reported_cases))
  common <- intersect(unique(gbd$iso3), unique(gho$iso3))

  gho_total <- gho |>
    filter(iso3 %in% common, year >= 1980) |>
    group_by(cause, year) |>
    summarise(cases = sum(reported_cases), countries_reporting = n(), .groups = "drop") |>
    mutate(source = "GHO reported")

  # Summing country UIs overstates the aggregate interval; a rough band only.
  gbd_total <- gbd |>
    filter(iso3 %in% common) |>
    group_by(cause, year) |>
    summarise(cases = sum(incidence_n_val), lower = sum(incidence_n_lower),
              upper = sum(incidence_n_upper), .groups = "drop") |>
    mutate(source = "GBD modelled")

  bind_rows(gho_total, gbd_total) |>
    mutate(source = factor(source, levels = names(pal_source)),
           n_common_countries = length(common))
}

# Country-level change from one GBD year to the next (annual from 1990), reported vs modelled
change_pairs <- function(analysis_data, min_modelled_cases) {
  analysis_data |>
    filter(!is.na(incidence_n_val)) |>
    arrange(cause, iso3, year) |>
    group_by(cause, iso3) |>
    mutate(
      prev_year = lag(year),
      prev_incidence = lag(incidence_n_val),
      d_log_modelled = log10(incidence_n_val) - log10(prev_incidence),
      d_log_reported = log10(reported_cases) - log10(lag(reported_cases))
    ) |>
    ungroup() |>
    filter(is.finite(d_log_modelled), is.finite(d_log_reported),
           incidence_n_val >= min_modelled_cases, prev_incidence >= min_modelled_cases)
}

change_agreement <- function(changes) {
  changes |>
    group_by(cause) |>
    summarise(
      intervals = n(),
      same_direction = mean(sign(d_log_modelled) == sign(d_log_reported)),
      cor_change = cor(d_log_modelled, d_log_reported),
      .groups = "drop"
    )
}
