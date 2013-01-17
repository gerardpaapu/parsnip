{Parser} = require './Parser'

Parser::continueWith = (createParser) ->
    new Parser (source) =>
        bind (@parse source), (c) ->
            parser = createParser c.value
            parser.parse c.source

Parser::andThen = (parser) ->
    @continueWith (v1) ->
        parser.continueWith (v2) ->
            new Parser.Succeed [v1, v2]

Parser::convert = (converter) ->
    @continueWith (v) ->
        new Parser.Succeed converter v

Parser::convertTo = (Klass) ->
    @convert (v) -> new Klass v

Seq = Parser.Seq = (parsers) ->
    cons = (a, b) -> [a].concat b

    if parsers.length is 0
        new Parser.Succeed []
    else
        [first, rest...] = parsers

        first.continueWith (head) ->
            (Seq rest).continueWith (tail) ->
                new Parser.Succeed (cons head, tail)

Or = Parser.Or = (a, b) ->
    new Parser (source) ->
        result = a.parse source

        if result.didSucceed
            result
        else
            b.parse source

Parser::maybe = (v) ->
    Or this, (new Parser.Succeed v)

Parser::onceOrMore = ->
    @continueWith (head) =>
        parseRest = (do @onceOrMore).maybe []
        parseRest.continueWith (tail) ->
            new Parser.Succeed (cons head, tail)

Parser::zeroOrMore = ->
    any = do @onceOrMore
    any.maybe []



