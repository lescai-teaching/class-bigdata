#!/usr/bin/env nextflow

// load modules
include { READ_DATA                } from './modules/reading.nf'
include { RUNMODEL as LOGREG       } from './modules/runmodel.nf'
include { RUNMODEL as RANDOMFOREST } from './modules/runmodel.nf'

// run workflow
workflow {
	def inputCh = channel.fromPath(params.input)
	def importScriptCh = channel.value(file("${projectDir}/scripts/run_import.R"))
	def logregScriptCh = channel.value(file("${projectDir}/scripts/run_logistic_model.R"))
	def randomForestScriptCh = channel.value(file("${projectDir}/scripts/run_random_forest.R"))

	READ_DATA(inputCh, importScriptCh)
	LOGREG(READ_DATA.out.dataset, logregScriptCh, 'logreg')
	RANDOMFOREST(READ_DATA.out.dataset, randomForestScriptCh, 'randomforest')
}
