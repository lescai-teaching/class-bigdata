workflow {
    def letters = ['A', 'B', 'C']

    channel
        .fromList(letters)
        .view()

    channel
        .value(letters)
        .view()
}
