#!/usr/bin/env nextflow

params.input = "$projectDir/../../files/content.txt"

process splitLines {

    input:
    path file

    output:
    path 'line_*'

    script:
    """
    count=0
    while read -r line
    do
        let "count+=1"
        echo \$line > line_\$count
    done < $file
    """
}

process getLast {

    input:
    path file

    output:
    stdout

    script:
    """
    cat $file | awk '{print \$NF}'
    """
}

workflow {
    def input_ch = channel.fromPath(params.input)
    def single_lines_ch = splitLines(input_ch)
    def results_ch = getLast(single_lines_ch)
    results_ch.view()
}
