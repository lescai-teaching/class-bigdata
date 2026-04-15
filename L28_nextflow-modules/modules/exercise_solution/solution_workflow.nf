#!/usr/bin/env nextflow

params.input = "https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_babynames.rds"
params.outdir = "."

include { SUMMARISE } from "./solution_module.nf"

workflow {
	def inputCh = channel.fromPath(params.input)
	def scriptCh = channel.value(file("${projectDir}/summarise.R"))

    SUMMARISE(inputCh, scriptCh)
}
