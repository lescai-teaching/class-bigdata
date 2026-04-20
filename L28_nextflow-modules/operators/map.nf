// first option

def nums = channel.of(1, 2, 3, 4)
def square = nums.map { it -> it * it }
square.view()

// second option to chain operators

channel
    .of(1, 2, 3, 4)
    .map { it -> it * it }
    .view()

// apply any function

channel
    .of('hello', 'world')
    .map { it -> it.reverse() }
    .view()

// or create new tuples

channel
    .of('hello', 'world')
    .map { word -> [word, word.size()] }
    .view { word, len -> "$word contains $len letters" }
