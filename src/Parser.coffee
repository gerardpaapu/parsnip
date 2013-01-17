# Calling Parser::parse(source : Port) returns a Result.
{Result, Success, Failure} = require './Result'

class Parser
    constructor: (@parse) ->
    parse: (source) ->
        throw new Error 'Not Implemented'

class Parser.Succeed extends Parser
    constructor: (@value) ->

    parse: (source) ->
        continuation = new Continuation @value, source
        new Success continuation

class Parser.Fail extends Parser
    constructor: (@message) ->
    parse: (source) ->
        new Failure @message

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