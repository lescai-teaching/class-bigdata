def input_data_ch = channel
    .fromPath(params.input)
    .splitCsv(header: true, sep: '\t')
    .map { row -> [row.experiment, row.datafile] }
