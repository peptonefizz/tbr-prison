#!/usr/bin/env Rscript
# Run the pipeline: analyze -> map, using data/tbr_prison.csv.
# Renders every numbered .qmd in scripts/, in file-name order.
# Tables, figures and HTML reports go to output/, sessionInfo to session-info/.

suppressPackageStartupMessages({
  library(here)
  library(sessioninfo)
})

here::i_am("scripts/00_run_all.R")

pipeline <- list.files(here("scripts"), pattern = "^[0-9]{2}_.+\\.qmd$")
if (!length(pipeline)) stop("No numbered .qmd documents found in scripts/")

quarto_bin <- Sys.which("quarto")
if (!nzchar(quarto_bin)) stop("quarto CLI not found on PATH")

dir.create(here("output"), showWarnings = FALSE)
dir.create(here("session-info"), showWarnings = FALSE)
dir.create(here("data"), showWarnings = FALSE)

stamp <- format(Sys.time(), "%Y%m%d-%H%M%S")

# Snapshot output/ so a failed run can be rolled back. Deleted on success.
snapshot_dir <- here("output", paste0(".prev-", stamp))
previous <- list.files(here("output"), full.names = TRUE, recursive = FALSE)
previous <- previous[!grepl("^\\.prev-", basename(previous))]
if (length(previous)) {
  dir.create(snapshot_dir, showWarnings = FALSE, recursive = TRUE)
  if (!all(file.copy(previous, snapshot_dir, recursive = TRUE, copy.date = TRUE))) {
    stop("Could not snapshot all previous outputs; no documents were rendered.")
  }
  message("Snapshot of previous output/: ", basename(snapshot_dir),
          " (", length(previous), " items)")
}

render_all <- function() {
  for (step in pipeline) {
    step_path <- here("scripts", step)
    message("\n=== Rendering: ", step, " ===")

    status <- system2(quarto_bin, c("render", shQuote(step_path), "--to", "html"))
    if (status != 0) stop("Quarto render failed for ", step, " (exit ", status, ")")

    # embed-resources: one self-contained .html, no _files/ sidecar.
    rendered <- here("scripts", sub("\\.qmd$", ".html", step))
    if (!file.exists(rendered)) stop("Expected rendered file not found: ", rendered)

    target <- here("output", sprintf("%s_%s.html", sub("\\.qmd$", "", step), stamp))
    if (!file.rename(rendered, target)) stop("Could not move ", rendered, " -> ", target)
    message("Report: ", basename(target))
  }
}

outcome <- try(render_all(), silent = FALSE)

if (inherits(outcome, "try-error")) {
  message("\n", strrep("-", 72))
  message("Pipeline FAILED. output/ now holds a mix of newly written and stale files.")
  if (dir.exists(snapshot_dir)) {
    message("The state before this run is preserved in:\n  ", snapshot_dir)
    message("Restore it with:  cp -a '", snapshot_dir, "/.' '", here("output"), "/'")
  }
  message(strrep("-", 72))
  quit(status = 1L)
}

# Each document writes its own session record from inside its render.
recorded <- paste0("session_info_", sub("\\.qmd$", "", pipeline), ".txt")
if (!all(file.exists(here("session-info", recorded)))) warning("a session-info file is missing")
message("\nSession info: ", paste(recorded, collapse = ", "))

if (dir.exists(snapshot_dir)) unlink(snapshot_dir, recursive = TRUE)

manifest_path <- here("output", "MANIFEST.txt")

# MANIFEST.txt is excluded from its own listing.
artifacts <- list.files(here("output"), full.names = TRUE)
artifacts <- artifacts[!dir.exists(artifacts)]
artifacts <- artifacts[basename(artifacts) != basename(manifest_path)]
manifest <- data.frame(
  file  = basename(artifacts),
  bytes = file.size(artifacts),
  md5   = unname(tools::md5sum(artifacts)),
  mtime = format(file.mtime(artifacts), "%Y-%m-%d %H:%M:%S"),
  row.names = NULL
)
manifest <- manifest[order(manifest$file), ]
writeLines(
  c(sprintf("# output/ manifest, written after the complete pipeline run %s", stamp),
    sprintf("# %d files currently in output/; older artifacts may also be present.", nrow(manifest)),
    paste("# Rendered steps:", paste(pipeline, collapse = ", ")),
    paste("# Input data/tbr_prison.csv MD5:", unname(tools::md5sum(here("data", "tbr_prison.csv")))),
    "# HTML reports are timestamped per run; earlier reports are kept alongside.",
    "# This file is not listed in itself: a checksum file cannot carry its own MD5.",
    "",
    sprintf("%-44s %12s  %-32s  %s", "file", "bytes", "md5", "modified"),
    sprintf("%-44s %12d  %-32s  %s",
            manifest$file, manifest$bytes, manifest$md5, manifest$mtime)),
  manifest_path
)

message("Pipeline complete. Outputs in output/ (", nrow(manifest), " files, see MANIFEST.txt)")
