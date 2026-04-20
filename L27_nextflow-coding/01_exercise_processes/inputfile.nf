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
    def ch_input = channel.fromPath('../files/content.txt')
    def results_ch = headLine(ch_input)
    results_ch.view()
}
