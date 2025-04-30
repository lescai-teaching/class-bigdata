# Metastasis Risk Exercise

## Context

Blood samples from 10,000 individuals have been collected and assessed for biochemistry and WBC counts. Subjects have been characterised in a retrospective study for the risk to developed metastasis in various types of tumours.


## Available data

To load the data:

```R
metastasis_risk_data = readRDS(url("https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L18_modelling_exercises/L18_dataset_metastasis_risk_data.rds"))
```

Data include:

- cytokines (measured in *pg/mL*)
- a few markers (measured in *mg/L*)
- blood pressure
- cholesterol
- liver and kidney function (classified as *good*, *reduced* or *compromised*)
- count of different white blood cells (measured as *count / uL*)

## Exercise

Using the appropriate modelling technique, test at least two approaches and select one model which performs best to provide an understanding of the scenario described above.
As a result of your modelling you should also be able to understand which markers best help understanding the phenomenon, and you should draw a hypothesis about the biological process which most influences metastasis risk.