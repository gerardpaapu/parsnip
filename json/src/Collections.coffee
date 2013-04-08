{Parser} = require '../lib/Parsnip'

{Any, lazy, Seq} = Parser
{stringParser} = require './String'

whitespace = (Parser.from /[ \r\n\t]*/)

IW = (p) ->
    (Parser.from p)
        .surroundedBy(whitespace, whitespace)

associate = (arr) ->
    result = {}
    for [k, v] in arr
        result[k] = v

    result

collectionsOf = (atom) ->
    value = lazy ->
        IW (Any [atom, arrayParser, objectParser])

    arrayParser = lazy ->
        value
            .separatedBy(IW ',')
            .maybe([])
            .surroundedBy((IW '['), (IW ']'))

    objectParser = lazy ->
        (Seq [stringParser, (IW ':'), value])
            .convert(([key, colon, value]) -> [key, value])
            .separatedBy(IW ',')
            .maybe([])
            .surroundedBy((IW '{'), (IW '}'))
            .convert(associate)

    {value, objectParser, arrayParser} 

exports.collectionsOf = collectionsOf
exports.ignoreWhitespace = IW
