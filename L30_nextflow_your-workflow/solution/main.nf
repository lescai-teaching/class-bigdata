#!/usr/bin/env nextflow

// create input channel
input_ch = Channel.fromPath(params.input)

// load modules
include { READ_DATA    } from './modules/reading.nf'
include { LINEARMODEL  } from './modules/linear.nf'
include { RANDOMFOREST } from './modules/random.nf'

// run workflow
workflow {
	READ_DATA( input_ch )
	LINEARMODEL( READ_DATA.out.dataset )
	RANDOMFOREST( READ_DATA.out.dataset )
}