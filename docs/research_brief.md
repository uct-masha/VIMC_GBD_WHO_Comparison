# DTP data: GBD 2023 vs WHO reported cases — research brief

Oct 22, 2026 · @Jared

Most of the GBD-vs-WHO discrepancies follow from documented GBD 2023
modelling choices. Pertussis is scaled to Switzerland's reporting level.
Diphtheria and tetanus incidence equal deaths ÷ CFR. GBD 2023 replaces
its diphtheria and pertussis estimates with the WHO count wherever the
model falls below it. Two further patterns are WHO data artefacts:
India's tetanus series and null-as-zero reporting.

## Summary

| Item | Status | One-line answer | Key source(s) |
|----|----|----|----|
| A1.1 Collection route | Explained | Annual national aggregates via eJRF (since 1998; electronic since 2021), released each July; countries can revise any year | [WHO JRF page](https://who.int/teams/immunization-vaccines-and-biologicals/immunization-analysis-and-insights/global-monitoring/who-unicef-joint-reporting-process) |
| A1.2 Case definitions | Explained (start year of total tetanus: not found) | Clinical cases count for all four. Minimum standards differ: pertussis sentinel, non-neonatal tetanus aggregate | [WHO VPD standards 2018](https://www.who.int/publications/m/item/vaccine-preventable-diseases-surveillance-standards-non-neonatal-tetanus) |
| A1.3 Zero vs blank | Explained (by data inspection) | GHO API stores missing reports as null and zero as 0; revisions are allowed, with no version log | [GHO API](https://ghoapi.azureedge.net/api/WHS3_43) |
| A1.4 Completeness | Explained | WHO calls diphtheria and tetanus counts underestimates and pertussis data in developing countries "less robust" | WHO standards |
| A2.5 GBD inputs | Explained | Pertussis: JRF regression with Switzerland random effect. Diphtheria and tetanus: deaths ÷ CFR. DTP3 is a covariate in all three | GBD 2023 appendices |
| A2.6 Tetanus definition | Explained | GBD tetanus = A33–A35 incl. neonatal, death-derived. Same concept as WHO total, different source | GBD 2023 nonfatal appendix |
| A2.7 COVID-19 pertussis | Explained | Dip driven by a mask-use covariate plus COVID-inclusive DTP3; not notifications or mobility | GBD 2023 appendix; [Nat Med 2026](https://www.nature.com/articles/s41591-026-04660-8) |
| A2.8 Notifications as given | Explained | New in GBD 2023: floor at JRF count for pertussis (60 location-years) and diphtheria; not tetanus | GBD 2023 appendix; Nat Med 2026 |
| B1 Pertussis under-reporting | Explained | Level set by the Switzerland reference random effect. Published clinical multipliers 3–33× vs GBD-implied about 170× | Nat Med 2026; [Dai 2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11596255/); [Sutter 1992](https://pubmed.ncbi.nlm.nih.gov/1309387/) |
| B2 Tetanus reports exceed GBD | Plausible mechanism | Incidence = deaths ÷ CFR with no notification floor; CFRs raised in GBD 2023 | GBD 2023 appendix |
| B3 Diphtheria matches | Explained | GBD 2023 notification floor. Yemen, Nigeria and Switzerland outbreaks documented; Ethiopia and Laos not found | GBD appendix; [EMRO](https://www.emro.who.int/yemen/news/epidemiological-situation-in-yemen-diphtheria.html); [PAMJ 2025](https://www.panafrican-med-journal.com/content/series/51/1/29/full) |
| B4 India and Pakistan breaks | Data artefact (India), not found (Pakistan) | India's total tetanus equals neonatal tetanus from 2022. Pakistan's collapse starts in 1989 | [GHO API](https://ghoapi.azureedge.net/api/WHS3_46) |
| B5 China pertussis | Explained | PCR added 2017, new criteria in 2024 (26.5× jump in Chongqing), plus genuine resurgence and macrolide resistance | [Chongqing 2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12832240/) |
| B6 Brazil pertussis | Partly documented | Post-2014 decline linked to cyclicity and maternal dTpa. GBD rise fits DTP3 falling from 93% to 68% | [Barros 2019](https://pmc.ncbi.nlm.nih.gov/articles/PMC7012156/); GHO |
| B7 Global pertussis 2020–24 | Explained | 2024 surge: post-COVID immunity gap plus PCR testing. GBD dip: mask covariate | [ECDC 2024](https://www.ecdc.europa.eu/en/publications-data/pertussis-annual-epidemiological-report-2024); Nat Med 2026 |
| B8 Diphtheria resurgence | Partly documented | 2023–25 driven by Nigeria, Niger, Guinea, Somalia and India; 2018–19 by India, Ethiopia and Yemen | GHO; PAMJ 2025 |
| B9 Year-to-year disconnect | Partly documented | GBD notes low concordance (r = −0.10). Smoothness is inherent to the model structure | Nat Med 2026; [npj Vaccines 2026](https://www.nature.com/articles/s41541-026-01479-9) |
| B10 DTP3 and reporting rate | Plausible mechanism | The cross-country link is partly built into GBD's DTP3 covariate; surveillance sensitivity tracks income | npj Vaccines 2026; Chongqing 2025 |
| B11 Persistent zeros | Data artefact (mostly) | Several example zeros are nulls in the GHO; sentinel pertussis surveillance can't support true zeros | GHO API; WHO pertussis standard |
| C12 Prior comparisons | Found (pertussis only) | Two 2026 pertussis comparisons. The EPI 50-year analysis used GBD 2021 for DTP; VIMC DTP not found | Nat Med 2026; npj Vaccines 2026; [Shattock 2024](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(24)00850-X/fulltext) |
| C13 Reconciliation commentary | Partly found | IHME: JRF is not a validation target. No diphtheria or tetanus reconciliation found | Nat Med 2026 |

## Part A1: How WHO reported cases are produced

WHO case counts are national aggregate totals that each country's
immunization programme types into the annual WHO/UNICEF electronic Joint
Reporting Form (eJRF). WHO does not adjust them for completeness, and
countries can revise past years at any time.

### A1.1 Collection route

- **What and who.** WHO and UNICEF have jointly collected immunization
  data "through a standard questionnaire (the Joint Reporting Form) sent
  to all Member States" since 1998. In 2021 this became the cloud-based
  eJRF. It "is completed by national immunization programme staff and in
  collaboration with WHO and UNICEF country office counterparts"
  ([WHO/UNICEF joint reporting
  process](https://who.int/teams/immunization-vaccines-and-biologicals/immunization-analysis-and-insights/global-monitoring/who-unicef-joint-reporting-process)).

- **How often.** Data are annual, for the calendar year
  (January–December), "and countries may update prior years' data at any
  time" (same page).

- **Publication.** The portal pages for each disease say counts "are
  collected annually through the WHO/UNICEF Joint Reporting Form" and
  that "Global and regional aggregate data are released annually in July
  and updated thereafter as country data are received" ([tetanus
  page](https://immunizationdata.who.int/global/wiise-detail-page/tetanus-reported-cases-and-incidence);
  [pertussis
  page](https://immunizationdata.who.int/global/wiise-detail-page/pertussis-reported-cases-and-incidence)).

- **Link to the GHO.** None of the WHO pages I read describes how GHO
  indicators WHS3_41/43/46/56 are populated. In practice they carry the
  same JRF series. The GHO API rows for India's WHS3_46 carry different
  Date stamps: 2025-07-14 for most years and 2026-07-14 for the 1995,
  1996 and 2025 rows. That fits rows being republished at each July
  release. This is my reading of the [GHO
  API](https://ghoapi.azureedge.net/api/WHS3_46), not a documented rule.

- **Pre-1998 years.** The GHO has values before the JRF existed; India's
  WHS3_46 starts in 1974. WHO does not document where those early values
  came from (status: not found).

### A1.2 Case definitions (WHO surveillance standards, 2018)

| Disease | Minimum surveillance standard | What a country should count | Lab confirmation needed? |
|----|----|----|----|
| [Diphtheria](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-04-diphtheria-r2.pdf) | National, facility-based, case-based | "Total diphtheria cases are the sum of laboratory-confirmed, epidemiologically linked and clinically compatible cases" | No. Clinically compatible cases count |
| [Pertussis](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-16-pertussis-r2.pdf) | Minimum is "sentinel hospital-based, case-based surveillance, with lab confirmation limited to children \< 5" | Laboratory-confirmed, epidemiologically linked and "possible" (clinical) cases | No. Clinical "possible" cases count |
| [Neonatal tetanus](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-14-neonataltetanus-r2.pdf) | Nationwide, case-based | Clinically confirmed cases aged 3–28 days. Classification is "entirely clinical" | No |
| [Non-neonatal tetanus](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-15-nonneonataltetanus-r2.pdf) | "Nationwide, aggregate surveillance with routine reporting from inpatient facilities" | "Tally only probable and confirmed inpatient cases" | No. Physician-confirmed or probable |

- **Consistency between countries.** The standards set the minimum, but
  the 2018 chapters give no count of countries that meet it. The
  2023–2024 African diphtheria review found that "Some countries report
  only suspected cases" and that "There are discrepancies in suspected
  cases reported in eJRF by few countries" ([Bita Fouda et al.
  2025](https://www.panafrican-med-journal.com/content/series/51/1/29/full)).
  In that review, 94.6% of classified cases were clinically compatible.

- **Total vs neonatal tetanus.** The non-neonatal chapter asks for
  neonatal and non-neonatal cases to be reported "separately … through
  the Joint Reporting Form". It also says "approximately 13,500 tetanus
  cases were reported in 2016 through the \[JRF\], with 85% of cases
  occurring after the neonatal period." So WHS3_46 should equal neonatal
  plus non-neonatal tetanus.

- **When total tetanus started.** No WHO page I read gives a start year
  for the total-tetanus field, and the 2018 chapter is silent. The eJRF
  page says older indicator lists are available from vpdata@who.int
  (status: not found).

### A1.3 Zero vs blank, and revisions

- **In the GHO API, a missing report is a row with a null value; a
  reported zero is the number 0.** India's WHS3_46 rows for 1995 and
  1996 have NumericValue: null ([GHO
  API](https://ghoapi.azureedge.net/api/WHS3_46)). Check that your
  download step keeps nulls as NA and does not turn them into zeros.

- **What zero means.** The surveillance standards ask sites to report
  "even if there are zero cases". WHO does not say whether a JRF zero
  means "surveillance found none" or "not collected" (status: not
  found).

- **Revisions.** Countries "may update prior years' data at any time",
  and the portal says historical data "are updated and made available as
  data is received". No version history is published, so the download
  date matters for reproducibility.

### A1.4 What WHO says about completeness

- **Diphtheria:** reported cases "are likely an underestimation of the
  real burden of disease due to under-reporting" ([2018
  standard](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-04-diphtheria-r2.pdf)).

- **Tetanus:** the 2016 JRF total of about 13,500 "is likely an
  underestimate; true tetanus incidence is uncertain." WHO also notes
  the "absence of reliable global estimates of non-NT cases and deaths"
  (non-neonatal tetanus chapter).

- **Pertussis:** "In developing countries … pertussis surveillance data
  is less robust". The chapter adds that "many pertussis deaths might
  occur outside of health care settings, and would be missed by
  facility-based surveillance" ([2018
  standard](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-16-pertussis-r2.pdf)).

- **Neonatal tetanus:** "Because most neonatal deaths occur in remote
  areas, which might lead to underreporting, neonatal tetanus deaths are
  estimated using mathematical models" ([Jones et al., MMWR
  2024](https://www.cdc.gov/mmwr/volumes/73/wr/mm7328a1.htm)).

## Part A2: How GBD 2023 estimates are produced

GBD 2023 builds the three causes in three different ways. Only pertussis
incidence is modelled from WHO notifications. Diphtheria and tetanus
incidence are back-calculated as modelled deaths ÷ a modelled
case-fatality ratio (CFR). Since GBD 2023, diphtheria and pertussis are
floored at the JRF notification count; tetanus is not.

Sources: GBD 2023 nonfatal appendix ([GBD 2023 Disease, Injury and Risk
Factor Collaborators, Lancet 2025, appendix
1](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(25)01637-X/fulltext);
diphtheria pp 479–483, pertussis pp 1100–1102, tetanus pp 1204–1208) and
the cause-of-death appendix ([GBD 2023 Causes of Death Collaborators,
Lancet 2025, appendix
1](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(25)01917-8/fulltext);
diphtheria pp 440–441, pertussis pp 669–671, tetanus pp 711–712). Page
numbers are as printed in the appendices. I read both appendices in full
text. The pertussis method is also set out in the GBD 2023 pertussis
capstone ([Nature Medicine, 21 Oct
2026](https://www.nature.com/articles/s41591-026-04660-8)). Every
statement below refers to the GBD 2023 round unless marked otherwise.

### A2.5 Input data, by cause

|  | Pertussis | Diphtheria | Tetanus |
|----|----|----|----|
| How incidence is made | Mixed-effects log-linear regression fitted to **WHO JRF notifications**, plus UK data from 1942 | **Deaths ÷ CFR**. The CFR comes from DisMod-MR with HAQ Index as a covariate | **Deaths ÷ CFR**. The CFR comes from DisMod-MR with HAQ Index as a covariate |
| Uses JRF notifications? | Yes, as the primary input | Only as a floor (new in GBD 2023) | No |
| Under-reporting adjustment | Swaps each country's random effect for **Switzerland's** (see below) | None needed, because incidence is derived from deaths | None |
| How deaths are made | CODEm in 64 data-rich locations. Elsewhere incidence × CFR (140 locations) | CODEm in data-rich locations. Elsewhere a negative binomial cause-fraction model | CODEm everywhere: under-1 and over-1, data-rich and global models |
| DTP3 covariate | 5-year rolling mean of COVID-inclusive DTP3, used in the incidence model | 5-year lagged COVID-inclusive DTP3, used in the death models | 5-year lagged COVID-inclusive DTP3, plus TT coverage and in-facility delivery for under-1s |
| COVID-19 handling | Mask-use covariate (new in 2023) | DTP3 covariate. The custom model drops post-2019 cause fractions | DTP3 covariate |

**Pertussis.** "Our primary input data are the pertussis case
notifications released annually by the World Health Organization (WHO)
through the Joint Reporting Form (JRF)." The GBD reference case
definition is "Cases reported by national pertussis surveillance systems
to WHO. Cases may be laboratory-confirmed, clinically diagnosed, or
epidemiologically linked" (nonfatal appendix p 1100). The model is:

\ln(\text{incidence}\_{ij}) = \beta_0 + \beta_1
\ln(1-\text{DTP3}\_{ij}) + \beta_2 \ln(1-\text{masking}\_{ij}) + u_j +
e\_{ij}

The under-reporting correction is the key choice. "As in GBD 2021, we
corrected for pertussis under-reporting by substituting the
location-specific random effect with the random effect obtained for
Switzerland … This approach assumes no under-reporting in Switzerland
and a stable attack rate across unvaccinated populations" (p 1101).

- **What this implies.** For a country j, GBD predicted incidence
  divided by the fitted value of its own notifications is about
  exp(u_Switzerland − u_j). One country-level constant therefore sets
  the reporting rate (my algebra, from the stated model).

- **How sensitive it is.** The capstone reports that using the mean of
  the top-five random effects instead of Switzerland's would multiply
  the scaling by 0.39. With no reference (RE = 0) it would multiply by
  0.0069, and these alternatives are "not alternative GBD model runs"
  ([Nature Medicine
  2026](https://www.nature.com/articles/s41591-026-04660-8)).

- **Deaths.** CODEm runs in 64 locations. In the other 140, deaths =
  incidence × CFR, with the CFR from a negative binomial model on HAQ
  fitted to literature data. The natural-history path covers all 46
  sub-Saharan African locations, all five South Asian ones and 20 of 21
  in north Africa and the Middle East. So deaths there inherit the
  Switzerland scaling.

**Diphtheria.** "Incidence was calculated as the mortality rate divided
by the case-fatality ratio" (p 481).

- The CFR review for GBD 2023 kept only studies with complete case
  ascertainment or population-representative reporting. This "led to far
  lower CFR estimates compared to previous rounds" (p 482), so incidence
  is higher than in GBD 2021 for the same deaths.

- Deaths come from CODEm in data-rich locations. Elsewhere a negative
  binomial model of cause fractions on DTP3 and HAQ is used, with
  post-2019 data excluded (CoD appendix p 441).

**Tetanus.** "Incidence rates were calculated by dividing GBD 2023
mortality rate estimates by the predicted CFR ratio" (p 1206).

- Deaths come only from CODEm, fed by vital registration, verbal autopsy
  and surveillance data, with separate under-1 and over-1 models (CoD
  appendix p 711).

- No case notifications enter the tetanus model.

- The new CFR review raised CFRs in south Asia and north Africa and the
  Middle East substantially. A higher CFR means lower incidence for the
  same deaths.

**GBD 2021 differences.** COVID-19 was handled by post-hoc adjustment of
COVID-free counterfactual estimates for pertussis, and diphtheria
mortality used COVID-free coverage with post-hoc adjustment. There was
no notification floor. The Switzerland random-effect device and the
incidence = deaths ÷ CFR approach for diphtheria and tetanus were
already in place.

### A2.6 Tetanus definition

GBD tetanus covers ICD-10 A33–A35.0 (A33 is neonatal tetanus), so it
includes neonatal and non-neonatal tetanus. Neonatal deaths are modelled
in separate under-1 CODEm models, and "All tetanus cases are assumed to
be severe" (p 1204–1206). Conceptually this matches WHO's "total
tetanus" (WHS3_46).

The practical difference is the source.

- GBD incidence is death-driven: VR deaths ÷ CFR.

- WHO counts are clinically diagnosed inpatient notifications.

The two can diverge wherever registered tetanus deaths are few, CFRs are
high, or notifications include non-fatal cases that GBD's CFR does not
reflect. To my knowledge, GBD publishes neonatal tetanus only inside the
"Tetanus" cause, with no separate cause in the Results Tool hierarchy
(not verified against the hierarchy file). You may be able to
approximate it with age groups under 28 days (status: plausible,
untested).

### A2.7 Pertussis in 2020–2021

The dip is modelled, not observed. In GBD 2023 the incidence model has a
"masking covariate to account for the impact of COVID-19 mitigation
strategies on the incidence of pertussis." It also uses COVID-inclusive
DTP3 (nonfatal appendix p 1101). No mobility or contact covariate is
used, and the capstone says the mask variable "could not capture other
pandemic-related changes such as school closures, mobility restrictions,
healthcare seeking, diagnostic disruption or reporting delays" ([Nature
Medicine 2026](https://www.nature.com/articles/s41591-026-04660-8)).

The capstone calls 2020–2021 "anomalously low pandemic-period estimates"
and reports a 102.6% rise in incidence from 2020 to 2023. The 2022
rebound in your download (19.3 million) is consistent with the mask
covariate falling back. That last point is my inference.

### A2.8 Where GBD equals notifications

This is documented for two of the three causes, both new in GBD 2023.

- **Pertussis:** "we replaced our modelled estimates with case
  notifications when our modelled results were lower than notified
  cases" (p 1101). According to the capstone this affected **60
  location-years in 15 locations** (0.65% of 1980–2024 country-years),
  "concentrated in the high-income super-region" ([Nature Medicine
  2026](https://www.nature.com/articles/s41591-026-04660-8),
  Supplementary Table 11).

- **Diphtheria:** "For location-years where modelled incidence was lower
  than JRF case notifications, we replaced modelled estimates with case
  notifications and calculated uncertainty intervals by sampling from a
  posterior distribution centered around this mean" (p 481–482).

- **Tetanus:** no floor.

## Part B: Are your observations documented?

Most of your patterns follow from how GBD 2023 is built, rather than
from anything new in the data. The three biggest:

- Pertussis is scaled up to Switzerland's reporting level.

- Diphtheria and tetanus incidence come from deaths ÷ CFR.

- GBD 2023 floors pertussis and diphtheria at the notification count.

Two patterns turn out to be artefacts of the WHO data itself:

- India's tetanus break: since 2022 India's "total tetanus" equals its
  neonatal tetanus count.

- Most of the "persistent zeros": GHO holds them as blanks (null), not
  zeros.

Each item is labelled **(a)** the source explicitly explains it, **(b)**
a source describes a mechanism that would plausibly explain it, or
**(c)** my own inference or check.

### B1. Pertussis is massively under-reported relative to GBD

**Status: Explained (a) for the level; plausible (b) for the
variation.**

- **The level is set by GBD's design.** GBD corrects under-reporting by
  assigning every country Switzerland's random effect, which "assumes no
  under-reporting in Switzerland" (GBD 2023 nonfatal appendix p 1101).
  Every other country's implied reporting rate is therefore roughly
  exp(u_j − u_Switzerland). Switzerland has the largest random effect,
  so all rates are below Switzerland's by construction (c).

- **GBD says the scaling is uncertain.** The capstone states that
  "absolute magnitude of the incidence estimates is also sensitive to
  the choice of Switzerland as the reference". It adds that the random
  effect "may capture not only incomplete ascertainment but also
  residual differences in transmission, population structure,
  vaccination history, diagnostic intensity, reporting requirements and
  healthcare seeking" ([Nature Medicine
  2026](https://www.nature.com/articles/s41591-026-04660-8)).

- **GBD's own aggregate comparison.** 163,454 reported cases vs 18.9
  million estimated in 2023, an aggregate ratio of about 0.9% (c), close
  to your 0.6% median.

- **Within-country swings (134×).** These come from notifications
  swinging with epidemic cycles, outbreaks and reporting changes while
  GBD stays smooth (see B9). The capstone says the model did not
  "directly estimate the effects of … the periodicity of pertussis
  epidemics" (b).

**Published under-ascertainment estimates (none is a global
multiplier):**

| Study | Setting | Method | Ratio (true ÷ reported) |
|----|----|----|----|
| [Sutter et al. 1992, JAMA](https://pubmed.ncbi.nlm.nih.gov/1309387/) (PMID 1309387; abstract only) | USA 1985–88 | Capture–recapture of hospitalizations and deaths | Hospitalization reporting 32% complete, deaths 33%, so about 3× for severe disease |
| [Dai et al. 2024, Microorganisms](https://pmc.ncbi.nlm.nih.gov/articles/PMC11596255/) (doi:10.3390/microorganisms12112186) | Yiwu, Zhejiang, China, 2021–22 | Active population surveillance with PCR or culture | About 33×: 108.3 vs 3.24 per 100,000 |
| [Chen et al. 2022, Front Public Health](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2022.1054617/full) (doi:10.3389/fpubh.2022.1054617) | Jiangsu, China, ages 15+, 2018–21 | Anti-PT IgG serosurvey | Infection incidence 18 per 100 a year; "a high rate of under-reporting". Infection, not disease, so not comparable to GBD's case definition |
| GBD 2023 implied (your data) | 204 countries | Model | Median 1/0.006, about 170×; Europe about 40×; Africa about 430× (c) |

GBD's implied multipliers sit between the clinical-disease studies
(3–33×) and serological infection estimates. The [ECDC 2024
report](https://www.ecdc.europa.eu/en/publications-data/pertussis-annual-epidemiological-report-2024)
says the burden "in Europe is still considerably underestimated" but
gives no multiplier. I could not open Yeung et al. 2017 (the WHO
pertussis model) or Crowcroft et al. 2003; both sites refused automated
access.

### B2. Tetanus reports often exceed GBD's estimate

**Status: Plausible mechanism (b).** No source discusses GBD-vs-WHO
tetanus specifically.

- **GBD does not anchor tetanus to notifications.** Incidence = CODEm
  deaths ÷ DisMod CFR, and the notification floor that diphtheria and
  pertussis received in GBD 2023 was not applied (nonfatal appendix pp
  1204–1206). Wherever reported cases × the true CFR exceed GBD's
  modelled deaths, reports will exceed GBD.

- **CFR updates push incidence down.** The GBD 2023 tetanus CFR review
  raised CFRs "substantially" in south Asia and north Africa and the
  Middle East, and a higher CFR means lower incidence for the same
  deaths.

- **WHO counts are looser.** WHO counts "probable and confirmed
  inpatient cases". A probable case is clinical only, with no physician
  confirmation ([non-neonatal tetanus
  standard](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-15-nonneonataltetanus-r2.pdf)).
  Some over-counting through misclassification is possible, but no
  source quantifies it.

- **USA (27 reported vs 17 modelled, 2023).** This fits incidence
  derived from a handful of VR tetanus deaths divided by a CFR (b/c). US
  surveillance captures non-fatal cases directly, so here the
  notification is probably the better count.

- **Uganda, Kenya, Angola, CAR (2.4–3.5×).** GBD deaths in these
  countries rest on verbal autopsy and covariates. A high CFR estimate
  for low-HAQ settings would make GBD incidence low (b). I found no
  country-specific documentation.

### B3. Diphtheria reports often match GBD almost exactly

**Status: Explained (a).**

New in GBD 2023: "For location-years where modelled incidence was lower
than JRF case notifications, we replaced modelled estimates with case
notifications" (nonfatal appendix pp 481–482). Your 8% of country-years
within 5% (19% in Europe) are almost certainly these floored
location-years. The exact count is not published for diphtheria; for
pertussis it is 60 location-years.

**Yet some reports exceed GBD (status: partly documented).** With a
floor in place, GBD should never fall below the JRF count it used.
Excesses therefore point to JRF values added or revised after GBD's data
freeze (c). Some excesses in country-years where GBD estimates under 10
cases are also below your threshold. Check the GBD 2023 input data in
the [GBD Sources Tool](https://ghdx.healthdata.org/gbd-2023/sources/)
for these location-years.

| Country | Documented outbreak? | Note |
|----|----|----|
| Yemen (3.1×) | Yes, since 2017 | The EMRO monitor gives 7,332 clinically diagnosed cases from week 33 of 2017 to week 30 of 2021 ([WHO EMRO](https://applications.emro.who.int/docs/EPI/2021/2224-4220-2021-1436-eng.pdf)). EMRO counted 1,671 suspected cases to 14 Oct 2023 ([WHO EMRO 2023](https://www.emro.who.int/yemen/news/epidemiological-situation-in-yemen-diphtheria.html)). The GHO shows Yemen at 1,516 in 2021 but under 300 in 2022 and 2023, so the JRF series is inconsistent with the outbreak reports (c, [GHO API](https://ghoapi.azureedge.net/api/WHS3_41)) |
| Nigeria (1.5×) | Yes, 2022–2025 | 27,078 suspected cases from week 19 of 2022 to week 6 of 2024, of which 16,603 were confirmed, mostly clinically compatible ([ReliefWeb/WHO](https://reliefweb.int/disaster/ep-2023-000034-nga)). JRF: 14,163 (2023), 10,595 (2024), 15,273 (2025) |
| Ethiopia (1.4×) | Not found | JRF shows 7,184 (2019), 5,267 (2020), 4,453 (2021) and 3,946 (2022). I found no outbreak report |
| Laos (1.4×) | Not found | Searched; no primary source opened |
| Switzerland (1.3×) | Yes, 2022 asylum centres | Mostly **cutaneous** cases and carriers in minors from Afghanistan ([Brockhaus et al. 2024](https://www.ssph-journal.org/journals/international-journal-of-public-health/articles/10.3389/ijph.2024.1606791/full); [Kofler et al. 2022](https://eurosurveillance.org/content/10.2807/1560-7917.ES.2022.27.44.2200811)) |

For Switzerland, a plausible mechanism (b) is that GBD's diphtheria is
respiratory, and its CFR review excluded "non-respiratory diphtheria".
WHO counts may include cutaneous cases.

### B4. Abrupt breaks in single countries

**India, tetanus. Status: data artefact confirmed (c); not documented by
WHO.**

| Year | Total tetanus (WHS3_46) | Neonatal tetanus (WHS3_56) |
|------|-------------------------|----------------------------|
| 2019 | 7,071                   | 35                         |
| 2020 | 1,361                   | 162                        |
| 2021 | 1,240                   | 81                         |
| 2022 | 65                      | 65                         |
| 2023 | 62                      | 62                         |
| 2024 | 70                      | 70                         |
| 2025 | 38                      | 38                         |

Source: [GHO API](https://ghoapi.azureedge.net/api/WHS3_46), read 22 Oct
2026. From 2022, India's "total" equals its neonatal count. Non-neonatal
tetanus is effectively unreported in the JRF series. The 2022 NT value
of 65 matches [MMWR
2024](https://www.cdc.gov/mmwr/volumes/73/wr/mm7328a1.htm). I found no
WHO or Indian document explaining the change, so treat India total
tetanus from 2020 onward as not comparable.

**Pakistan, pertussis. Status: not found (WHO data confirm the series is
erratic).** The GHO series is 1986: 53,835; 1987: 47,676; 1988: 62,382;
**1989: 1,324**; **1990: 24,545**; **1991: 140**; then 103–473 a year to
2000 ([GHO API](https://ghoapi.azureedge.net/api/WHS3_43)). The collapse
begins in 1989, not 1991, and 1990 looks like an isolated revert to the
old system. That suggests a change of reporting source or definition
around 1989 (c). I found no documentation. The series is pre-JRF (1998),
so WHO may hold provenance notes (vpdata@who.int).

### B5. China, pertussis

**Status: Explained (a) as a mix of diagnostic and case-definition
change plus genuine resurgence.**

- **Diagnostic criteria changed twice.** A 2017 revision added PCR as
  accepted confirmation. The 2023 national protocol, effective in the
  2024 surveillance year, broadened clinical criteria and molecular
  confirmation. In Chongqing the 2024 revision was associated with "an
  immediate 26.5-fold increase in pertussis notifications" (IRR 26.46).
  The authors read the surge as "both substantially enhanced
  surveillance sensitivity and a genuine underlying increase"
  ([Chongqing 2013–2024, Front Public Health 2025,
  doi:10.3389/fpubh.2025.1620429](https://pmc.ncbi.nlm.nih.gov/articles/PMC12832240/)).

- **Growth before 2024.** National notified incidence rose from 0.25 per
  100,000 (2014) to 2.11 (2019) and 2.89 (2023) ([Dai et al.
  2024](https://pmc.ncbi.nlm.nih.gov/articles/PMC11596255/)). A Jinan
  hospital study credits wider PCR use after COVID-19 and a shift "from
  passive to active monitoring" ([Liu et al. 2025,
  doi:10.3389/fpubh.2025.1657953](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1657953/pdf)).

- **Macrolide resistance.** In that hospital, the A2047G resistance
  mutation rose from 0.24% (2022) to 42.86% (2024). The authors call it
  "a key driver", but they did no virulence typing (b).

- **Why GBD diverges.** GBD's China estimate falls because it is driven
  by DTP3 coverage and a fixed random effect, so ascertainment changes
  go into the residual. Your 0.16% to 6.3% rise is consistent with
  improved ascertainment (b/c).

### B6. Brazil, pertussis

**Status: Partly documented. The notification fall is documented (a,
partially); the GBD rise has a plausible mechanism (b).**

- **Notifications.** Brazil's 2014 peak (4.03 per 100,000) and the 2015
  fall in infants (175.2 to 64.9 per 100,000) are documented. The
  authors suggest cyclicity and "an impact may be suspected" from
  maternal dTpa, introduced late 2014 with coverage of 9.2% in 2014 and
  40.4% in 2015 ([Barros et al. 2019,
  doi:10.1080/21645515.2019.1634991](https://pmc.ncbi.nlm.nih.gov/articles/PMC7012156/)).
  PCR was rolled out unevenly by state (São Paulo 2009; Paraná and Bahia
  2014). PAHO reports Brazil's 2024 total as its highest since 2019 and
  2,682 confirmed cases in 2025 ([PAHO, Mar
  2026](https://www.paho.org/en/documents/epidemiological-update-pertussis-whooping-cough-americas-region-25-march-2026)).
  I found no source covering 2016–2023 specifically.

- **GBD.** Brazil's WUENIC DTP3 fell from 93% (2014) to 70% (2019) and
  68% (2021) ([GHO
  WHS4_100](https://ghoapi.azureedge.net/api/WHS4_100)). That roughly
  quadruples the unvaccinated fraction that drives GBD's pertussis
  regression, consistent with GBD rising 164,000 to 588,000 (b/c). GBD
  uses its own coverage estimates, which may differ from WUENIC.

### B7. Global pertussis, 2020–2024

**Status: Explained (a) for both.**

- **WHO totals.** "163,388 in 2023 to 941,582 in 2024 (5.76-fold)";
  China went from 41,124 to 476,690, and the Western Pacific rose
  12-fold ([Nature Medicine
  2026](https://www.nature.com/articles/s41591-026-04660-8)). EU/EEA
  reported 209,674 cases in 2024 against 26,001 in 2023. ECDC attributes
  this to "the accumulation of susceptible individuals following
  prolonged COVID-19 control measures", waning acellular immunity and
  expanded PCR testing: the PCR share was 42% in 2023–24 vs 23% in
  2015–19 ([ECDC
  2024](https://www.ecdc.europa.eu/en/publications-data/pertussis-annual-epidemiological-report-2024)).
  The Americas reported 66,184 cases in 2024 ([PAHO, Mar
  2026](https://www.paho.org/en/documents/epidemiological-update-pertussis-whooping-cough-americas-region-25-march-2026)).

- **GBD dip.** This is driven by the mask-use covariate (A2.7); GBD
  calls the 2020–21 values "anomalously low pandemic-period estimates".
  GBD 2023 ends in 2023 and "do\[es\] not quantify the subsequent
  reported waves".

### B8. Global diphtheria resurgence

**Status: Partly documented (a).**

| Year | Global (GHO) | Main contributors (GHO, cases) |
|----|----|----|
| 2025 | 30,206 | Nigeria 15,273; Somalia 3,622; India 3,249; Niger 1,592; Yemen 1,447; Mauritania 1,273 |
| 2024 | 25,147 | Nigeria 10,595; India 5,634; Chad 2,599; Niger 2,082 |
| 2023 | 24,782 | Nigeria 14,163; India 3,850; Niger 3,286 |
| 2019 | 22,989 | India 9,622; Ethiopia 7,184; Nigeria 2,289; Madagascar 1,815 |
| 2018 | 16,911 | India 8,788; Yemen 2,609; Nigeria 1,870; Indonesia 1,026 |

Source: [GHO API WHS3_41](https://ghoapi.azureedge.net/api/WHS3_41),
read 22 Oct 2026. The WHO African Region counted 58,910 suspected cases
in nine countries in 2023–2024, with Nigeria, Guinea and Niger most
affected ([Bita Fouda et al. 2025,
doi:10.11604/pamj.supp.2025.51.1.48620](https://www.panafrican-med-journal.com/content/series/51/1/29/full)).
India, Ethiopia and Madagascar 2015–2019 were not covered by any source
I opened.

### B9. Changes don't line up year to year

**Status: Partly documented (a), and expected from model structure
(b).**

- **The closest published result.** The GBD capstone found limited
  country-level concordance with WHO/JRF in 2023 (Pearson r = −0.103;
  log-scale r = 0.398 among positive pairs).

- **The npj Vaccines comparison** found GBD and WHO pertussis trends
  diverging in direction across regions and concluded the divergence is
  "compatible with differential ascertainment" ([Li et al. 2026,
  doi:10.1038/s41541-026-01479-9](https://www.nature.com/articles/s41541-026-01479-9)).

- **Why the structure predicts this.** Pertussis predictions vary only
  with 5-year rolling DTP3 and masking. Diphtheria and tetanus follow
  smoothed CODEm deaths (ST-GPR). Notification shocks therefore go into
  the residuals rather than the estimates.

- No source computes year-on-year change correlations as you did.

### B10. DTP3 coverage and reporting rate

**Status: Plausible mechanism (b).**

- **Across countries.** Your positive correlation is partly mechanical.
  GBD's denominator is a decreasing function of DTP3 by construction
  (the β₁ term), and the random effect that soaks up reporting
  completeness correlates with health-system capacity. Li et al. 2026
  report GBD incidence strongly tied to DTP3 (Spearman −0.81 in 2019),
  while WHO incidence is weakly or not associated. That gap is exactly a
  coverage gradient in the ratio.

- **Surveillance quality.** Higher district income predicted higher
  pertussis notification in Chongqing, read as surveillance sensitivity
  ([Chongqing
  2025](https://pmc.ncbi.nlm.nih.gov/articles/PMC12832240/)).

- **Within a country.** Coverage changes move GBD's numerator and
  denominator almost together, so the ratio barely moves (c).

### B11. Persistent zero reporting

**Status: Mostly a data-handling artefact (c); the surveillance gap is
described generally (a).**

In the GHO API, several of your example country-years are **null, not
zero**.

- Angola pertussis: 2021, 2022, 2023 and 2024 are null. 2020 is 0, and
  2025 is 1,150.

- Botswana: 2020 and 2021 are null.

- Bhutan: 2021 is null.

- Cabo Verde: there is no 2020 row ([GHO API
  WHS3_43](https://ghoapi.azureedge.net/api/WHS3_43)).

If your pipeline coerces nulls to 0, the 47-country list is inflated;
re-run it with nulls as NA. Where true zeros remain (Botswana 2022–2024,
Cabo Verde 2021–2024), WHO's standard says pertussis surveillance can be
sentinel-only and that deaths outside facilities "would be missed". A
reported zero from a non-nationwide system is not evidence of absence
(b). I found no source that lists persistent pertussis zero-reporters.

## Part C: Prior comparisons

Two 2026 papers already compare GBD and WHO pertussis directly. I found
no published GBD-vs-WHO comparison for diphtheria or tetanus. The WHO
50-year EPI analysis takes GBD 2021 DTP burden as given rather than
reconciling it with WHO cases.

### C12. Published comparisons

| Study | Disease and rounds | What it compares | Key finding |
|----|----|----|----|
| [GBD 2023 Pertussis Collaborators, Nature Medicine, 21 Oct 2026](https://www.nature.com/articles/s41591-026-04660-8) (doi:10.1038/s41591-026-04660-8) | Pertussis, GBD 2023 vs JRF 2023–2024 | Country concordance of incidence and ranks | Pearson r = −0.103 (2023); Spearman 0.314 for GBD 2023 vs JRF 2024 ranks. JRF "should not be used as formal validation targets". Supplementary Table 8 has the country comparison |
| [Li et al., npj Vaccines 2026;11:148](https://www.nature.com/articles/s41541-026-01479-9) (doi:10.1038/s41541-026-01479-9) | Pertussis, GBD 2019 and 2021 vs WHO 2000–2024 | Regional trends (joinpoint), DTP3 and maternal-vaccination associations | "GBD consistently reported higher incidence than WHO". Trend directions diverge (South-East Asia most). DTP3 is strongly associated with GBD and weakly with WHO. Divergence is "compatible with differential ascertainment". Second half read only via summary |
| [Shattock et al., Lancet 2024;403:2307–16](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(24)00850-X/fulltext) (doi:10.1016/S0140-6736(24)00850-X), appendix | Diphtheria, tetanus, pertussis, TB | "Static modelling approach built upon disease burden estimates from the \[GBD\]" (GBD 2021) | DTP deaths averted come from GBD deaths ÷ (1 − effective coverage). No calibration to WHO case data is described. The authors call the low diphtheria impact "likely an artefact of the relatively simplistic static modelling approach" |
| [Wu et al., Front Public Health 2025](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1597076/full) (doi:10.3389/fpubh.2025.1597076) | Diphtheria, GBD 2021 | GBD vs SDI and DTP3 | No WHO comparison. Not a reconciliation |

**VIMC.** The first-phase VIMC review covers 10–12 pathogens and does
not include DTP. It describes no use of JRF case data for calibration
and no GBD comparison ([Gaythorpe et al. 2024, Gates Open Res,
doi:10.12688/gatesopenres.15556.1](https://pmc.ncbi.nlm.nih.gov/articles/PMC11467163/)).
The VIMC model standards require documenting "how fitting accounts for
data limitations (e.g. under-reporting of cases)" ([VIMC Model
Standards](https://www.vaccineimpact.org/_files/ugd/ac3c5d_00bb4141a2654e2d85390ebd238b1faa.pdf)).
UCT MASHA has "six years of experience developing dynamic models for
pertussis, diphtheria and tetanus" and contributed to the EPI analysis
([UCT MASHA, June
2024](https://science.uct.ac.za/masha/articles/2024-06-04-masha-team-contribute-landmark-study-global-impact-immunisation)).
However, the published EPI appendix lists DTP under the GBD-based static
form. Whether DTP is in VIMC's current portfolio could not be confirmed
from vaccineimpact.org (status: not found).

### C13. Commentary on reconciling the sources

- **IHME.** JRF notifications "are not directly equivalent to modeled
  underlying incidence and should not be used as formal validation
  targets" ([Nature Medicine
  2026](https://www.nature.com/articles/s41591-026-04660-8)). The
  pertussis model's random effect mixes ascertainment with "residual
  differences in transmission … diagnostic intensity, reporting
  requirements and healthcare seeking".

- **WHO.** Reported cases are "likely an underestimation" for diphtheria
  and "likely an underestimate" for tetanus (2018 standards). WHO
  publishes no reconciliation with GBD that I could find.

- **Academic.** Li et al. 2026 argue the divergence reflects "changes in
  ascertainment driven by strengthened surveillance and expanded access
  to sensitive molecular diagnostics" as well as epidemiology.

- **Not found.** I found no paper that reconciles GBD and WHO for
  diphtheria or tetanus. I also found none that uses JRF for formal
  completeness estimates across DTP, beyond the pertussis work above.
  Searches included GBD vs WHO for diphtheria and tetanus, VIMC DTP
  calibration and WHO JRF completeness.

## Implications for your analysis

The "reporting rate" means something different for each disease. For
pertussis it mostly measures distance from Switzerland. For diphtheria
it is capped at 1 by design. For tetanus it compares notifications with
a death-derived estimate. Report and interpret the three separately.

1.  **Fix nulls first.** Keep GHO NumericValue: null as NA, never as 0.
    Then re-run B11 and any medians that counted zeros. Angola, Botswana
    and Bhutan are confirmed examples.

2.  **Flag floored country-years.** For diphtheria and pertussis, a
    ratio of exactly 1 (within about 1%) means GBD copied the
    notification. Exclude these from the distribution of reporting rates
    or report them separately. Otherwise they pull the median and the
    share above 1 toward 1. A ratio above 1 in GBD 2023 implies a JRF
    revision after GBD's data freeze. Log the WHO download date and
    compare with the GBD 2023 input data (Sources Tool or the [nonfatal
    data
    audit](https://explorer.healthdata.org/heatmap?componentType=cause_nf&id=339/)
    for pertussis).

3.  **Pertussis: report relative, not absolute, completeness.** The
    absolute level rests on Switzerland's random effect, which is
    reporting 100% by assumption. Under alternative references GBD's own
    sensitivity changes the scaling by 0.39× to 0.0069×. Within-country
    rankings over time are more robust than cross-country levels. As a
    sanity check, Switzerland's own rate should be near 1.

4.  **Treat the DTP3 correlation as partly built in.** GBD pertussis
    uses DTP3 in its incidence model, and diphtheria and tetanus use it
    in their death models. A test of "surveillance quality vs coverage"
    needs a coverage-independent denominator, or should relate
    notifications to WUENIC directly.

5.  **Exclude known reporting breaks.**

    - India total tetanus from 2020 on (non-neonatal dropped; use
      WHS3_56 vs GBD under-1 tetanus instead).

    - Pakistan pertussis before 1991.

    - China pertussis: mark 2017 (PCR) and 2024 (new criteria) as
      definition changes.

    - Brazil and other countries: check for state-level PCR roll-out and
      surveillance changes.

6.  **Tetanus: compare like with like.** WHS3_46 (total) matches GBD
    "Tetanus" conceptually. A cleaner second comparison is WHS3_56
    neonatal tetanus vs GBD tetanus for ages under 28 days (early plus
    late neonatal). Verify the age groups exist for this cause in the
    Results Tool. Because GBD tetanus incidence is deaths ÷ CFR, a ratio
    above 1 is not over-reporting by itself. Report it alongside GBD
    deaths and CFR.

7.  **Diphtheria: note case mix.** WHO counts may include cutaneous and
    clinically compatible cases (94.6% of African cases 2023–24), while
    GBD is respiratory. Expect ratios above 1 in migrant-related
    European outbreaks and clinically defined African outbreaks.

8.  **Pandemic years.** For pertussis 2020–2022, GBD's dip is a
    mask-covariate artefact. Analyse 2020–2022 separately rather than
    pooling with 2015–2019.

9.  **Age coverage.** GBD diphtheria and pertussis appendices say
    estimates are produced for "post-neonatal to 59 years". Check
    whether your all-ages GBD download contains values outside this
    range. If not, notifications in older adults have no GBD counterpart
    (worth a quick check in your data).

10. **Cite the GBD round.** Everything above is GBD 2023 (the floor and
    mask covariate are new). If you compare with older downloads, the
    floor will not be present.

## Bibliography

All sources were opened on 22 Oct 2026 unless noted. Read status: "full"
= full text read; "partial" = part verbatim, rest via an automated
summary; "abstract" = abstract only.

**GBD**

1.  GBD 2023 Disease and Injury and Risk Factor Collaborators. Burden of
    375 diseases and injuries, risk-attributable burden of 88 risk
    factors, and healthy life expectancy in 204 countries and
    territories, including 660 subnational locations, 1990–2023.
    *Lancet* 2025. doi:10.1016/S0140-6736(25)01637-X. Supplementary
    appendix 1 (nonfatal methods): diphtheria pp 479–483, pertussis pp
    1100–1102, tetanus pp 1204–1208.
    [Article](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(25)01637-X/fulltext).
    Full (relevant sections).

2.  GBD 2023 Causes of Death Collaborators. Global burden of 292 causes
    of death in 204 countries and territories and 660 subnational
    locations, 1990–2023. *Lancet* 2025.
    doi:10.1016/S0140-6736(25)01917-8. Appendix 1: diphtheria pp
    440–441, pertussis pp 669–671, tetanus pp 711–712.
    [Article](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(25)01917-8/fulltext).
    Full (relevant sections).

3.  GBD 2023 Pertussis Collaborators, Mosser JF, Liu J. Global, regional
    and national burden of pertussis in 1990–2023: a Global Burden of
    Disease study. *Nat Med* 2026 (published 21 Oct 2026).
    doi:10.1038/s41591-026-04660-8.
    [Link](https://www.nature.com/articles/s41591-026-04660-8). Full
    (main text and methods).

**WHO**

4.  WHO. WHO/UNICEF joint reporting process.
    [Link](https://who.int/teams/immunization-vaccines-and-biologicals/immunization-analysis-and-insights/global-monitoring/who-unicef-joint-reporting-process).
    Full.

5.  WHO Immunization Data portal:
    [tetanus](https://immunizationdata.who.int/global/wiise-detail-page/tetanus-reported-cases-and-incidence)
    and
    [pertussis](https://immunizationdata.who.int/global/wiise-detail-page/pertussis-reported-cases-and-incidence)
    reported cases pages; [portal launch news, 3 Nov
    2022](https://www.who.int/news/item/03-11-2022-who-immunization-data-portal--global--regional-and-country-immunization-data-at-your-fingertips).
    Text only (charts not rendered).

6.  WHO. Vaccine-Preventable Diseases Surveillance Standards, 2018:
    [diphtheria](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-04-diphtheria-r2.pdf),
    [neonatal
    tetanus](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-14-neonataltetanus-r2.pdf),
    [non-neonatal
    tetanus](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-15-nonneonataltetanus-r2.pdf),
    [pertussis](https://cdn.who.int/media/docs/default-source/immunization/vpd_surveillance/vpd-surveillance-standards-publication/who-surveillancevaccinepreventable-16-pertussis-r2.pdf).
    Full.

7.  WHO Global Health Observatory OData API: indicators
    [WHS3_41](https://ghoapi.azureedge.net/api/WHS3_41),
    [WHS3_43](https://ghoapi.azureedge.net/api/WHS3_43),
    [WHS3_46](https://ghoapi.azureedge.net/api/WHS3_46),
    [WHS3_56](https://ghoapi.azureedge.net/api/WHS3_56) and
    [WHS4_100](https://ghoapi.azureedge.net/api/WHS4_100). Filtered
    queries for IND, PAK, BRA, AGO, BWA, BTN, CPV and global; values as
    of 22 Oct 2026.

8.  WHO EMRO. Weekly Epidemiological Monitor 14(36), 5 Sep 2021 (Yemen
    diphtheria).
    [PDF](https://applications.emro.who.int/docs/EPI/2021/2224-4220-2021-1436-eng.pdf).
    Full. Also WHO EMRO, [Epidemiological situation in Yemen:
    diphtheria](https://www.emro.who.int/yemen/news/epidemiological-situation-in-yemen-diphtheria.html),
    16 Nov 2023. Full.

9.  WHO/UNICEF. Global childhood immunization coverage inches forward…,
    15 Jul 2026.
    [Link](https://www.who.int/news/item/15-07-2026-global-childhood-immunization-coverage-inches-forward-despite-conflict-and-hesitancy---unicef--who).
    Full (no DTP case data).

**Regional agencies**

10. Jones CE, Yusuf N, Ahmed B, Kassogue M, Wasley A, Kanu FA. Progress
    toward achieving and sustaining maternal and neonatal tetanus
    elimination — worldwide, 2000–2022. *MMWR* 2024;73(28):614–21.
    doi:10.15585/mmwr.mm7328a1.
    [Link](https://www.cdc.gov/mmwr/volumes/73/wr/mm7328a1.htm). Full.

11. ECDC. Pertussis — Annual Epidemiological Report for 2024.
    [Link](https://www.ecdc.europa.eu/en/publications-data/pertussis-annual-epidemiological-report-2024).
    Full.

12. ECDC. Diphtheria — Annual Epidemiological Report for 2023 (published
    23 Jan 2026). [Link](https://www.ecdc.europa.eu/en/node/41668).
    Full.

13. PAHO. Epidemiological alert: pertussis, 22 Jul 2024
    ([PDF](https://paho.org/sites/default/files/2024-07/2024-jul-22-phe-epialert-pertussis-eng-final2.pdf))
    and Epidemiological update: pertussis in the Americas, 25 Mar 2026
    ([link](https://www.paho.org/en/documents/epidemiological-update-pertussis-whooping-cough-americas-region-25-march-2026)).
    Full.

14. OCHA ReliefWeb. Nigeria: Diphtheria Outbreak – Jan 2023.
    [Link](https://reliefweb.int/disaster/ep-2023-000034-nga). Cached
    page; compiles WHO/NCDC updates.

**Peer-reviewed papers**

15. Li K, Xie Y, … Chen T. Global patterns of pertussis incidence and
    vaccination strategies: implications of divergent surveillance data.
    *npj Vaccines* 2026;11:148. doi:10.1038/s41541-026-01479-9.
    [Link](https://www.nature.com/articles/s41541-026-01479-9). Partial.

16. Dai H, He H, Xu J, et al. Underestimated incidence rate of pertussis
    in the community: results from active population-based surveillance
    in Yiwu, China. *Microorganisms* 2024;12(11):2186.
    doi:10.3390/microorganisms12112186.
    [Link](https://pmc.ncbi.nlm.nih.gov/articles/PMC11596255/). Full.

17. Epidemiological and spatial–temporal clustering characteristics of
    pertussis in Southwest China, 2013–2024. *Front Public Health* 2025.
    doi:10.3389/fpubh.2025.1620429.
    [Link](https://pmc.ncbi.nlm.nih.gov/articles/PMC12832240/). Main
    text read; author list not captured.

18. Liu M, Wei X, Sun J, et al. Molecular epidemiological
    characteristics of pertussis in a pediatric hospital in Jinan City,
    China, 2022 to 2024. *Front Public Health* 2025;13:1657953.
    doi:10.3389/fpubh.2025.1657953.
    [Link](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1657953/pdf).
    Partial.

19. Chen Q, Wang W, Shi X, et al. Seroepidemiology of pertussis in the
    east of China: estimates of incidence of infection in adolescents
    and adults pre- and post-COVID-19. *Front Public Health*
    2022;10:1054617. doi:10.3389/fpubh.2022.1054617.
    [Link](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2022.1054617/full).
    Partial.

20. Sutter RW, et al. Pertussis hospitalizations and mortality in the
    United States, 1985–1988: evaluation of the completeness of national
    reporting. *JAMA* 1992. PMID 1309387.
    [Link](https://pubmed.ncbi.nlm.nih.gov/1309387/). Abstract.

21. Barros ENC de, Nunes AA, Abreu ADJL de, et al. Pertussis
    epidemiological pattern and disease burden in Brazil: an analysis of
    national public health surveillance data. *Hum Vaccin Immunother*
    2019;16(1):61–69. doi:10.1080/21645515.2019.1634991.
    [Link](https://pmc.ncbi.nlm.nih.gov/articles/PMC7012156/). Full.

22. Bita Fouda AA, Wiysonge CS, Masresha BG, et al. Resurgence of
    diphtheria outbreaks in the African Region 2023–2024. *Pan Afr Med
    J* 2025;51(Suppl 1):29. doi:10.11604/pamj.supp.2025.51.1.48620.
    [Link](https://www.panafrican-med-journal.com/content/series/51/1/29/full).
    Full.

23. Kofler J, Ramette A, … Grützmacher B. Ongoing toxin-positive
    diphtheria outbreaks in a federal asylum centre in Switzerland, July
    to September 2022. *Euro Surveill* 2022;27(44):2200811.
    doi:10.2807/1560-7917.ES.2022.27.44.2200811.
    [Link](https://eurosurveillance.org/content/10.2807/1560-7917.ES.2022.27.44.2200811).
    Abstract.

24. Brockhaus L, Urwyler P, Leutwyler U, et al. Diphtheria in a Swiss
    asylum seeker reception centre: outbreak investigation and
    evaluation of testing and vaccination strategies. *Int J Public
    Health* 2024;69:1606791. doi:10.3389/ijph.2024.1606791.
    [Link](https://www.ssph-journal.org/journals/international-journal-of-public-health/articles/10.3389/ijph.2024.1606791/full).
    Full.

25. Wu Z, Lin L, Zhang J, Zhong J, Lai D. Global burden of diphtheria,
    1990–2021 (GBD 2021). *Front Public Health* 2025;13:1597076.
    doi:10.3389/fpubh.2025.1597076.
    [Link](https://www.frontiersin.org/journals/public-health/articles/10.3389/fpubh.2025.1597076/full).
    Partial.

26. Shattock AJ, Johnson HC, Sim SY, et al. Contribution of vaccination
    to improved survival and health: modelling 50 years of the Expanded
    Programme on Immunization. *Lancet* 2024;403:2307–16.
    doi:10.1016/S0140-6736(24)00850-X.
    [Link](https://www.thelancet.com/journals/lancet/article/PIIS0140-6736(24)00850-X/fulltext).
    Appendix read in full; main text not read.

27. Gaythorpe KAM, Li X, Clapham H, et al. Estimating the impact of
    vaccination: lessons learned in the first phase of the Vaccine
    Impact Modelling Consortium. *Gates Open Res* 2024;8:97.
    doi:10.12688/gatesopenres.15556.1.
    [Link](https://pmc.ncbi.nlm.nih.gov/articles/PMC11467163/). Partial.

**Other**

28. VIMC. Model Standards (c. 2020).
    [PDF](https://www.vaccineimpact.org/_files/ugd/ac3c5d_00bb4141a2654e2d85390ebd238b1faa.pdf).
    Full. UCT MASHA news item, 4 Jun 2024.
    [Link](https://science.uct.ac.za/masha/articles/2024-06-04-masha-team-contribute-landmark-study-global-impact-immunisation).
    Full.

**Could not open** (blocked or rate-limited; claims not used):

- Yeung KHT et al., *Lancet Infect Dis* 2017;17:974–80,
  doi:10.1016/S1473-3099(17)30390-0.

- Crowcroft NS et al., *Lancet Infect Dis* 2003 (PMID 12834898).

- de Melker HE et al., 2000 (Netherlands pertussis serology).
