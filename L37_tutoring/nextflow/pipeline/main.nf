#!/usr/bin/env nextflow

// create input channel
input_ch = Channel.fromPath(params.input)

// load modules
include { READ_DATA                        } from './modules/reading.nf'
include { RUNMODEL as LINEAR_REGRESSION    } from './modules/runmodel.nf'
include { RUNMODEL as K_NEAREST_NEIGHBOURS } from './modules/runmodel.nf'

// run workflow
workflow {
	READ_DATA( input_ch, "$projectDir/scripts/run_import.R" )
	LINEAR_REGRESSION( READ_DATA.out.dataset, "$projectDir/scripts/run_lm.R", "lm" )
	K_NEAREST_NEIGHBOURS( READ_DATA.out.dataset, "$projectDir/scripts/run_knn.R", "knn" )
}