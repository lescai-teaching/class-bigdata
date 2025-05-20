Channel
    .fromPath(params.input)
    .splitCsv(header:true, sep:'\t')
    .map { row -> 
        [row.experiment, row.datafile] 
	}
    .set { input_data_ch }