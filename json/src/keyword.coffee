{Parser} = require '../lib/Parsnip'
{Any} = Parser

exports.keywordParser = do ->
    parserFor = (v) ->
        (Parser.from (String v))
            .convert (_) -> v

    Any ([true, false, null].map parserFor)
