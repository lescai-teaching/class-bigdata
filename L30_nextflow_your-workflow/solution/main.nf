#!/usr/bin/env nextflow

// load modules
include { READ_DATA } from './modules/reading.nf'
include { RUNMODEL as LOGREG } from './modules/runmodel.nf'
include { RUNMODEL as RANDOMFOREST } from './modules/runmodel.nf'

// run workflow
workflow {
    def input_ch = channel.fromPath(params.input)
    READ_DATA(input_ch, "$projectDir/scripts/run_import.R")
    LOGREG(READ_DATA.out.dataset, "$projectDir/scripts/run_logistic_model.R", 'logreg')
    RANDOMFOREST(READ_DATA.out.dataset, "$projectDir/scripts/run_random_forest.R", 'randomforest')
}
