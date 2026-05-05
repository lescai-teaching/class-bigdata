#!/usr/bin/env nextflow

// load modules
include { READ_DATA } from './modules/reading.nf'
include { LINEARMODEL } from './modules/linear.nf'
include { RANDOMFOREST } from './modules/random.nf'

// run workflow
workflow {
    main:
    def input_ch = channel.fromPath(params.input)
    READ_DATA(input_ch)
    LINEARMODEL(READ_DATA.out.dataset)
    RANDOMFOREST(READ_DATA.out.dataset)

    def linear_ch = LINEARMODEL.out.tables.mix(LINEARMODEL.out.plots)
    def random_forest_ch = RANDOMFOREST.out.tables.mix(RANDOMFOREST.out.plots)

    publish:
    preprocess = READ_DATA.out.dataset
    linear_model = linear_ch
    random_forest = random_forest_ch
}

output {
    preprocess {
        path 'preprocess'
    }

    linear_model {
        path 'results/linear_model'
    }

    random_forest {
        path 'results/random_forest'
    }
}
