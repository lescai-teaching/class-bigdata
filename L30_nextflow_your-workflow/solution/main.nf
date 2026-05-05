#!/usr/bin/env nextflow

// load modules
include { READ_DATA } from './modules/reading.nf'
include { RUNMODEL as LOGREG } from './modules/runmodel.nf'
include { RUNMODEL as RANDOMFOREST } from './modules/runmodel.nf'

// run workflow
workflow {
    main:
    def input_ch = channel.fromPath(params.input)
    READ_DATA(input_ch, "$projectDir/scripts/run_import.R")
    LOGREG(READ_DATA.out.dataset, "$projectDir/scripts/run_logistic_model.R", 'logreg')
    RANDOMFOREST(READ_DATA.out.dataset, "$projectDir/scripts/run_random_forest.R", 'randomforest')

    def logreg_ch = LOGREG.out.model.mix(LOGREG.out.plots)
    def random_forest_ch = RANDOMFOREST.out.model.mix(RANDOMFOREST.out.plots)

    publish:
    preprocess = READ_DATA.out.dataset
    logreg = logreg_ch
    randomforest = random_forest_ch
}

output {
    preprocess {
        path 'preprocess'
    }

    logreg {
        path 'results/logreg'
    }

    randomforest {
        path 'results/randomforest'
    }
}
