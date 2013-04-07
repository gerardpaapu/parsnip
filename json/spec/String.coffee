vows = require 'vows'
assert = require 'assert'
{stringParser} = require '../src/String'

(vows.describe 'Parsing Strings')
    .addBatch
        'When parsing an empty string':
            topic: ->
                stringParser.parse '"" rest'

            'It succeeds': (t) ->
                assert.ok t.didSucceed

            'With the correct value': (t) ->
                cont = t.value
                assert.equal cont.value, ''

            'Leaving the remainder for the next parse': (t) ->
                assert.equal t.value.source, ' rest'

        'When parsing a unicode literal':
            topic: ->
                stringParser.parse '"\\u99ff" rest'

            'It succeeds': (t) ->
                assert.ok t.didSucceed

            'With the correct value': (t) ->
                assert.equal t.value.value,  '\u99ff'

            'Leaving the remainder for the next parse': (t) ->
                assert.equal t.value.source, ' rest'

        'When parsing a non-string':
            topic: ->
                stringParser.parse 'lolercoasters'

            'It fails': (t) ->
                assert.ok not t.didSucceed

    .export module
