###
The Parser class exposes the method parse which attempts 
to extract a value from an input `source`.

Parser::parse (source) -> Result<Continuation, Message>

`parse` on a given source, returns either a `Success`
which contains a Continuation or a Failure which contains
a Message communicating why and where it failed.
###
{Result, Success, Failure} = require './Result'

class Parser
    constructor: (@parse) ->
    parse: (source) ->
        throw new Error 'Not Implemented'

###
A Continuation contains the value that was successfully
parsed out of source, and the remainder of source that
was not consumed.

When a `parse` succeeds we may continue by parsing the
remaining source with another parser.
###

class Continuation
    constructor: (@value, @source) ->

###
A Message contains human readable text explaining why the
parse failed and the source it failed on.
###

class Message
    constructor: (@text, @source) ->


{Result, Success, Failure} = require './Result'

class Parser.Succeed extends Parser
    constructor: (@value) ->

    parse: (source) ->
        continuation = new Continuation @value, source
        new Success continuation

class Parser.Fail extends Parser
    constructor: (@text) ->
    parse: (source) ->
        message = new Message @text, source
        new Failure message

{Port} = require './Port'

class Parser.Item extends Parser
    constructor: ->

    parse: (source) ->
        source = Port.from source

        if do source.isEmpty
            new Failure 'Source empty', source
        else
            val = source.take 1
            rest = source.drop 1
            continuation = new Continuation val, rest
            new Success continuation 

class Message
    # encode the reason for failure and the source location
    constructor: (@text, @source) ->

class Continuation
    # A Parser continuation contains a value
    # derived from a source and the remainder of the
    # source that is unparsed
    constructor: (@value, @source) ->

###
zero, return and chain implement the monad operations

By implementing these methods we can exploit
existing composability patterns for monadic values

* I'm using of as the name for return because
  return is a keyword in javascript (and coffeescript)
###        
Parser.zero = -> new Parser.Fail 'zero'
Parser.of = (v) -> new Parser.Succeed v
Parser.chain = (m, f) ->
    new Parser (source) =>
        (m.parse source).chain (c) ->
            # c is a continuation
            (f c.value, Parser).parse c.source



# It's also useful to have chain as an instance metho

Parser::chain = (f) -> Parser.chain this, f
Parser::of = Parser.of
Parser::map = (f) ->
    @chain (v) =>
        (@of || @constructor.of) (f v)


Parser.lazy = (makeParser) ->
    parser = null

    new Parser (input) ->
        parser ?= do makeParser
        parser.parse input

###
Add the static methods `Parser.from` and `Parser.addConverter`
these allow other modules to define a conversion from
another type to a Parser.
###
do -> 
    {addMethods} = require './From'
    addMethods Parser

exports.Parser = Parser
exports.Message = Message
exports.Continuation = Continuation
