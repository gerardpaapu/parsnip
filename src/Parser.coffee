# Calling Parser::parse(source : Port) returns a Result.
class Parser
    constructor: (@parse) ->
    parse: (source) ->
        throw new Error 'Not Implemented'

class Parser.Succeed extends Parser
    constructor: (@value) ->
    parse: (source) ->
        new Success @value, source

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

Parser::continueWith = (createParser) ->
    new Parser (source) =>
        bind (@parse source), (c) ->
            c.makeParserAndContinue createParser

Parser::andThen = (parser) ->
    @continueWith (v1) ->
        parser.continueWith (v2) ->
            new Parser.Succeed [v1, v2]

Parser::convert = (converter) ->
    @continueWith (v) ->
        new Parser.Succeed converter v

Parser::convertTo = (Klass) ->
    @convert (v) -> new Klass v
