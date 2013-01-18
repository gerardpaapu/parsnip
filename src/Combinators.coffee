{Parser} = require './Parser'
{bind, mreturn, mzero} = Parser

Parser::andThen = (parser) ->
    bind this, (v1) ->
        bind parser, (v2) ->
            mreturn [v1, v2]

Parser::convert = (converter) ->
    @bind (v) ->
        new Parser.Succeed converter v

Parser::convertTo = (Klass) ->
    @convert (v) -> new Klass v

Seq = Parser.Seq = (parsers) ->
    cons = (a, b) -> [a].concat b

    if parsers.length is 0
        new Parser.Succeed []
    else
        [first, rest...] = parsers

        first.bind (head) ->
            (Seq rest).bind (tail) ->
                new Parser.Succeed (cons head, tail)

Parser.from 'Array', Seq

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
    @bind (head) =>
        parseRest = (do @onceOrMore).maybe []
        parseRest.bind (tail) ->
            new Parser.Succeed (cons head, tail)

Parser::zeroOrMore = ->
    any = do @onceOrMore
    any.maybe []



