#!/usr/bin/env nextflow

params.input = 'https://raw.githubusercontent.com/lescai-teaching/class-bigdata/main/L11_data_import-export/L11_dataset_babynames.rds'
params.outdir = '.'

include { SUMMARISE } from './solution_module.nf'

workflow {
    def input_ch = channel.fromPath(params.input)
    def ch_rscript = channel.value(file("$projectDir/summarise.R"))
    SUMMARISE(input_ch, ch_rscript)
}
