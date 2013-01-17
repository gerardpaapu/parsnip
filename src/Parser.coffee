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

class Parser.Exactly extends Parser
    constructor: (@string) ->
    parse: (source) ->
        head = source.slice 0, @string.length

        if head is @string
            rest = source.slice @string.length
            cont = new Continuation head, rest
            new Success cont
        else
            reason = "Source didn't match: '#{@string}'"
            message = new Message reason, source
            new Failure message

class Message
    # encode the reason for failure and the source location
    constructor: (@text, @source) ->

class Continuation
    # A Parser continuation contains a value
    # derived from a source and the remainder of the
    # source that is unparsed
    constructor: (@value, @source) ->

    # makeParserAndContinue: (makeParser: (v) -> Parser) -> Result
    makeParserAndContinue: (makeParser) ->
        (makeParser @value).parse @source

exports.Parser = Parser
exports.Message = Message
exports.Continuation = Continuation
