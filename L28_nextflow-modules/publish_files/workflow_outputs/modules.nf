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
    path 'upper_*'

    script:
    """
    cat $y | tr '[:lower:]' '[:upper:]' > upper_${y}
    """
}
