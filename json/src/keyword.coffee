{Parser} = require '../../src/Parser'
require '../../src/Parser.Matchers'
require '../../src/Combinators'
{Any} = Parser

exports.keywordParser = do ->
    parserFor = (v) ->
        (Parser.from (String v))
            .convert (_) -> v

    Any ([true, false, null].map parserFor)
