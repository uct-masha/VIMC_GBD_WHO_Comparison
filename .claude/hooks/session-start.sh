#!/bin/bash
# Install R, the R packages, Quarto and LaTeX needed to run the targets
# pipeline and render report.pdf in Claude Code cloud sessions.
# Idempotent: each step is skipped when its dependency is already present.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

export DEBIAN_FRONTEND=noninteractive

# ---- System packages (R, build deps, TeX Live, fonts) ----------------------
apt_packages=(
  r-base-core r-cran-jsonlite r-cran-httr r-cran-dplyr r-cran-tidyr
  r-cran-readr r-cran-ggplot2 r-cran-purrr r-cran-stringr
  r-cran-igraph r-cran-xml2 r-cran-textshaping r-cran-systemfonts r-cran-svglite
  libuv1-dev libglpk40
  texlive-xetex texlive-luatex texlive-latex-recommended texlive-latex-extra
  texlive-fonts-recommended texlive-fonts-extra texlive-plain-generic
  texlive-science texlive-pictures lmodern fonts-lmodern fonts-texgyre
  poppler-utils
)

missing=()
for pkg in "${apt_packages[@]}"; do
  dpkg-query -W -f='${Status}' "$pkg" 2>/dev/null | grep -q "install ok installed" || missing+=("$pkg")
done

if [ ${#missing[@]} -gt 0 ]; then
  echo "Installing system packages: ${missing[*]}" >&2
  apt-get update -qq
  apt-get install -y -qq --no-install-recommends "${missing[@]}" >/dev/null
fi

# ---- Quarto CLI ------------------------------------------------------------
# The GitHub API is not reachable from cloud sessions, so use quarto.org's
# stable "latest" download link.
if ! command -v quarto >/dev/null 2>&1; then
  echo "Installing Quarto CLI" >&2
  tmp_deb="$(mktemp --suffix=.deb)"
  curl -sSL -o "$tmp_deb" https://quarto.org/download/latest/quarto-linux-amd64.deb
  dpkg -i "$tmp_deb" >/dev/null
  rm -f "$tmp_deb"
fi

# ---- R packages from CRAN --------------------------------------------------
# xfun/knitr/rmarkdown are upgraded from CRAN because the apt versions are too
# old for current targets.
Rscript --vanilla - <<'EOF'
needed <- c(xfun = "0.52", knitr = "1.50", rmarkdown = "2.29", fs = "0", countrycode = "0",
            targets = "1.11", tarchetypes = "0.13", quarto = "1.4", kableExtra = "1.4",
            ggrepel = "0.9", ggplot2 = "4.0")
outdated <- names(needed)[vapply(names(needed), function(p) {
  !requireNamespace(p, quietly = TRUE) || packageVersion(p) < needed[[p]]
}, logical(1))]
if (length(outdated)) {
  message("Installing R packages: ", paste(outdated, collapse = ", "))
  # Posit Package Manager serves prebuilt Linux binaries (the user agent
  # selects them), so nothing needs compiling; e.g. igraph needs Fortran.
  options(HTTPUserAgent = sprintf("R/%s R (%s)", getRversion(),
    paste(getRversion(), R.version["platform"], R.version["arch"], R.version["os"])))
  codename <- system("lsb_release -cs", intern = TRUE)
  install.packages(outdated, Ncpus = 4, quiet = TRUE, repos = c(
    p3m = paste0("https://packagemanager.posit.co/cran/__linux__/", codename, "/latest"),
    cran = "https://cloud.r-project.org"
  ))
}
still_missing <- names(needed)[!vapply(names(needed), requireNamespace, logical(1), quietly = TRUE)]
if (length(still_missing)) stop("R packages failed to install: ", paste(still_missing, collapse = ", "))
EOF

echo "Session setup complete: $(R --version | head -1); Quarto $(quarto --version)" >&2
