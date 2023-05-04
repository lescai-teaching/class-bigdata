my_channel_1 = Channel.of(1, 2, 3)
my_channel_2 = Channel.of('a', 'b')
my_channel_3 = Channel.of('z')

my_channel_1
    .mix(my_channel_2, my_channel_3)
    .view()
