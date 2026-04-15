
// first option

def nums = channel.of(1, 2, 3, 4)
def square = nums.map { number -> number * number }
square.view()

// second option to chain operators

channel
    .of(1, 2, 3, 4)
    .map { number -> number * number }
    .view()

// apply any function

channel
    .of('hello', 'world')
    .map { word -> word.reverse() }
    .view()

// or create new tuples

channel
    .of('hello', 'world')
    .map { word -> [word, word.size()] }
    .view { word, len -> "$word contains $len letters" }
