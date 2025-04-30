#!/usr/bin/env nextflow

params.input = "https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_babynames.rds"
input_ch = Channel.fromPath(params.input)
params.outdir = "."

include { SUMMARISE } from "./solution_module.nf"

workflow {
	ch_rscript = Channel.value(file("$projectDir/summarise.R"))
    SUMMARISE( input_ch, ch_rscript )
}