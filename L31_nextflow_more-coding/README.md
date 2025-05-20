# Create a Pipeline from Scratch

## Goal of the workflow

Summarise different statistics from data originated in different experiments

## Logic of the workflow

- the pipeline takes as input a file containing a list of the data files collected in three different experiments
- the workflow will load each of the datafile and run three different R scripts on each of them
- finally, all statistics will be summarised in a single table allowing the comparison of the statistics across the experiments

All data are located in the `data` folder.

## Help provided

A number of help files are provided under the `help_files` folder.

- the R scripts are provided: your task is not to code in R but write the appropriate process definition to run each script
- a code in nextflow is provided, to show how to create a data input channel from a list of data files in tsv format

