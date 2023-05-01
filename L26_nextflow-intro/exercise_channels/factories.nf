def letters = ['A', 'B', 'C']


Channel.fromList(letters)
.view()


Channel.value(letters)
.view()