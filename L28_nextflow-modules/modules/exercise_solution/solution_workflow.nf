#!/usr/bin/env nextflow

params.input = "https://raw.githubusercontent.com/lescai-teaching/class-bigdata-2023/main/L11_data_import-export/L11_dataset_babynames.rds"
input_ch = Channel.fromPath(params.input)

include { SUMMARISE } from "./solution_module.nf"

workflow {
    SUMMARISE( input_ch )
}