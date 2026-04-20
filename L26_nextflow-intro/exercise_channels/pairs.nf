workflow {
    channel
        .fromFilePairs('./files/*_{1,2}.txt')
        .view { "value: $it" }
}
