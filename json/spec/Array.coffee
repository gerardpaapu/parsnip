
whitespace = (Parser.from /\w+/).maybe null

IW = (p) ->
    (Parser.from p)
        .surroundedBy whitespace

exports.arrayParser = (atom) ->
    atom
        .separatedBy (IW ',')
        .surroundedBy (IW '['), (IW ')')