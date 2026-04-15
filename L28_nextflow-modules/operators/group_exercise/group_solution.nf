channel
    .fromPath("${projectDir}/record*")
    .map { file -> tuple(file.baseName, file) }
    .groupTuple()
    .view { baseName, file -> "> $baseName : $file" }
