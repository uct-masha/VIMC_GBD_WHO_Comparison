# Research brief: how DTP disease data are collected, and whether our GBD vs WHO discrepancies are explained anywhere

## Context

I am comparing two sources of disease burden data for **diphtheria, tetanus and pertussis** across 204 countries, 1990–2023 (code: https://github.com/uct-masha/VIMC_GBD_WHO_Comparison):

- **GBD 2023 (IHME)**: modelled incidence and deaths, all ages, both sexes, by country and year. Downloaded from the GBD Results Tool (https://vizhub.healthdata.org/gbd-results/).
- **WHO Global Health Observatory (GHO)**: reported case counts by country and year, from the GHO OData API. Indicators:
  - `WHS3_41`: diphtheria, number of reported cases
  - `WHS3_43`: pertussis, number of reported cases
  - `WHS3_46`: total tetanus, number of reported cases (compared with GBD "Tetanus")
  - `WHS3_56`: neonatal tetanus, number of reported cases
  - `WHS4_100`: DTP3 coverage (WUENIC)

For each country-year I compute an **implied reporting rate** = WHO reported cases ÷ GBD modelled incidence. I only compute it where GBD estimates at least 10 cases. I then look at how the rate varies between countries and over time.

I want to know **how each dataset is produced**, and **whether the patterns below have already been described or explained** in official documentation, methods appendices, reports or peer-reviewed literature.

## Part A: How the data are collected and produced

Answer each question with sources.

### A1. WHO reported cases

1. **Collection route:** how do these case counts reach WHO? Cover the WHO/UNICEF Joint Reporting Form (JRF/eJRF), who completes it, how often, and how it feeds the GHO and the WHO Immunization Data portal (https://immunizationdata.who.int).
2. **Case definitions:** what definitions apply for diphtheria, pertussis, total tetanus and neonatal tetanus? Clinical, probable or laboratory-confirmed? Do countries apply them consistently? When did definitions or reporting fields change? In particular, when did "total tetanus" (including non-neonatal) start being collected, separately from neonatal tetanus?
3. **Zero vs blank:** how does the GHO distinguish a reported zero from a missing report? Are values revised after first publication?
4. **Known limitations:** what does WHO itself say about the completeness of these reports, for example in WHO vaccine-preventable disease surveillance standards, position papers or immunization summaries?

### A2. GBD 2023 modelled estimates

5. **Input data:** what does GBD use to estimate incidence for each of the three causes? Specifically:
   - Does it use WHO/JRF case notifications?
   - If so, how are they adjusted for under-reporting (completeness scaling, multipliers)?
   - What role do vital registration and verbal autopsy deaths play, and are case-fatality approaches used?
   - Is DTP3 coverage used as a covariate?
   Find the GBD 2023 methods appendices (and GBD 2021/2019 if 2023 is not yet available) for incidence/prevalence and causes of death, and quote the cause-specific sections.
6. **Tetanus definition:** how does GBD define and model tetanus? Does it include neonatal tetanus, and could its definition differ from WHO's "total tetanus"?
7. **COVID-19 years:** how did GBD handle 2020–2021 for pertussis? Was the drop in estimated incidence modelled from notifications, from mobility or contact covariates, or something else?
8. **Notifications taken as given:** are there settings where GBD treats notifications as complete, so that its estimates equal reported cases?

## Part B: Are these observations documented or explained?

For each item: has anyone documented it? What is the explanation, if one exists? Give exact sources. Figures are from my analysis of the downloads described above.

1. **Pertussis is massively under-reported relative to GBD.**
   - The median country-year reporting rate is **0.6%**: Europe 2.4%, Americas 0.37%, Africa 0.23%, South-East Asia 0.17%.
   - Within a typical country, the highest year's rate is **134×** the lowest.
   - Look for published under-ascertainment multipliers for pertussis (serosurveys, capture–recapture studies) and how they compare.
2. **Tetanus reports often exceed GBD's estimate.**
   - Reports are above GBD's estimate in **12%** of country-years overall: **30%** in Europe and **19%** in the Americas.
   - Pooled 2020–2023: Uganda **3.5×**, Kenya **3.4×**, Angola **3.3×**, Central African Republic **2.4×**.
   - In the USA, reports run **1.1–1.6×** GBD every year (for example, 27 reported vs 17 modelled in 2023).
   - Is this explained by case-definition differences, by how GBD models tetanus, by over-reporting (for example, misclassified cases), or something else?
3. **Diphtheria reports often match GBD almost exactly.**
   - **8%** of country-years are within 5% of GBD's estimate overall: **19%** in Europe, **12%** in the Americas.
   - Does GBD use notifications directly in some locations?
   - Pooled 2020–2023, reports exceed GBD in Yemen (**3.1×**: 1,792 vs 581), Nigeria (**1.5×**), Ethiopia (**1.4×**), Laos (**1.4×**) and Switzerland (**1.3×**). Are these documented outbreaks? Did GBD's model under-estimate them?
4. **Abrupt breaks in single countries.**
   - **India, tetanus:** 7,071 reported in 2019, 1,361 in 2020, 65 in 2022 and 62 in 2023, while GBD declines smoothly from about 9,000 to 5,300. Did India change what it reports (for example, neonatal-only vs total tetanus) or its surveillance system?
   - **Pakistan, pertussis:** 24,545 reported in 1990, then 140 in 1991, and about 100–180 a year since, against about 1 million modelled cases a year. What happened in 1990–1991?
5. **China, pertussis:** reports rose from 1,764 (2010) to 41,124 (2023), while GBD's estimate fell from 1.1 million to 0.65 million. That takes the reporting rate from 0.16% to 6.3%. Is this attributed to changes in diagnostics (PCR), surveillance or case definitions, to genuine resurgence, or to macrolide-resistant *B. pertussis*?
6. **Brazil, pertussis:** reports fell from 8,338 (2014) to 222 (2023), while GBD's estimate rose from 164,000 to 588,000. Is this documented? Possible causes include a post-2014 decline after maternal Tdap, surveillance disruption, or a GBD modelling artefact.
7. **Global pertussis, 2020–2024.**
   - WHO reported totals: about 150,000–170,000 a year before the pandemic, **70,000 (2020)**, **31,000 (2021)**, **163,000 (2023)** and **941,900 (2024)**.
   - GBD's estimates fall from 19.5 million (2019) to **9.7 million (2020)** and **7.2 million (2021)**, then rebound to **19.3 million (2022)**.
   - Are the 2024 surge and the GBD pandemic dip both documented, and how are they explained?
8. **Global diphtheria resurgence:** WHO reported totals rose from about 4,600 (2010) to 23,000 (2019) and **30,200 (2025)**. Which outbreaks and countries drive this?
9. **Changes don't line up year to year.** Within countries, year-to-year changes in reported cases barely correlate with changes in GBD's estimates (correlation 0.20 for diphtheria, 0.16 for pertussis, 0.02 for tetanus). Has anyone shown that GBD's DTP incidence estimates are smooth compared with notifications, or examined this disconnect?
10. **DTP3 coverage.** The reporting rate is higher in countries with higher DTP3 coverage (Spearman 0.32–0.42 across countries), but within a country the rate barely moves with coverage over time (0.03–0.23). Has the link between coverage, surveillance quality and reporting completeness been described?
11. **Persistent zero reporting.** 47 countries reported **zero** pertussis cases in every year from 2020 to 2023, even though GBD estimates at least 10 cases a year in each (for example Angola, Botswana, Bhutan and Cabo Verde). Is zero-reporting for pertussis discussed as a surveillance gap?

## Part C: Prior comparisons

12. Find any published comparison of **GBD estimates vs WHO-reported cases** (or vs other burden models) for diphtheria, tetanus, pertussis or other vaccine-preventable diseases. Include work from or citing the **Vaccine Impact Modelling Consortium (VIMC)**. For example, check how VIMC burden estimates for DTP relate to GBD and to WHO data, and whether VIMC documents using WHO case data for calibration.
13. Find any WHO, IHME or academic commentary on reconciling the two sources.

## How to work

- **Prefer primary sources:** WHO pages and documents, GBD methods appendices (Lancet supplementary material), IHME documentation, peer-reviewed papers. Use news or secondary sources only to point to primary ones.
- **Distinguish clearly:**
  - (a) the source explicitly explains the observation;
  - (b) the source describes a mechanism that would plausibly explain it;
  - (c) your own inference.
  Never present (b) or (c) as (a).
- **Do not invent citations.** Every claim needs a URL you actually opened. Give DOIs for papers. If something is paywalled or you could only read the abstract, say so.
- **Check the GBD round.** GBD methods change between rounds, so state which round each methods statement refers to (2019, 2021 or 2023).
- **Quote briefly:** a sentence or two of key wording where the exact phrasing matters, for example case definitions and modelling choices.
- **If you find nothing on an item, say so explicitly** and list what you searched.

## Output format

1. **Summary table.** One row per item (A1–A8, B1–B11, C12–C13) with columns:
   - Item
   - Status: Explained / Plausible mechanism / Not found
   - One-line answer
   - Key source(s)
2. **Detailed findings.** For each item:
   - the answer;
   - the evidence, with quotes and URLs;
   - the GBD round, if relevant;
   - confidence;
   - open questions.
3. **Implications for my analysis.** Anything that should change how I compute or interpret the reporting rate, for example:
   - excluding countries or years with known reporting-system changes;
   - comparing GHO neonatal tetanus with a GBD neonatal estimate;
   - treating countries where GBD effectively copies notifications differently.
4. **Bibliography.** Full references with URLs or DOIs and the date you accessed each.
