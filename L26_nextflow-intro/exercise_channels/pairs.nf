def filesCh = channel.fromFilePairs('./files/*_{1,2}.txt')

filesCh.view { filePair -> "value: ${filePair}" }
