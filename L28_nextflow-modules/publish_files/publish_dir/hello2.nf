#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

include { SPLITLETTERS } from './modules.nf'
include { CONVERTTOUPPER } from './modules.nf'

workflow {
    def greeting_ch = channel.of(params.greeting)
    def letters_ch = SPLITLETTERS(greeting_ch)
    def results_ch = CONVERTTOUPPER(letters_ch.flatten())
    results_ch.view { file -> file }
}
