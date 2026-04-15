def myChannel1 = channel.of(1, 2, 3)
def myChannel2 = channel.of('a', 'b')
def myChannel3 = channel.of('z')

myChannel1
    .mix(myChannel2, myChannel3)
    .view()
