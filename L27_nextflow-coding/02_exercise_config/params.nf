// workflow script
params.foo = 'Hello'
params.bar = 'world!'

workflow {
    println "${params.foo} ${params.bar}"
}
