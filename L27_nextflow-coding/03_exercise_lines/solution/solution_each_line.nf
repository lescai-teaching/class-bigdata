#!/usr/bin/env nextflow

params.input  = '../files/content.txt'
input_ch = Channel.fromPath(params.input)

process splitLines {

    input:
    path file

    output:
    path "line_*"

    script:
    """
    count=0
    while read -r line
    do
        let "count+=1"
        echo \$line >line_\$count
    done < $file
    """
}

process getLast {

    input:
    path file

    output:
    stdout

    """
    cat $file | awk '{print \$NF}'
    """
}

workflow {
    single_lines_ch = splitLines( input_ch )
    results_ch = getLast( single_lines_ch )
    results_ch.view()
}


