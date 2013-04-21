{Parser, Message, Continuation} = require './Core'
{Success, Failure, Result} = require './Result'
{chain, of: $of, zero} = Parser
{Port, Location} = require './Port'

Parser::andThen = (parser) ->
    this.chain (v1) ->
        parser.chain (v2) ->
            $of [v1, v2]

Parser::convert = (converter) ->
    @chain (v) ->
        new Parser.Succeed converter v

Parser::convertTo = (Klass) ->
    @convert (v) -> new Klass v

# append :: (Monad m) => [m a] -> m [a]
append = (M) ->
    (ls) ->
        cons = (a, b) -> [a].concat b

        if ls.length is 0
            M.of []
        else
            [first, rest...] = ls
            chain first, (a) ->
                ((append M) rest).map (b) ->
                     cons a, b

Seq = Parser.Seq = (parsers) ->
    (append Parser)(Parser.from p for p in parsers)
###
    cons = (a, b) -> [a].concat b

    if parsers.length is 0
        Parser.of []
    else
        [first, rest...] = parsers

        (Parser.from first).chain (head) ->
            (Seq rest).chain (tail) ->
                Parser.of (cons head, tail)
###

Parser.addConverter 'Array', Seq

Or = Parser.Or = (a, b) ->
    (Parser.from a).or b

Parser::concat = (other) ->
    new Parser (source) =>
        (@parse source).lconcat ->
            (Parser.from other).parse source
            
Parser::or = Parser::concat

Parser::maybe = (v) ->
    Or this, (new Parser.Succeed v)

Any = Parser.Any = (arr) ->
    if arr.length is 0
        new Parser.Fail 'no candidates'
    else if arr.length is 1
        Parser.from arr[0]
    else if arr.length is 2
        Or arr[0], arr[1]
    else
        [first, rest...] = arr
        Or first, Any rest

Parser::onceOrMore = ->
    cons = (a, b) ->
        [a].concat b

    @chain (head) =>
        parseRest = (do @onceOrMore).maybe []
        parseRest.chain (tail) ->
            new Parser.Succeed (cons head, tail)

Parser::zeroOrMore = ->
    any = do @onceOrMore
    any.maybe []

Parser::precededBy = (prefix) ->
    (Parser.from prefix)
        .chain (_) => this

Parser::followedBy = (suffix) ->
    @chain (v1) ->
        (Parser.from suffix).chain (_) ->
            $of v1

Parser::surroundedBy = (left, right) ->
    (@precededBy left).followedBy right

Parser::is = (test) ->
    @chain (v1) ->
        if (test v1)
            $of v1
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

        (@parse _source).chain (cont) ->
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
            text = result.message.text
            loc = result.message.source.getLocation()
            throw new SyntaxError "#{text} #{loc}"

Parser::dontConsume = ->
    new Parser (source) =>
        (@parse source).chain (c) ->
            new Success (new Continuation c.value, source)

Parser::lookAhead = (p) ->
    p = Parser.from p
    @followedBy (do p.dontConsume)