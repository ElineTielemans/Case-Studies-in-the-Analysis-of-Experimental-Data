# Case-Studies-in-the-Analysis-of-Experimental-Data
Reproducible Network Analysis of Empathy

Project Overview
This project was completed for the UGent course on reproducible and transparent scientific practice.
The aim is to reproduce and extend a published network analysis of empathy using the Interpersonal Reactivity Index (IRI). We investigate the network structure of empathy-related questionnaire items and compare network characteristics across gender groups.

Research Questions
H1
Can the network structure reported by Briganti et al. be reproduced using an independent dataset?
H2
Does the empathy network differ between male and female participants?
H3
Are there differences in centrality and connectivity patterns between gender-specific empathy networks?

Repository Structure
├── data/
│   ├── raw/
│   └── processed/
├── scripts/
│   ├── Prepare_IRI_data.R
│   ├── H1_Analysis.R
│   └── H2_H3_Analysis.R
├── figures/
├── results/
├── report/
└── README.md

Data
The dataset contains Interpersonal Reactivity Index (IRI) responses extracted from the dataset used by Han (2023).
Only the 28 IRI questionnaire items, gender information, and age variables are used in the analyses.

Analysis Pipeline
Step 1: Data Preparation
Run:
source("scripts/Prepare_IRI_data.R")
This script:
extracts the 28 IRI items
prepares gender and age variables
removes incomplete observations
creates analysis-ready datasets
Step 2: H1 Analysis
Run:
source("scripts/H1_Analysis.R")
This script reproduces the main empathy network analysis.
Step 3: H2 and H3 Analyses
Run:
source("scripts/H2_H3_Analysis.R")
This script performs gender-based network analyses and comparisons.

Software Requirements
R version 4.0+
Required packages:
qgraph
bootnet
igraph
mgm
dplyr
ggplot2
data.table
reshape2
readr

Reproducibility
All analyses can be reproduced by running the scripts in the order described above.

Authors
Eline Tielemans
Justine Tielemans
Sarah Saad Saoud

UGent – Reproducible and Transparent Scientific Practice

References
Briganti, G., Kempenaers, C., Braun, S., Fried, E. I., & Linkowski, P. (2018). Network analysis of empathy items from the interpersonal reactivity index in 1973 young adults. Psychiatry Research, 265, 87–92. https://doi.org/10.1016/j.psychres.2018.03.082
Han, H. (2024). Examining the network structure among moral functioning components with network analysis. Personality and Individual Differences, 217, Article 112435. https://doi.org/10.1016/j.paid.2023.112435
