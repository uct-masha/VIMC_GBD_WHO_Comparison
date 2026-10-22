# Pipeline: WHO GHO vs GBD 2023 burden of diphtheria, tetanus and pertussis.
# Run with targets::tar_make(); inspect with targets::tar_visnetwork().

library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("dplyr", "tidyr", "readr", "ggplot2", "jsonlite", "countrycode")
)

tar_source("R")

# Below this many modelled cases the reporting rate is dominated by noise
# (e.g. 2 reported vs 0.3 modelled), so it is not computed.
MIN_MODELLED_CASES <- 10
# Countries need this many years with a rate for variability statistics
MIN_YEARS_WITH_RATE <- 4
# GHO is re-downloaded when the cached copy is older than this
GHO_MAX_AGE <- as.difftime(30, units = "days")

causes <- tibble::tibble(cause = c("Diphtheria", "Pertussis", "Tetanus"))
heatmap_parts <- tidyr::crossing(causes, part = 1:2)

list(
  # ---- Inputs --------------------------------------------------------------
  tar_target(gho_case_codes, gho_case_indicators()),
  tar_target(gho_coverage_codes, gho_coverage_indicators()),
  tar_age(gho_cases_raw, fetch_gho_indicators(gho_case_codes$code), age = GHO_MAX_AGE),
  tar_age(gho_coverage_raw, fetch_gho_indicators(gho_coverage_codes$code), age = GHO_MAX_AGE),
  tar_files_input(
    gbd_files,
    list.files("data/raw/gbd", pattern = "^IHME-GBD_.*\\.csv$", full.names = TRUE)
  ),

  # ---- Cleaning and merging ------------------------------------------------
  tar_target(gho_cases, clean_gho_cases(gho_cases_raw, gho_case_codes)),
  tar_target(gho_coverage, clean_gho_coverage(gho_coverage_raw, gho_coverage_codes)),
  tar_target(gbd_raw, read_gbd_exports(gbd_files)),
  tar_target(gbd_location_map, gbd_locations(gbd_raw)),
  tar_target(gbd, clean_gbd(gbd_raw, gbd_location_map)),
  tar_target(merged, merge_sources(gbd, gho_cases, gho_coverage, MIN_MODELLED_CASES)),
  tar_target(coverage_mismatch, country_coverage_mismatch(gbd, gho_cases)),
  # GBD has no incidence before 1990
  tar_target(analysis_data, dplyr::filter(merged, year >= 1990)),
  tar_target(status_counts, rate_status_counts(analysis_data)),

  # ---- Analyses ------------------------------------------------------------
  tar_target(country_summary, country_rate_summary(analysis_data, MIN_YEARS_WITH_RATE)),
  tar_target(variance, variance_split(analysis_data, MIN_YEARS_WITH_RATE)),
  tar_target(cause_summary, cause_variability_summary(country_summary, variance, analysis_data)),
  tar_target(ranking, disagreement_ranking(analysis_data, 2020, MIN_MODELLED_CASES)),
  tar_target(dtp3_assoc, dtp3_association(analysis_data, MIN_YEARS_WITH_RATE)),
  tar_target(trends, global_trends(gbd, gho_cases)),
  tar_target(changes, change_pairs(analysis_data, MIN_MODELLED_CASES)),
  tar_target(change_summary, change_agreement(changes)),

  # ---- Figures -------------------------------------------------------------
  tar_target(fig_scatter, plot_reported_vs_modelled(analysis_data)),
  tar_target(fig_fold_range, plot_fold_range(country_summary, MIN_YEARS_WITH_RATE)),
  tar_target(fig_disagreement, plot_disagreement(ranking)),
  tar_target(fig_dtp3, plot_dtp3(analysis_data)),
  tar_target(fig_trends, plot_global_trends(trends)),
  tar_target(fig_change, plot_change(changes)),
  tar_map(
    values = heatmap_parts,
    names = c("cause", "part"),
    tar_target(fig_heatmap, plot_heatmap(analysis_data, country_summary, cause, part)),
    tar_target(
      fig_heatmap_file,
      save_plot(fig_heatmap, paste0("heatmap_", tolower(cause), "_", part), width = 7,
                height = heatmap_height(analysis_data, country_summary, cause, part)),
      format = "file"
    )
  ),
  tar_map(
    values = causes,
    tar_target(fig_trajectories, plot_trajectories(analysis_data, cause)),
    tar_target(
      fig_trajectories_file,
      save_plot(fig_trajectories, paste0("trajectories_", tolower(cause)), width = 11, height = 8),
      format = "file"
    )
  ),

  # ---- Exported files ------------------------------------------------------
  tar_target(
    figure_files,
    c(
      save_plot(fig_scatter, "scatter_reported_vs_modelled", width = 11, height = 8),
      save_plot(fig_fold_range, "reporting_rate_fold_range", width = 9, height = 4.5),
      save_plot(fig_disagreement, "disagreement_ranking", width = 10, height = 10),
      save_plot(fig_dtp3, "reporting_rate_vs_dtp3", width = 11, height = 4.8),
      save_plot(fig_trends, "global_trends", width = 11, height = 4.8),
      save_plot(fig_change, "change_reported_vs_modelled", width = 11, height = 4.8)
    ),
    format = "file"
  ),
  tar_target(
    table_files,
    c(
      save_csv(merged, "gbd_gho_merged"),
      save_csv(country_summary, "reporting_rate_by_country"),
      save_csv(cause_summary, "reporting_rate_variability_summary"),
      save_csv(ranking, "disagreement_ranking_2020_2023"),
      save_csv(dtp3_assoc, "dtp3_association"),
      save_csv(trends, "global_trends"),
      save_csv(change_summary, "change_direction_agreement"),
      save_csv(coverage_mismatch, "country_coverage_mismatch")
    ),
    format = "file"
  ),

  # ---- Report --------------------------------------------------------------
  tar_quarto(report, "report.qmd")
)
