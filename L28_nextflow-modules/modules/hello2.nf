#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

include { SPLITLETTERS   } from './modules.nf'
include { CONVERTTOUPPER } from './modules.nf'

workflow {
    def greetingCh = channel.of(params.greeting)
    def lettersCh = SPLITLETTERS(greetingCh)
    def resultsCh = CONVERTTOUPPER(lettersCh.flatten())

    resultsCh.view()
}
