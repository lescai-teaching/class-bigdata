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
    tr '[:lower:]' '[:upper:]' < "$y"
    """
}

workflow {
    def greetingCh = channel.of(params.greeting)
    def lettersCh = SPLITLETTERS(greetingCh)
    def resultsCh = CONVERTTOUPPER(lettersCh.flatten())

    resultsCh.view()
}
