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

	def inputDataCh = channel
        .fromPath(params.input)
        .splitCsv(header:true, sep:'\t')
        .map { row ->
            [row.experiment, file(row.datafile)]
		}

    // process the input data in parallel
	MEAN_SD(inputDataCh)
	PC1_LOADING(inputDataCh)
	MAD(inputDataCh)

	// collect the results from the previous processes
	def allStatsCh = MEAN_SD.out.meansd
		.collect { tupleValue -> tupleValue[1] }
		.combine(PC1_LOADING.out.pc1load.collect { tupleValue -> tupleValue[1] })
		.combine(MAD.out.mad.collect { tupleValue -> tupleValue[1] })

	// generate the summary
	SUMMARY(allStatsCh)

}
