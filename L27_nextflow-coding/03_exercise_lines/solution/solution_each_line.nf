#!/usr/bin/env nextflow

params.input = "${projectDir}/../../files/content.txt"

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

    script:
    """
    awk '{print \$NF}' "$file"
    """
}

workflow {
    def inputCh = channel.fromPath(params.input)
    def singleLinesCh = splitLines(inputCh)
    def resultsCh = getLast(singleLinesCh.flatten())

    resultsCh.view()
}
