#!/usr/bin/env nextflow

// load modules
include { READ_DATA } from './modules/reading.nf'
include { LINEARMODEL } from './modules/linear.nf'
include { RANDOMFOREST } from './modules/random.nf'

// run workflow
workflow {
    def input_ch = channel.fromPath(params.input)
    READ_DATA(input_ch)
    LINEARMODEL(READ_DATA.out.dataset)
    RANDOMFOREST(READ_DATA.out.dataset)
}
