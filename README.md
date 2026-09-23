# TB screening in people deprived of liberty

Analysis code and intervention-level data for a multi-country mixed-methods study of TB REACH-funded interventions that screened people deprived of liberty (PDL): 67 interventions across 35 projects, 25 countries, waves 1–11 (2011–2024).

## Layout

```
tbr-analysis/
├── scripts/
│   ├── 00_run_all.R    # entry point: analyze → map
│   ├── 01_analyze.qmd  # descriptives, NNS/NNT, random-effects NNS, figures, cascade decomposition
│   └── 02_map.qmd      # country map
├── data/
│   ├── tbr_prison.csv          # published analysis input
│   └── tbr_project_details.csv # generated project summary (untracked)
├── output/             # generated tables, figures and HTML reports (untracked)
├── session-info/       # per-step package/session records (untracked)
├── renv.lock           # pinned package versions
└── _quarto.yml         # shared configuration; renders analysis and map
```

Raw extractions, source reports, manuscript drafts and qualitative exports are excluded from Git. Only `data/tbr_prison.csv` is allowed as a public data file.

## Running

Requires R 4.5 and the Quarto CLI. From the repository root, run these commands in a terminal:

```sh
Rscript -e 'renv::restore()'
Rscript scripts/00_run_all.R
```

The pipeline uses the included CSV. `.Rprofile` activates the project library; `_quarto.yml` runs documents from the project root. The map downloads the United Nations Geospatial simplified boundary areas layer (BNDA) on first use, so internet access is needed for that step. The basemap and its `PROVENANCE.md` are cached in the ignored `data-raw/basemap/` directory. Delete that cache to download it again.

Tables, five 600 dpi figures (including the map), and timestamped HTML reports are written to `output/`. Tables include `TableDescriptive.xlsx`, `estimate_summary.xlsx` and `supplementary_tables.xlsx` (Tables S1–S3). `MANIFEST.txt` records output checksums and the input CSV checksum. Older output files may remain alongside the current run.

## Data and interpretation

`data/tbr_prison.csv` contains aggregate intervention-level counts, not individual patient records. `intervention_id` identifies a row; `project_code` groups interventions within projects. Project codes are neutral identifiers (P01 to P35, numbered in extraction order) and do not name the grantee; `wave`, `country` and `year_implemented` describe the project. The CSV also retains selected screening criteria and category descriptions used to document the extraction.

- `country`, `who_region`, `year_implemented` and `wave` describe the project and its main implementation year.
- `screened`, `presumptive`, `tested`, `tb_af` and `tb_bplus` are counts of people screened, classified presumptive, tested, diagnosed with all forms of TB and diagnosed with bacteriologically confirmed TB, respectively.
- `screening_point` and `presumptive_criteria` describe the screening setting and criteria.
- Indicators beginning `screening_stage_`, `screening_point_`, `screening_methods_`, `testing_methods_` and `subpopulation_` use 1 for present and 0 for absent. Fields ending `_other` contain descriptions rather than binary indicators. `screening_methods_cxr_ai` denotes computer-assisted chest X-ray screening.
- Blank cells represent missing values. Zero is an observed count or an absent indicator. Missing counts must not be replaced with zero.
