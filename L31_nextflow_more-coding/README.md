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

**IMPORTANT**

Earlier versions of Singularity do not handle very well oras:// containers generated with Seqera containers.
In order to solve this issue:

1) load the Apptainer module instead of the Singularity module

```bash
module load students/apptainer_1.4.0
```

2) inside the config, enable apptainer in place of singularity (same logic)

```nextflow
apptainer.enabled    = true
apptainer.autoMounts = true
```


3) in the container directive conditional use `apptainer` instead of `singularity`

```nextflow
container "${ workflow.containerEngine == 'apptainer' && !task.ext.singularity_pull_docker_container ?
        'oras://seqeracontainer-singularity' :
        'community.wave.seqera.io/seqeracontainer-docker' }"
```