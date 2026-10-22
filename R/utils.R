# Shared palette, ggplot theme and small helpers.

# Categorical slots in fixed order (validated for all-pairs use up to 3 series)
pal_cause <- c(Diphtheria = "#2a78d6", Pertussis = "#eb6834", Tetanus = "#1baf7a")
pal_source <- c("GHO reported" = "#2a78d6", "GBD modelled" = "#eb6834")

# Sequential blue ramp for magnitude (light = low, dark = high)
seq_blue <- c("#cde2fb", "#9ec5f4", "#6da7ec", "#3987e5", "#256abf", "#184f95", "#0d366b")

ink_primary <- "#0b0b0b"
ink_secondary <- "#52514e"
ink_muted <- "#898781"
grid_col <- "#e1e0d9"
axis_col <- "#c3c2b7"
surface <- "#fcfcfb"
zero_fill <- "#b4b2a9"

gbd_caption <- "Sources: GBD 2023 (IHME); WHO Global Health Observatory reported cases."

theme_dtp <- function(base_size = 10) {
  theme_minimal(base_size = base_size) +
    theme(
      plot.background = element_rect(fill = surface, colour = NA),
      panel.grid.major = element_line(colour = grid_col, linewidth = 0.3),
      panel.grid.minor = element_blank(),
      axis.line.x = element_line(colour = axis_col, linewidth = 0.3),
      axis.text = element_text(colour = ink_muted),
      axis.title = element_text(colour = ink_secondary),
      plot.title = element_text(colour = ink_primary, face = "bold"),
      plot.subtitle = element_text(colour = ink_secondary),
      plot.caption = element_text(colour = ink_muted, hjust = 0),
      strip.text = element_text(colour = ink_primary, face = "bold", hjust = 0),
      legend.text = element_text(colour = ink_secondary),
      legend.title = element_text(colour = ink_secondary),
      legend.position = "top",
      legend.justification = "left"
    )
}

# Percent labels that keep small values readable (0.001%, not 0%)
pct_label <- function(x) {
  out <- paste0(formatC(x * 100, format = "fg", digits = 2, big.mark = ","), "%")
  out[is.na(x)] <- NA
  out
}

# Save a plot and return its path, for use in format = "file" targets
save_plot <- function(plot, name, width = 9, height = 6, dir = "output/figures") {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(dir, paste0(name, ".png"))
  ggsave(path, plot, width = width, height = height, dpi = 150, bg = surface)
  path
}

save_csv <- function(x, name, dir = "output/tables") {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(dir, paste0(name, ".csv"))
  write_csv(x, path)
  path
}

# Drop in-plot titles when a figure is captioned by the report instead
for_report <- function(plot) {
  plot + labs(title = NULL, subtitle = NULL, caption = NULL)
}
