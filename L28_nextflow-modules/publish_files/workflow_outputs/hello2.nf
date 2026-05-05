#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

include { SPLITLETTERS } from './modules.nf'
include { CONVERTTOUPPER } from './modules.nf'

workflow {
    main:
    def greeting_ch = channel.of(params.greeting)
    def letters_ch = SPLITLETTERS(greeting_ch)
    def results_ch = CONVERTTOUPPER(letters_ch.flatten())
    results_ch.view { file -> file }

    publish:
    chunks = letters_ch
    uppercase = results_ch
}

output {
    chunks {
        path 'chunks'
    }

    uppercase {
        path 'uppercase'
    }
}
