# Country-level detail behind the scatter (reported vs modelled) and the
# global trends figures: which countries sit where, and which drive totals.

agreement_levels <- c(
  "Not reported to WHO", "Zero reported", "< 1% of modelled", "1-10% of modelled",
  "10-99% of modelled", "Equals GBD (floor)", "Exceeds modelled"
)

# Classify every country-year by how the WHO count compares with GBD. Unlike
# the reporting-rate analysis this keeps country-years with < 10 modelled
# cases, so every point in the scatter has a class; `small_gbd` marks them.
classify_agreement <- function(analysis_data, min_modelled_cases) {
  analysis_data |>
    filter(!is.na(incidence_n_val), !exclude) |>
    mutate(
      raw_ratio = reported_cases / incidence_n_val,
      small_gbd = incidence_n_val < min_modelled_cases,
      agreement = case_when(
        is.na(reported_cases) ~ agreement_levels[1],
        reported_cases == 0 ~ agreement_levels[2],
        gbd_floored ~ agreement_levels[6],
        raw_ratio > 1 ~ agreement_levels[7],
        raw_ratio >= 0.1 ~ agreement_levels[5],
        raw_ratio >= 0.01 ~ agreement_levels[4],
        TRUE ~ agreement_levels[3]
      ),
      agreement = factor(agreement, levels = agreement_levels),
      gbd_band = cut(incidence_n_val, c(0, 10, 100, 1e3, 1e4, Inf), right = FALSE,
                     labels = c("< 10", "10-99", "100-999", "1,000-9,999", "10,000+"))
    )
}

# Share of country-years in each agreement class, by a grouping variable
agreement_shares <- function(classified, years, by) {
  classified |>
    filter(year %in% years, !is.na(.data[[by]])) |>
    count(cause, group = .data[[by]], agreement, .drop = FALSE) |>
    group_by(cause, group) |>
    mutate(share = n / sum(n), total = sum(n)) |>
    ungroup() |>
    filter(total > 0)
}

# Countries where GBD estimates a substantial burden but WHO receives zeros
# or nothing. One row per country, pooled over `years`.
silent_countries <- function(classified, years, min_gbd_mean = 100) {
  classified |>
    filter(year %in% years) |>
    group_by(cause, iso3, location, who_region) |>
    summarise(
      gbd_mean = mean(incidence_n_val),
      reported_total = sum(reported_cases, na.rm = TRUE),
      years_zero = sum(agreement == "Zero reported"),
      years_missing = sum(agreement == "Not reported to WHO"),
      years_positive = sum(coalesce(reported_cases, 0) > 0),
      dtp3_mean = mean(dtp3, na.rm = TRUE),
      .groups = "drop"
    ) |>
    filter(years_positive == 0, gbd_mean >= min_gbd_mean) |>
    arrange(cause, desc(gbd_mean))
}

# Country-years where WHO reports more than GBD models (excluding the floor)
exceeding_countries <- function(classified, years) {
  classified |>
    filter(year %in% years, agreement == "Exceeds modelled") |>
    transmute(cause, year, location, who_region, reported_cases,
              modelled = incidence_n_val, ratio = raw_ratio, small_gbd, flag) |>
    arrange(cause, year, desc(ratio))
}

# ---- Contributions to global totals -----------------------------------------

# Annual cases by country for both sources, restricted to countries in both.
country_series <- function(gbd, gho_cases, gbd_location_map) {
  common <- intersect(unique(gbd$iso3), unique(gho_cases$iso3))
  bind_rows(
    gho_cases |>
      filter(cause != "Neonatal tetanus", iso3 %in% common, year >= 1980, !is.na(reported_cases)) |>
      transmute(cause, iso3, year, cases = reported_cases, source = "GHO reported"),
    gbd |>
      filter(iso3 %in% common, !is.na(incidence_n_val)) |>
      transmute(cause, iso3, year, cases = incidence_n_val, source = "GBD modelled")
  ) |>
    left_join(gbd_location_map, by = "iso3") |>
    mutate(source = factor(source, levels = names(pal_source)))
}

# The countries that matter most to either source: the union of each source's
# top `n_each` contributors since `from_year` (1990, when both sources start).
top_contributors <- function(series, cause_name, n_each = 4, from_year = 1990) {
  series |>
    filter(cause == cause_name, year >= from_year) |>
    group_by(source, location) |>
    summarise(total = sum(cases), .groups = "drop_last") |>
    slice_max(total, n = n_each) |>
    ungroup() |>
    group_by(location) |>
    summarise(total = max(total), .groups = "drop") |>
    arrange(desc(total)) |>
    pull(location)
}

# Largest contributors to the WHO global total in selected years
top_reporters_by_year <- function(series, years, n = 3) {
  series |>
    filter(source == "GHO reported", year %in% years) |>
    group_by(cause, year) |>
    mutate(global = sum(cases), share = cases / global) |>
    slice_max(cases, n = n, with_ties = FALSE) |>
    summarise(
      global = first(global),
      top = paste0(location, " (", formatC(cases, format = "d", big.mark = ","), ", ",
                   round(100 * share), "%)", collapse = "; "),
      top_share = sum(share),
      .groups = "drop"
    )
}

# ---- Figures -----------------------------------------------------------------

agreement_colours <- c(
  "Not reported to WHO" = "#e1e0d9",
  "Zero reported" = "#b4b2a9",  # zero_fill in utils.R
  "< 1% of modelled" = "#9ec5f4",
  "1-10% of modelled" = "#3987e5",
  "10-99% of modelled" = "#184f95",
  "Equals GBD (floor)" = "#1baf7a",
  "Exceeds modelled" = "#eb6834"
)

plot_agreement_shares <- function(shares, x_label) {
  ggplot(shares, aes(share, group, fill = agreement)) +
    geom_col(width = 0.75, colour = surface, linewidth = 0.2) +
    scale_fill_manual(values = agreement_colours, name = NULL, drop = FALSE) +
    scale_x_continuous(labels = scales::label_percent(), expand = c(0, 0)) +
    scale_y_discrete(limits = rev) +
    facet_wrap(~ cause, ncol = 1) +
    guides(fill = guide_legend(nrow = 2)) +
    labs(x = "Share of country-years", y = x_label, caption = gbd_caption) +
    theme_dtp(base_size = 9) +
    theme(panel.grid.major.y = element_blank())
}

# One cause-year of the scatter with notable countries labelled: every
# country reporting more than GBD, and the largest GBD burdens among countries
# reporting zero or far below.
plot_labelled_scatter <- function(classified, cause_name, year_shown, n_label = 6) {
  d <- classified |>
    filter(cause == cause_name, year == year_shown, !is.na(reported_cases))

  to_label <- bind_rows(
    d |> filter(agreement == "Exceeds modelled", !small_gbd),
    # Reports where GBD expects almost nothing
    d |> filter(agreement == "Exceeds modelled", small_gbd) |> slice_max(reported_cases, n = n_label),
    d |> filter(agreement == "Zero reported") |> slice_max(incidence_n_val, n = n_label),
    d |> filter(agreement %in% c("< 1% of modelled", "1-10% of modelled")) |>
      slice_max(incidence_n_val, n = n_label),
    d |> filter(agreement == "Equals GBD (floor)") |> slice_max(incidence_n_val, n = 3)
  ) |>
    distinct(iso3, .keep_all = TRUE)

  axis_trans <- scales::pseudo_log_trans(sigma = 1, base = 10)
  axis_breaks <- 10^(0:8)
  axis_labels <- c("1", "10", "100", "1K", "10K", "100K", "1M", "10M", "100M")
  lim <- max(c(d$incidence_n_val, d$reported_cases), na.rm = TRUE) * 1.5
  ref <- tibble(x = 10^seq(0, log10(lim), length.out = 100))

  ggplot(d, aes(incidence_n_val, reported_cases)) +
    geom_line(data = ref, aes(x, x), colour = axis_col, linetype = "dashed", linewidth = 0.4) +
    geom_point(aes(colour = agreement), size = 1.6, alpha = 0.85) +
    ggrepel::geom_text_repel(
      data = to_label, aes(label = location), size = 2.4, colour = ink_secondary,
      min.segment.length = 0, segment.colour = axis_col, segment.size = 0.3,
      box.padding = 0.35, max.overlaps = Inf, seed = 1
    ) +
    scale_colour_manual(values = agreement_colours, name = NULL, drop = TRUE) +
    scale_x_continuous(trans = axis_trans, breaks = axis_breaks, labels = axis_labels) +
    scale_y_continuous(trans = axis_trans, breaks = axis_breaks, labels = axis_labels) +
    coord_cartesian(xlim = c(0, lim), ylim = c(0, lim)) +
    guides(colour = guide_legend(nrow = 2, override.aes = list(size = 2.5))) +
    labs(
      title = paste0(cause_name, ", ", year_shown, ": reported vs modelled, notable countries labelled"),
      x = "GBD modelled incidence (cases)", y = "WHO GHO reported cases", caption = gbd_caption
    ) +
    theme_dtp(base_size = 9)
}

# Stacked contributions of the top countries to each source's global total
plot_contributions <- function(series, cause_name, n_each = 4) {
  top <- top_contributors(series, cause_name, n_each)
  levels <- c(top, "All other countries")
  pal <- c(setNames(c("#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4",
                      "#008300", "#6250d6", "#e34948")[seq_along(top)], top),
           "All other countries" = "#d6d4cc")

  d <- series |>
    filter(cause == cause_name) |>
    mutate(country = factor(if_else(location %in% top, location, "All other countries"), levels = levels)) |>
    group_by(source, year, country) |>
    summarise(cases = sum(cases), .groups = "drop") |>
    complete(source, year, country, fill = list(cases = 0)) |>
    group_by(source) |>
    filter(year >= min(year[cases > 0]), year <= max(year[cases > 0])) |>
    ungroup()

  ggplot(d, aes(year, cases, fill = country)) +
    geom_area(colour = surface, linewidth = 0.15) +
    scale_fill_manual(values = pal, name = NULL) +
    scale_y_continuous(labels = scales::label_comma()) +
    facet_wrap(~ source, scales = "free_y") +
    guides(fill = guide_legend(nrow = 2)) +
    labs(
      title = paste0(cause_name, ": which countries make up the global totals"),
      x = NULL, y = "Cases", caption = gbd_caption
    ) +
    theme_dtp(base_size = 9) +
    theme(panel.spacing.x = unit(1.2, "lines"))
}
