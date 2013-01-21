vows = require 'vows'
assert = require 'assert'
{keywordParser} = require '../src/keyword'

(vows.describe 'Parsing keywords')
    .addBatch
        'parsing null':
            topic: ->
                keywordParser.parse 'null rest'

            'It succeeds': (t) ->
                assert.ok t.didSucceed

            'With the correct value': (t) ->
                cont = t.value
                assert.equal cont.value, null

            'Leaving the remainder for the next parse': (t) ->
                assert.equal t.value.source, ' rest'

        'parsing true':
            topic: ->
                keywordParser.parse 'true rest'

            'It succeeds': (t) ->
                assert.ok t.didSucceed

            'With the correct value': (t) ->
                cont = t.value
                assert.equal cont.value, true

            'Leaving the remainder for the next parse': (t) ->
                assert.equal t.value.source, ' rest'

        'parsing false':
            topic: ->
                keywordParser.parse 'false rest'

            'It succeeds': (t) ->
                assert.ok t.didSucceed

            'With the correct value': (t) ->
                cont = t.value
                assert.equal cont.value, false

            'Leaving the remainder for the next parse': (t) ->
                assert.equal t.value.source, ' rest'

        'Fails on anything else':
            topic: ->
                keywordParser.parse 'undefined rest'

            'It fails': (t) ->
                assert.ok not t.didSucceed
    .export module