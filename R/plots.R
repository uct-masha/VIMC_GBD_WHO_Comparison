# Figure functions. Each returns a ggplot; saving happens in _targets.R.

plot_reported_vs_modelled <- function(analysis_data, years = c(1990, 2000, 2010, 2023)) {
  d <- filter(analysis_data, !is.na(reported_cases), year %in% years)

  # Reference lines where reported = 100%, 10%, 1% of modelled. Drawn as paths
  # because pseudo-log axes bend straight lines near zero.
  y_max <- 1e6
  ref_paths <- crossing(
    tibble(rate = c(1, 0.1, 0.01), label = c("100%", "10%", "1%")),
    x = 10^seq(0, 8, length.out = 200)
  ) |>
    mutate(y = x * rate) |>
    filter(y >= 1, y <= y_max)

  # pseudo-log keeps zero reports visible at the bottom of each panel
  axis_trans <- scales::pseudo_log_trans(sigma = 1, base = 10)
  axis_breaks <- 10^c(0, 2, 4, 6, 8)
  axis_labels <- c("1", "100", "10K", "1M", "100M")

  ggplot(d, aes(incidence_n_val, reported_cases)) +
    geom_line(data = ref_paths, aes(x, y, group = label), colour = axis_col,
              linewidth = 0.4, linetype = "dashed") +
    geom_point(aes(colour = cause), size = 1.1, alpha = 0.6, show.legend = FALSE) +
    scale_colour_manual(values = pal_cause) +
    scale_x_continuous(trans = axis_trans, breaks = axis_breaks, labels = axis_labels) +
    scale_y_continuous(trans = axis_trans, breaks = axis_breaks, labels = axis_labels) +
    coord_cartesian(xlim = c(0, 1e8), ylim = c(0, y_max)) +
    facet_grid(cause ~ year) +
    labs(
      title = "Reported cases vs GBD modelled incidence, by country",
      subtitle = "Dashed lines, left to right: reported = 100%, 10% and 1% of modelled. Points on the floor reported zero cases.",
      x = "GBD modelled incidence (cases)", y = "WHO GHO reported cases",
      caption = gbd_caption
    ) +
    theme_dtp()
}

plot_fold_range <- function(country_summary, min_years) {
  country_summary |>
    filter(!is.na(fold_range)) |>
    ggplot(aes(fold_range, cause, colour = cause)) +
    geom_boxplot(outlier.shape = NA, width = 0.5, linewidth = 0.4, colour = ink_secondary) +
    geom_jitter(height = 0.15, size = 1.2, alpha = 0.6, show.legend = FALSE) +
    scale_colour_manual(values = pal_cause) +
    scale_x_log10(breaks = 10^(0:5), labels = c("1x", "10x", "100x", "1,000x", "10,000x", "100,000x")) +
    labs(
      title = "Within-country range of the implied reporting rate, 1990-2023",
      subtitle = paste0("Highest / lowest non-zero reported/modelled ratio per country (countries with >= ",
                        min_years, " years with a ratio)"),
      x = "Fold range (log scale)", y = NULL, caption = gbd_caption
    ) +
    theme_dtp()
}

# WHO regions split into two halves so each heatmap fits on a page
heatmap_region_parts <- list(
  c("Africa", "Americas", "Eastern Mediterranean"),
  c("Europe", "South-East Asia", "Western Pacific")
)

heatmap_data <- function(analysis_data, country_summary, cause_name, part, min_years_shown = 5) {
  regions <- heatmap_region_parts[[part]]
  keep <- country_summary |>
    filter(cause == cause_name, years_evaluable >= min_years_shown, who_region %in% regions) |>
    arrange(who_region, median_rate)

  analysis_data |>
    filter(cause == cause_name) |>
    semi_join(keep, by = "iso3") |>
    mutate(
      location = factor(location, levels = keep$location),
      who_region = factor(who_region, levels = regions)
    )
}

plot_heatmap <- function(analysis_data, country_summary, cause_name, part) {
  d <- heatmap_data(analysis_data, country_summary, cause_name, part)

  ggplot(d, aes(year, location)) +
    geom_tile(data = filter(d, rate_status == "zero reported"), fill = zero_fill,
              colour = surface, linewidth = 0.2) +
    geom_tile(data = filter(d, rate_status == "ratio"), aes(fill = reporting_rate),
              colour = surface, linewidth = 0.2) +
    scale_x_continuous(breaks = seq(1990, 2020, by = 5), expand = c(0, 0)) +
    scale_fill_gradientn(
      colours = seq_blue, trans = "log10", limits = c(1e-4, 1),
      oob = scales::squish, breaks = 10^(-4:0),
      labels = c("<=0.01%", "0.1%", "1%", "10%", ">=100%"),
      name = "Reported / modelled",
      guide = guide_colourbar(title.position = "top")
    ) +
    facet_grid(who_region ~ ., scales = "free_y", space = "free_y", switch = "y") +
    labs(
      title = paste0(cause_name, ": implied reporting rate by country and year"),
      subtitle = "Grey = zero reported. Blank = not reported to WHO or GBD incidence < 10 cases.",
      x = NULL, y = NULL, caption = gbd_caption
    ) +
    theme_dtp(base_size = 8) +
    theme(
      panel.grid.major = element_blank(),
      axis.line.x = element_blank(),
      axis.text.y = element_text(size = 6),
      strip.text.y.left = element_text(angle = 0, size = 7),
      strip.placement = "outside",
      legend.key.width = unit(1.4, "cm"),
      legend.key.height = unit(0.25, "cm")
    )
}

heatmap_height <- function(analysis_data, country_summary, cause_name, part) {
  d <- heatmap_data(analysis_data, country_summary, cause_name, part)
  2 + nlevels(droplevels(d$location)) * 0.11
}

plot_trajectories <- function(analysis_data, cause_name, n_countries = 12) {
  top <- analysis_data |>
    filter(cause == cause_name, year == max(year)) |>
    slice_max(incidence_n_val, n = n_countries)

  # Full year grid so lines break at years with no ratio rather than bridging them
  d <- analysis_data |>
    filter(cause == cause_name) |>
    semi_join(top, by = "iso3") |>
    mutate(line_rate = if_else(rate_status == "ratio", reporting_rate, NA_real_))

  # Zero-report years sit on their own row one decade below the smallest ratio
  zero_row <- 10^(floor(log10(min(d$line_rate, na.rm = TRUE))) - 1)
  ratio_breaks <- 10^(seq(log10(zero_row) + 1, 1))
  d_zero <- filter(d, rate_status == "zero reported")
  col <- pal_cause[[cause_name]]

  ggplot(d, aes(year)) +
    geom_hline(yintercept = zero_row, colour = grid_col, linewidth = 0.3) +
    geom_line(aes(y = line_rate), colour = col, linewidth = 0.6, na.rm = TRUE) +
    geom_point(aes(y = line_rate, shape = "Reported / modelled"), colour = col, size = 1.8, na.rm = TRUE) +
    geom_point(data = d_zero, aes(y = zero_row, shape = "Zero cases reported"), colour = col, size = 1.8) +
    scale_shape_manual(values = c("Reported / modelled" = 16, "Zero cases reported" = 4), name = NULL) +
    scale_y_log10(breaks = c(zero_row, ratio_breaks), labels = c("zero", pct_label(ratio_breaks))) +
    facet_wrap(~ location, ncol = 4, labeller = label_wrap_gen(30)) +
    labs(
      title = paste0(cause_name, ": implied reporting rate over time, ", n_countries,
                     " highest-burden countries (GBD ", max(analysis_data$year), ")"),
      subtitle = "Log scale. Gaps = not reported to WHO or GBD incidence < 10 cases.",
      x = NULL, y = "Reported / modelled", caption = gbd_caption
    ) +
    theme_dtp() +
    theme(panel.grid.major.y = element_line(colour = grid_col, linewidth = 0.3))
}

plot_disagreement <- function(ranking, n_each = 10) {
  # Countries reporting zero throughout have no meaningful rank on the low
  # side, so the "lowest" list only includes countries that reported cases.
  zero_reporters <- ranking |> filter(reported == 0) |> count(cause, name = "n_zero")

  extremes <- bind_rows(
    ranking |> filter(reported > 0) |> group_by(cause) |>
      slice_min(reporting_rate, n = n_each, with_ties = FALSE) |>
      mutate(end = "Lowest"),
    ranking |> group_by(cause) |>
      slice_max(reporting_rate, n = n_each, with_ties = FALSE) |>
      mutate(end = "Highest")
  ) |>
    ungroup() |>
    left_join(zero_reporters, by = "cause") |>
    mutate(panel = if_else(end == "Lowest",
                           paste0(cause, ": lowest\n(", coalesce(n_zero, 0L), " more reported zero)"),
                           paste0(cause, ": highest\n")))

  extremes |>
    mutate(label = reorder(paste(location, cause, end, sep = "___"), reporting_rate)) |>
    ggplot(aes(reporting_rate, label, colour = cause)) +
    geom_vline(xintercept = 1, colour = axis_col, linewidth = 0.4) +
    geom_point(size = 2) +
    scale_colour_manual(values = pal_cause, guide = "none") +
    scale_x_log10(labels = pct_label, breaks = scales::breaks_log(n = 5)) +
    scale_y_discrete(labels = function(x) sub("___.*$", "", x)) +
    facet_wrap(~ panel, scales = "free", ncol = 2) +
    labs(
      title = "Largest disagreements between WHO-reported and GBD-modelled cases, 2020-2023 pooled",
      subtitle = "Vertical line = reported equals modelled.",
      x = "Reported / modelled (log scale)", y = NULL, caption = gbd_caption
    ) +
    theme_dtp(base_size = 9)
}

plot_dtp3 <- function(analysis_data) {
  d <- filter(analysis_data, rate_status == "ratio", !is.na(dtp3))

  ggplot(d, aes(dtp3, reporting_rate, colour = cause)) +
    geom_point(size = 0.9, alpha = 0.35) +
    geom_smooth(method = "loess", se = FALSE, colour = ink_primary, linewidth = 0.6, formula = y ~ x) +
    scale_colour_manual(values = pal_cause, guide = "none") +
    scale_y_log10(labels = pct_label, breaks = 10^(-5:2)) +
    scale_x_continuous(labels = function(x) paste0(x, "%"), breaks = c(25, 50, 75, 100)) +
    facet_wrap(~ cause) +
    labs(
      title = "Implied reporting rate vs DTP3 coverage, all country-years 1990-2023",
      subtitle = "Black line: loess smooth. Excludes zero-report years and GBD incidence < 10 cases.",
      x = "DTP3 coverage (WUENIC)", y = "Reported / modelled (log scale)", caption = gbd_caption
    ) +
    theme_dtp() +
    theme(panel.spacing.x = unit(1.2, "lines"))
}

plot_global_trends <- function(trends) {
  gbd_total <- filter(trends, source == "GBD modelled")

  ggplot(trends, aes(year, cases, colour = source)) +
    geom_ribbon(data = gbd_total, aes(ymin = lower, ymax = upper, x = year), inherit.aes = FALSE,
                fill = pal_source[["GBD modelled"]], alpha = 0.15) +
    geom_line(linewidth = 0.7) +
    scale_colour_manual(values = pal_source, name = NULL) +
    scale_y_log10(labels = scales::label_comma()) +
    facet_wrap(~ cause, scales = "free_y") +
    labs(
      title = "Global cases over time: WHO reported vs GBD modelled incidence",
      subtitle = paste0("Sum over ", trends$n_common_countries[1], " countries in both sources. ",
                        "Band: sum of country 95% UIs (approximate)."),
      x = NULL, y = "Cases (log scale)", caption = gbd_caption
    ) +
    theme_dtp() +
    theme(panel.spacing.x = unit(1.2, "lines"))
}

plot_change <- function(changes) {
  fold_lab <- function(x) paste0(signif(10^x, 2), "x")

  ggplot(changes, aes(d_log_modelled, d_log_reported, colour = cause)) +
    geom_hline(yintercept = 0, colour = axis_col, linewidth = 0.3) +
    geom_vline(xintercept = 0, colour = axis_col, linewidth = 0.3) +
    geom_abline(slope = 1, intercept = 0, colour = axis_col, linetype = "dashed", linewidth = 0.4) +
    geom_point(size = 1, alpha = 0.45) +
    scale_colour_manual(values = pal_cause, guide = "none") +
    scale_x_continuous(labels = fold_lab) +
    scale_y_continuous(labels = fold_lab) +
    coord_cartesian(xlim = c(-1.5, 1.5), ylim = c(-3, 3)) +
    facet_wrap(~ cause) +
    labs(
      title = "Year-on-year change by country: reported vs modelled",
      subtitle = "Each point is one country-year. Dashed = equal change.",
      x = "Fold change in GBD modelled incidence", y = "Fold change in WHO reported cases",
      caption = gbd_caption
    ) +
    theme_dtp() +
    theme(panel.spacing.x = unit(1.2, "lines"))
}
