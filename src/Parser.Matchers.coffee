{Parser, Continuation, Message} = require './Parser'
{Result, Success, Failure} = require './Result'
{Port} = require './Port'

class Parser.Exactly extends Parser
    constructor: (@string) ->
    parse: (source) ->
        source = Port.from source
        head = source.slice 0, @string.length

        if head is @string
            rest = source.slice @string.length
            cont = new Continuation head, rest
            new Success cont
        else
            reason = "Source didn't match: '#{@string}'"
            message = new Message reason, source
            new Failure message

Parser.addConverter 'String', (str) ->
    new Parser.Exactly str

cloneRegexp = (source) ->
    destination = new RegExp(source.source)

    destination.global = source.global
    destination.ignoreCase = source.ignoreCase
    destination.multiline = source.multiline

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

    parse: (input) ->
        input = Port.from input
        pattern = do @getPattern
        match = pattern.exec (do input.slice)

        if match?
            val = match[@index]
            rest = input.drop match[0].length
            cont = new Continuation val, rest
            new Success cont
        else
            message = "Source didn't match: /#{pattern.source}/"
            new Failure message


Parser.addConverter 'RegExp', (str) ->
    new Parser.RegExp str
