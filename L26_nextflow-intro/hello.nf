#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

process SPLITLETTERS {
    input:
    val x

    output:
    path 'chunk_*'

    script:
    """
    printf '$x' | split -b 6 - chunk_
    """
}

process CONVERTTOUPPER {
    input:
    path y

    output:
    stdout

    script:
    """
    cat $y | tr '[a-z]' '[A-Z]'
    """
}

workflow {
    def greeting_ch = channel.of(params.greeting)
    def letters_ch = SPLITLETTERS(greeting_ch)
    def results_ch = CONVERTTOUPPER(letters_ch.flatten())
    results_ch.view { it }
}
