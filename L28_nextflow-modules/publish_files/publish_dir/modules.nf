process SPLITLETTERS {
    publishDir "${params.outdir}/chunks", mode: 'copy'

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
    publishDir "${params.outdir}/uppercase", mode: 'copy'

    input:
    path y

    output:
    path 'upper_*'

    script:
    """
    cat $y | tr '[:lower:]' '[:upper:]' > upper_${y}
    """
}
