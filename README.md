# DTP disease burden: GBD vs WHO GHO

Compares the burden of diphtheria, tetanus and pertussis as estimated by GBD 2023 (modelled) with reported case counts from the WHO Global Health Observatory. The main focus is the **implied reporting rate**: GHO reported cases divided by GBD modelled incidence. The analysis looks at how that rate differs between countries and how much it changes over time within each country.

The write-up is `report.pdf`, rendered from `report.qmd`.

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
| `R/merge.R` | Join sources and compute the reporting rate |
| `R/analysis.R` | Variability, disagreement ranking, DTP3 association, trends |
| `R/plots.R`, `R/utils.R` | Figure functions, palette and theme |
| `report.qmd` | Quarto report; reads results with `tar_read()` |
| `output/figures/`, `output/tables/` | PNG figures and CSV tables written by the pipeline |
| `docs/research_prompt.md` | Brief for a literature/documentation search on how the data are produced and what explains the discrepancies |

### Requirements

- **R ≥ 4.3** with dplyr, tidyr, readr, ggplot2, jsonlite, countrycode, targets, tarchetypes, quarto, knitr and kableExtra.
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
- **Zero-report years** have a rate of 0, which has no log value. They are counted separately and are not imputed.
- **Variability** is measured on the log10 scale. Per country it is summarised as the fold range (highest / lowest non-zero rate), the SD of log10(rate) and the trend per decade, for countries with at least 4 years that have a rate. The within-country share is the fraction of the total sum of squares of log10(rate) that lies around each country's own mean.

## Caveats

- GBD uses WHO case notifications as an input for at least some of these causes, so the two sources are not independent. This is most visible for diphtheria: many country-years have reported cases within 5% of modelled incidence.
- GHO "Total tetanus" includes neonatal tetanus. It is compared with GBD "Tetanus" (all ages).
