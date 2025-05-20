#!/usr/bin/env nextflow

// load the required modules
include { MEAN_SD } from './modules/mean_sd/main'
include { PC1_LOADING } from './modules/pc1_loading/main'
include { MAD } from './modules/mad/main'
include { SUMMARY } from './modules/summary/main'

// default parameters defined in the config file

workflow {

	// read the input file and load data
	// into an input channel

	Channel
        .fromPath(params.input)
        .splitCsv(header:true, sep:'\t')
        .map { row -> 
            [row.experiment, row.datafile] 
		}
        .set { input_data_ch }

    // process the input data in parallel
	MEAN_SD(input_data_ch)
	PC1_LOADING(input_data_ch)
	MAD(input_data_ch)

	// collect the results from the previous processes
	all_stats = MEAN_SD.out.meansd.collect { it[1]}
	.combine(PC1_LOADING.out.pc1load.collect { it[1]})
	.combine(MAD.out.mad.collect { it[1]})

	// generate the summary
	SUMMARY(all_stats)

}