def inputDataCh = channel
    .fromPath(params.input)
    .splitCsv(header:true, sep:'\t')
    .map { row ->
        [row.experiment, file(row.datafile)]
	}

inputDataCh.view()
