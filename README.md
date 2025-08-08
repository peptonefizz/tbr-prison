# Active Case Finding for Tuberculosis in Prisons

*A multi-country mixed-methods analysis of TB REACH–funded interventions to screen populations deprived of liberty.*

This repository contains all data and R scripts supporting the manuscript. All code is fully reproducible—figures, tables, and outputs can be regenerated.

------------------------------------------------------------------------

### 📄 Associated publications

Active Case-Finding for Tuberculosis in Populations Deprived of Liberty: A Multi-Country Mixed-Methods Review of Screening Outcomes and Challenges.

*Under peer review*

------------------------------------------------------------------------

## 📁 Repository structure

```         
tbr-prison/
├── Data/                              
│   ├── tbr_prison.csv                # Input data files
│   ├── tbr_project_details.csv       # Interim project-level output 
├── Scripts/                
│   ├── 1.batch_run_all_analyses.R    # Batch script for entire code
│   ├── 2.tbr-prison_analysis.qmd     # Analysis code
│   ├── 3.tbr-prison_viz_map.R        # Visualizing map
├── Outputs/
├── tbr-prison.Rproj        
└── README.md               
```

------------------------------------------------------------------------

## 🚀 Running the Analysis

To reproduce the entire analysis:

1.  Clone the repository

2.  Open RStudio in the project root.

3.  Run the batch script:`Scripts/1.batch_run_all_analyses.R`

4.  Outputs will be saved in the `Outputs/` folder.
