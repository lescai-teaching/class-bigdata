
// first option

nums = Channel.of(1, 2, 3, 4) 
square = nums.map { it -> it * it } 
square.view() 

// second option to chain operators

Channel
    .of(1, 2, 3, 4)
    .map { it -> it * it }
    .view()

// apply any function

Channel
    .of('hello', 'world')
    .map { it -> it.reverse() }
    .view()

// or create new tuples

Channel
    .of('hello', 'world')
    .map { word -> [word, word.size()] }
    .view { word, len -> "$word contains $len letters" }

