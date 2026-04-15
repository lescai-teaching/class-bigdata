process headLine {

    input:
    path content

    output:
    stdout

    script:
    """
    head -n 1 $content
    """

}

workflow {

    def inputCh = channel.fromPath("${projectDir}/../files/content.txt")
    def resultsCh = headLine(inputCh)

    resultsCh.view()

}
