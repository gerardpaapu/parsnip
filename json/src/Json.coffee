{Parser, Port} = require '../lib/Parser'

{Any} = Parser

{stringParser} = require './String'
{numberParser} = require './Number'
{keywordParser} = require './keyword'
{value} = require './Collections'

JSONParser = do ->
    value Any [stringParser, numberParser, keywordParser]

parseJSON = (source) ->
    source = Port.from source
    result = JSONParser.parse source
    unless result.didSucceed
       throw new SyntaxError "Invalid JSON"

    continuation = result.value
    unless continuation.source.isEmpty is 0
        throw new SyntaxError "Trailing Characters"

    continuation.value

exports.parseJSON = parseJSON
exports.JSONParser = JSONParser


