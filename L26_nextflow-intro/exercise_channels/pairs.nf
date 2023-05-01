ch_files = Channel.fromFilePairs("./files/*_{1,2}.txt")
ch_files.view{ "value: $it"}