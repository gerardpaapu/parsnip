{Parser} = require './lib/Parser'

pattern = ///
    (-)?  # optional leading sign
    (0|([1-9][0-9]*)) # digits before the decimal
    (.[0-9]+)? # digits after the decimal
    ((e|E)(\+|-)?[0-9]+)? # scientific notation
///

number = (Parser.from pattern)
    .convert (str) ->
        parseFloat str, 10

exports.numberParser = number
