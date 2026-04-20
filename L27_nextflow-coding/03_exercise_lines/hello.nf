#!/usr/bin/env nextflow

nextflow.enable.dsl=2

process splitLetters {

    input:
    val x

    output:
    file 'chunk_*'

    script:
    """
    printf '$x' | split -b 6 - chunk_
    """
}

process convertToUpper {

    input:
    file y

    output:
    stdout

    script:
    """
    cat $y | tr '[a-z]' '[A-Z]'
    """
}

params.greeting = 'Hello world!'

workflow {
    def greeting_ch = channel.of(params.greeting)
    def letters_ch = splitLetters(greeting_ch)
    def uppercase_ch = convertToUpper(letters_ch.flatten())
    uppercase_ch.view { it.trim() }
}
