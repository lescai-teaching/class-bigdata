#!/usr/bin/env nextflow

params.input  = '../files/content.txt'
input_ch = Channel.fromPath(params.input)

process splitLines {

    input:
    path file from input_ch

    output:
    file 'line_*' into split_ch

    """
    count=0
    while read -r line
    do
    ((count++))
    echo \$line >line_\$count
    done <$file
    """
}

process getLast {

    input:
    path file from split_ch

    output:
    stdout results_ch

    """
    cat $file | awk '{print \$NF}'
    """
}


results_ch.view()

