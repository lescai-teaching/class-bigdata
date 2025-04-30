# Bioremediation Exercise

## Context

Biodegradation is the process by which microorganisms break down organic compounds.
Polycyclic aromatic hydrocarbons (PAHs) are produced by industrial activities an they can be targeted by
specific genera of microorganisms to develop bioremediation solutions.

Aerobic conditions favor PAHs degradation through oxygenase-mediated activities. 
Additionally, the use of surfactant compounds produced by microorganisms represents a promising approach to improve the bioremediation efficiency of polluted environments

## Dataset

A series of measurements have been made, in order to understand how different microbial compositions and environmental conditions might affect the biodegradation of PAHs. 

PAHs, oxygen and rhamnolipids have been measured in *mg/litre*. 

Microorganisms have been measured in *g/Kg* of biomass.

Nitrogen is measured in parts per million (*ppm*).

The dataset can be loaded with:

```r
biodegradation_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_biodegradation_data.rds"))

```

## Exercise

Using the appropriate modelling technique, test at least two approaches and select one model which performs best to provide an understanding of the scenario described above.

Provide both measures and plots to show what you have achieved.