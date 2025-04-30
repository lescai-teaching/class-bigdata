#  Exercise - Your first Nextflow Workflow

## Dataset

The workflow shoud analyse the same dataset used in the modelling exercises, for classification models, i.e. the metastasis risk data

The data can be retrieved at the following URL

```bash
https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L30_nextflow_your-workflow/L30_dataset_metastasis_risk.tsv
```

## Scope of the workflow

The workflow should run in parallel 2 different models of your choice and collect the fitted model in an RDS file, as well as representative plots in a PDF format.

To perform this exercise **do not tune** the model parameters.
