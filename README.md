# DTP disease burden: GBD vs WHO GHO

Compares the burden of diphtheria, tetanus and pertussis as estimated by GBD 2023 (modelled) with reported case counts from the WHO Global Health Observatory. The main focus is the **implied reporting rate**: GHO reported cases divided by GBD modelled incidence. The analysis looks at how that rate differs between countries and how much it changes over time within each country.

Outputs:

- **`report.pdf`** is the write-up, rendered from `report.qmd`.
- **`calibration_targets.pdf`** applies the comparison to the 117 VIMC countries and proposes calibration targets and a reporting-rate approach for DTPBoost, with open questions for the calibration discussion. It is rendered from `calibration_targets.qmd`.
- **`explorer.html`** is an interactive companion. Download it and open it in a web browser; it needs an internet connection to load its charting library. It has three views:
  - the reported-vs-modelled scatter for any disease and year, with every country named on hover and a sortable table;
  - global totals broken down by country;
  - a profile for each country, with both sources over time.

## Running

The pipeline uses [targets](https://docs.ropensci.org/targets/). From the project root:

```r
targets::tar_make()        # build everything, including report.pdf
targets::tar_visnetwork()  # view the dependency graph
targets::tar_read(cause_summary)  # read any result
```

Only out-of-date targets are rebuilt. GHO data are re-downloaded when the cached copy is more than 30 days old (`GHO_MAX_AGE` in `_targets.R`). To add GBD years, drop another Results Tool export (`IHME-GBD_*.csv`) into `data/raw/gbd/` and run `tar_make()` again; the files are tracked, so everything downstream updates.

| Path | Contents |
|---|---|
| `_targets.R` | Pipeline definition and analysis settings (`MIN_MODELLED_CASES`, `MIN_YEARS_WITH_RATE`) |
| `R/data_gho.R`, `R/data_gbd.R` | Download / read and clean each source |
| `R/merge.R` | Join sources, flag known reporting issues, compute the reporting rate |
| `R/analysis.R` | Variability, disagreement ranking, DTP3 association, trends |
| `R/country_detail.R` | Country-level classification, "silent" and over-reporting countries, contributions to global totals |
| `R/plots.R`, `R/utils.R` | Figure functions, palette and theme |
| `R/calibration.R` | VIMC-country subset: WHO completeness, data tiers, diphtheria burstiness, GBD floor years, reporting rates, figures for `calibration_targets.qmd` |
| `R/explorer.R`, `explorer/template.html` | Builds `explorer.html` from the template with the pipeline's data embedded |
| `report.qmd`, `references.bib` | Quarto report and its bibliography; the report reads results with `tar_read()` |
| `calibration_targets.qmd` | Calibration-targets note for the VIMC countries; its targets are in the marked "VIMC calibration targets" section at the end of `_targets.R` |
| `output/figures/`, `output/tables/` | PNG figures and CSV tables written by the pipeline |
| `docs/research_prompt.md` | Prompt given to a research assistant to search the documentation and literature |
| `docs/research_brief.md` (`.docx`) | The resulting brief: how both datasets are produced and what explains each pattern, with sources |

### Requirements

- **R ≥ 4.3** with dplyr, tidyr, readr, ggplot2 (≥ 4.0), ggrepel, jsonlite, countrycode, targets, tarchetypes, quarto, knitr and kableExtra.
- **Quarto CLI ≥ 1.4.**
- **A LaTeX distribution with XeLaTeX**, for example TeX Live or TinyTeX.
- **TeX Gyre fonts** (Pagella and Heros). These ship with TeX Live; on Debian/Ubuntu, install `fonts-texgyre`.

`.Renviron` sets a UTF-8 locale so that country names such as Côte d'Ivoire render correctly.

## Data

| Source | Content | Years | Disaggregation |
|---|---|---|---|
| GBD 2023 Results Tool (manual exports, `data/raw/gbd/`) | Incidence and deaths, number and rate per 100k, with 95% UI | Incidence annual 1990-2023; deaths from 1980 | 204 countries; all ages, both sexes |
| WHO GHO API | Reported cases: diphtheria `WHS3_41`, pertussis `WHS3_43`, total tetanus `WHS3_46`, neonatal tetanus `WHS3_56`; DTP1/DTP3 coverage (WUENIC) | 1974-2025 | Country-year only (no age or sex) |

## Definitions

- **Reporting rate** = GHO reported cases / GBD modelled incidence (number), per country-year. It is computed only where GBD incidence is at least 10 cases; below that, the ratio is mostly noise.
- **Zero-report years** have a rate of 0, which has no log value. They are counted separately and are not imputed. A missing GHO value (null) is kept as missing, never treated as zero.
- **Agreement class** (country-level breakdowns and the explorer): each country-year is classed as not reported, zero reported, <1%, 1-10% or 10-99% of modelled, equal to GBD (the GBD 2023 floor, within 1%), or above GBD. This keeps country-years with fewer than 10 modelled cases.
- **Known reporting issues** are listed in `known_reporting_issues()` in `R/merge.R`:
  - India total tetanus from 2020 onwards is excluded, because from 2022 it equals the neonatal count only.
  - Pakistan pertussis 1989-1990 and China pertussis from 2017 are labelled but kept.
- **Variability** is measured on the log10 scale. Per country it is summarised as the fold range (highest / lowest non-zero rate), the SD of log10(rate) and the trend per decade, for countries with at least 4 years that have a rate. The within-country share is the fraction of the total sum of squares of log10(rate) that lies around each country's own mean.

## Caveats

The reporting rate means something different for each disease (see `docs/research_brief.md` and the report's "What explains these patterns?" section).

- **Pertussis:** GBD 2023 fits its model to WHO notifications and then scales every country to Switzerland's reporting level, which it assumes is complete. The absolute rate therefore mostly measures distance from Switzerland; Switzerland's own rate is about 100%.
- **Diphtheria:** GBD 2023 replaces its estimate with the WHO count wherever the model falls below it. For this reason 144 diphtheria country-years (9% of those with a positive WHO count) and 48 pertussis country-years sit within 1% of the WHO count; these are copies, not independent agreement. Diphtheria incidence is otherwise derived from deaths divided by a case-fatality ratio.
- **Tetanus:** GBD derives incidence from deaths divided by a case-fatality ratio, with no notification floor. A WHO count above GBD's estimate is therefore not over-reporting in itself; in high-income settings with few deaths the notification is probably the better count.
- **Definitions:** GHO "Total tetanus" includes neonatal tetanus and is compared with GBD "Tetanus" (all ages, including neonatal).
