ch_input = Channel.fromPath('../files/content.txt')

process headLine {

    input:
    file content

    output:
    stdout

    script:
    """
    head -n 1 $content
    """

}

workflow {

    results_ch = headLine( ch_input )
    results_ch.view()

}