{Parser} = require '../../src/Parser'
require '../../src/Parser.Matchers'
require '../../src/Combinators'

{Any} = Parser
{stringParser} = require './String'
whitespace = (Parser.from /\w+/).maybe null

IW = (p) ->
    (Parser.from p)
        .surroundedBy whitespace, whitespace

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
        .separatedBy (IW ',')
        .surroundedBy (IW '['), (IW ')')

objectParser = (atom) ->
    (Parser.from [stringParser, (IW ':'), (value atom)])
        .separatedBy IW ','
        .surroundedBy '{', '}'

exports.arrayParser = arrayParser
exports.objectParser = objectParser
exports.value = objectParser

