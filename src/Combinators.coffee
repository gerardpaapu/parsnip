{Parser, Message, Continuation} = require './Core'
{Success, Failure, Result} = require './Result'
{bind, mreturn, mzero} = Parser
{Port, Location} = require './Port'

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

        (Parser.from first).bind (head) ->
            (Seq rest).bind (tail) ->
                new Parser.Succeed (cons head, tail)

Parser.addConverter 'Array', Seq

Or = Parser.Or = (a, b) ->
    new Parser (source) ->
        result = a.parse source

        if result.didSucceed
            result
        else
            b.parse source

Parser::or = (other) ->
    Or this, other

Parser::maybe = (v) ->
    Or this, (new Parser.Succeed v)

Any = Parser.Any = (arr) ->
    if arr.length is 0
        new Parser.Fail 'no candidates'
    else if arr.length is 1
        arr[0]
    else if arr.length is 2
        Or arr[0], arr[1]
    else
        [first, rest...] = arr
        Or first, Any rest

Parser::onceOrMore = ->
    cons = (a, b) ->
        [a].concat b

    @bind (head) =>
        parseRest = (do @onceOrMore).maybe []
        parseRest.bind (tail) ->
            new Parser.Succeed (cons head, tail)

Parser::zeroOrMore = ->
    any = do @onceOrMore
    any.maybe []

Parser::precededBy = (prefix) ->
    (Parser.from prefix)
        .bind (_) => this

Parser::followedBy = (suffix) ->
    @bind (v1) ->
        (Parser.from suffix).bind (_) ->
            mreturn v1

Parser::surroundedBy = (left, right) ->
    (@precededBy left).followedBy right

Parser::is = (test) ->
    @bind (v1) ->
        if (test v1)
            mreturn v1
        else
            new Parser.Fail 'Failed predicate'

Parser::isnt = (test) ->
    @is (v) -> !(test v)

Parser::separatedBy = (comma) ->
    comma = Parser.from comma
    squash = ([a, b]) ->
        [a].concat b

    # p' := p tail
    # tail := epsilon
    #      := comma p

    tail = (@precededBy comma)
        .zeroOrMore()

    @andThen(tail).convert(squash)

Parser::withLocation = (fn) ->
    new Parser (_source) =>
        _source = Port.from _source
        start = _source.getLocation()

        (@parse _source).bind (cont) ->
            {source, value} = cont
            end = source.getLocation()
            _value = fn value, start, end

            next = new Continuation _value, source
            new Success next

Parser::tag = (tag_str) ->
    @withLocation (value, start, end) ->
        type: tag_str
        value: value
        start: start
        end: end

Parser::toFunction = (opts) ->
    (source) =>
        opts ?= {}
        result = @parse(source)
        if result.didSucceed
            cont = result.value
            complete = do cont.source.isEmpty

            if opts.noTrailing and !complete
               throw new Error "Trailing Characters #{cont.source}"

            cont.value
        else
            throw new SyntaxError result.message
