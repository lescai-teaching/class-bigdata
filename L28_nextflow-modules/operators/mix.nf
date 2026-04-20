def my_channel_1 = channel.of(1, 2, 3)
def my_channel_2 = channel.of('a', 'b')
def my_channel_3 = channel.of('z')

my_channel_1
    .mix(my_channel_2, my_channel_3)
    .view()
