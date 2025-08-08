suppressMessages(if (!require("pacman")) install.packages("pacman"))
pacman::p_load(rmarkdown,here, ggplot2,sessioninfo)

sessioninfo::session_info(pkgs = c("loaded", "attached")[1], to_file = here("Session info","tbr_prison_session_info.txt"))

# Patch ggsave to auto-create directories
unlockBinding("ggsave", as.environment("package:ggplot2"))
assign("ggsave", function(filename, ...) {
  dir.create(dirname(filename), recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(filename, ...)
}, envir = as.environment("package:ggplot2"))
lockBinding("ggsave", as.environment("package:ggplot2"))

rmd_files <- c(
  "2.tbr-prison_analysis.qmd",
  "3.tbr-prison_viz_map.R"
)

for (file in rmd_files) {
  rmd_path <- here("Scripts", file)
  message("Running: ", rmd_path)
  
  render(
    input = rmd_path,
    output_format = "all",
    output_file = tempfile(),
    clean = TRUE,
    envir = new.env()
  )
}
