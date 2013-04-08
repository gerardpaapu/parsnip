{Parser, Port} = require '../lib/Parsnip'

{Any, lazy} = Parser

{stringParser} = require './String'
{numberParser} = require './Number'
{keywordParser} = require './keyword'
{collectionOf} = require './Collections'

atom = (Any [stringParser, numberParser, keywordParser])
{value, arrayParser, objectParser} = collectionOf atom

exports.JSONParser = value
exports.parseJSON = value.toFunction()

exports.Number = numberParser
exports.String = stringParser
exports.Array = arrayParser
exports.Object = objectParser
