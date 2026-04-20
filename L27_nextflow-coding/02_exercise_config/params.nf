// workflow script
params.foo = 'Hello'
params.bar = 'world!'

workflow {
    // print both params
    println "${params.foo} ${params.bar}"
}
