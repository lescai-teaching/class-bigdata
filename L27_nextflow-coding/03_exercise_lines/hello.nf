#!/usr/bin/env nextflow

params.greeting = 'Hello world!'

process splitLetters {

    input:
    val x

    output:
    path 'chunk_*'

    script:
    """
    printf '$x' | split -b 6 - chunk_
    """
}

process convertToUpper {

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
    def greetingCh = channel.of(params.greeting)
    def lettersCh = splitLetters(greetingCh)
    def uppercaseCh = convertToUpper(lettersCh.flatten())

    uppercaseCh.view { value -> value.trim() }

}
