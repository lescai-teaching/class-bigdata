Channel
    .fromPath('group_exercise/*')
    .map { file -> tuple(file.baseName, file) }
    .groupTuple()
    .view { baseName, file -> "> $baseName : $file" }