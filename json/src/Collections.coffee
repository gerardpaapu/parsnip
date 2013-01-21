{Parser} = require '../../src/Parser'
require '../../src/Parser.Matchers'
require '../../src/Combinators'

{Any} = Parser
{stringParser} = require './String'

whitespace = (Parser.from /[ \r\n\t]*/)

IW = (p) ->
    (Parser.from p)
        .surroundedBy(whitespace, whitespace)

delay = (makeParser) ->
    parser = null

    new Parser (input) ->
        parser ?= do makeParser
        parser.parse input

value = (atom) ->
    IW Any [ atom,
             (delay -> arrayParser atom),
             (delay -> objectParser atom)]

arrayParser = (atom) ->
    (value atom)
        .separatedBy(IW ',')
        .maybe([])
        .surroundedBy((IW '['), (IW ']'))

associate = (arr) ->
    result = {}
    for [k, v] in arr
        result[k] = v

    result


objectParser = (atom) ->
    (Parser.from [stringParser, (IW ':'), (value atom)])
        .convert(([key, colon, value]) -> [key, value])
        .separatedBy(IW ',')
        .maybe([])
        .surroundedBy((IW '{'), (IW '}'))
        .convert(associate)


exports.arrayParser = arrayParser
exports.objectParser = objectParser
exports.value = objectParser
exports.ignoreWhitespace = IW

