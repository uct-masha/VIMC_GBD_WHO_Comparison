# Pipeline: WHO GHO vs GBD 2023 burden of diphtheria, tetanus and pertussis.
# Run with targets::tar_make(); inspect with targets::tar_visnetwork().

library(targets)
library(tarchetypes)

tar_option_set(
  packages = c("dplyr", "tidyr", "readr", "ggplot2", "jsonlite", "countrycode", "ggrepel")
)

tar_source("R")

# Below this many modelled cases the reporting rate is dominated by noise
# (e.g. 2 reported vs 0.3 modelled), so it is not computed.
MIN_MODELLED_CASES <- 10
# Countries need this many years with a rate for variability statistics
MIN_YEARS_WITH_RATE <- 4
# GHO is re-downloaded when the cached copy is older than this
GHO_MAX_AGE <- as.difftime(30, units = "days")
# Window for the country-level breakdowns of the latest years
RECENT_YEARS <- 2019:2023

# Settings for the VIMC calibration-targets section (calibration_targets.qmd)
# Window for WHO reporting completeness in the 117 VIMC countries
VIMC_COMPLETENESS_YEARS <- 2000:2024
# Window for per-country reporting rates: pre-COVID and inside GBD 2023
VIMC_RATE_YEARS <- 2010:2019
# Years on which GBD 2023 diphtheria floors cluster (inferred from the data,
# see calibration_targets.qmd); used only to colour the floor figure
GBD_FLOOR_YEARS <- c(seq(1990, 2020, 5), 2022)

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
  tar_target(reporting_issues, known_reporting_issues()),
  tar_target(merged, merge_sources(gbd, gho_cases, gho_coverage, reporting_issues, MIN_MODELLED_CASES)),
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

  # ---- Country-level detail --------------------------------------------------
  tar_target(classified, classify_agreement(analysis_data, MIN_MODELLED_CASES)),
  tar_target(shares_by_region, agreement_shares(classified, RECENT_YEARS, "who_region")),
  tar_target(shares_by_gbd_band, agreement_shares(classified, RECENT_YEARS, "gbd_band")),
  tar_target(silent, silent_countries(classified, RECENT_YEARS)),
  tar_target(exceeding, exceeding_countries(classified, max(RECENT_YEARS))),
  tar_target(series, country_series(gbd, gho_cases, gbd_location_map)),
  tar_target(top_reporters, top_reporters_by_year(series, c(2010, 2019, 2023, 2024, 2025))),

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
  tar_target(fig_shares_region, plot_agreement_shares(shares_by_region, NULL)),
  tar_target(fig_shares_band, plot_agreement_shares(shares_by_gbd_band, "GBD modelled cases per year")),
  tar_map(
    values = causes,
    tar_target(fig_trajectories, plot_trajectories(analysis_data, cause)),
    tar_target(fig_labelled, plot_labelled_scatter(classified, cause, max(RECENT_YEARS))),
    tar_target(fig_contrib, plot_contributions(series, cause)),
    tar_target(
      fig_country_files,
      c(save_plot(fig_labelled, paste0("labelled_scatter_", tolower(cause)), width = 9, height = 7),
        save_plot(fig_contrib, paste0("contributions_", tolower(cause)), width = 11, height = 5)),
      format = "file"
    ),
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
      save_plot(fig_change, "change_reported_vs_modelled", width = 11, height = 4.8),
      save_plot(fig_shares_region, "agreement_by_region", width = 9, height = 7),
      save_plot(fig_shares_band, "agreement_by_gbd_size", width = 9, height = 7)
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
      save_csv(coverage_mismatch, "country_coverage_mismatch"),
      save_csv(classified, "country_year_agreement"),
      save_csv(silent, "silent_countries_recent"),
      save_csv(exceeding, "countries_exceeding_gbd")
    ),
    format = "file"
  ),

  # ---- Interactive explorer --------------------------------------------------
  tar_target(explorer_template, "explorer/template.html", format = "file"),
  tar_target(explorer_data, build_explorer_data(analysis_data, classified, gho_cases, gbd_location_map, gho_coverage)),
  tar_target(explorer, write_explorer(explorer_data, explorer_template, "explorer.html"), format = "file"),

  # ---- Report --------------------------------------------------------------
  tar_quarto(report, "report.qmd"),

  # ==========================================================================
  # ---- START: VIMC calibration targets (calibration_targets.qmd) -----------
  # What the GBD and WHO data offer as calibration targets for DTPBoost in the
  # 117 VIMC countries. Reuses gho_cases, analysis_data and gho_coverage from
  # above; functions are in R/calibration.R.
  # ==========================================================================
  tar_target(vimc, vimc_countries()),
  tar_target(vimc_cases, vimc_gho_cases(gho_cases, vimc)),
  tar_target(vimc_data, vimc_analysis_data(analysis_data, vimc)),
  tar_target(vimc_completeness, reporting_completeness(vimc_cases, vimc, VIMC_COMPLETENESS_YEARS)),
  tar_target(vimc_completeness_summary, completeness_summary(vimc_completeness, length(VIMC_COMPLETENESS_YEARS))),
  tar_target(vimc_burstiness, diphtheria_burstiness(vimc_cases, 2000:2025)),
  tar_target(vimc_burstiness_summary, burstiness_summary(vimc_burstiness, nrow(vimc))),
  tar_target(floored_years, floored_by_year(analysis_data, GBD_FLOOR_YEARS)),
  tar_target(vimc_rates, vimc_country_rates(vimc_data, VIMC_RATE_YEARS)),
  tar_target(vimc_rates_summary, vimc_rate_summary(vimc_rates)),
  tar_target(vimc_cross, cross_disease_rates(vimc_rates)),
  tar_target(vimc_pop, vimc_population(vimc_data)),
  tar_target(vimc_diph_tiles, diphtheria_tiles(vimc_cases, vimc_burstiness, 2000:2025)),
  tar_target(vimc_table, vimc_country_table(vimc, vimc_cases, vimc_completeness, vimc_rates, vimc_burstiness,
                                            vimc_data, gho_coverage)),

  tar_target(fig_floored_years, plot_floored_years(floored_years)),
  tar_target(fig_diph_tiles, plot_diphtheria_tiles(vimc_diph_tiles)),
  tar_target(fig_vimc_rates, plot_vimc_rates(vimc_rates)),
  tar_target(fig_cross_disease, plot_cross_disease(vimc_cross)),
  tar_target(fig_population, plot_population(vimc_pop)),
  tar_target(
    calibration_files,
    c(
      save_plot(fig_floored_years, "calibration_gbd_floored_years", width = 9, height = 5.5),
      save_plot(fig_diph_tiles, "calibration_diphtheria_reports", width = 10, height = 8),
      save_plot(fig_vimc_rates, "calibration_reporting_rates", width = 9, height = 4.5),
      save_plot(fig_cross_disease, "calibration_cross_disease", width = 11, height = 4.5),
      save_plot(fig_population, "calibration_small_populations", width = 8, height = 5),
      save_csv(vimc_table, "vimc117_country_summary")
    ),
    format = "file"
  ),

  tar_quarto(calibration_report, "calibration_targets.qmd")
  # ---- END: VIMC calibration targets ---------------------------------------
)
