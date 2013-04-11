{Parser, Continuation, Message} = require './Core'
{Result, Success, Failure} = require './Result'
{Port} = require './Port'

class Parser.Exactly extends Parser
    constructor: (@string) ->
    parse: (source) ->
        source = Port.from source
        head = source.slice 0, @string.length

        if head is @string
            rest = source.move @string.length
            cont = new Continuation head, rest
            new Success cont
        else
            reason = "Source didn't match: '#{@string}'"
            message = new Message reason, source
            new Failure message

Parser.addConverter 'String', (str) ->
    new Parser.Exactly str

cloneRegexp = (source) ->
    src = source.source
    if (src.charAt 0) isnt '^'
        src = '^' + src

    flags = [
        if source.global then 'g' else '',
        if source.ignoreCase then 'i' else '',
        if source.multiline then 'm' else '',
    ].join('')

    destination = new RegExp src, flags

    destination

class Parser.RegExp extends Parser
    constructor: (pattern, index) ->
        @_pattern = pattern
        @index = index ? 0

    getPattern: ->
        # clone the RegExp each time we use it
        # because JS RegExp objects are stateful
        # and we don't want that baggage
        cloneRegexp @_pattern

    parse: (source) ->
        source = Port.from source
        pattern = do @getPattern
        match = pattern.exec (do source.slice)

        if match?
            val = match[@index]
            rest = source.move match[0].length
            cont = new Continuation val, rest
            new Success cont
        else
            reason = "Source didn't match: /#{pattern.source}/"
            message = new Message reason, source
            new Failure message


Parser.addConverter 'RegExp', (str) ->
    new Parser.RegExp str

Parser.EOF = new Parser (source) ->
    source = Port.from source

    if source.isEmpty()
        new Success (new Continuation null, source)
    else
        new Failure (new Message 'Expected EOF', source)
