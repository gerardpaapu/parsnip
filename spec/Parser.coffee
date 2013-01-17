vows = require 'vows'
assert = require 'assert'

{Parser} = require '../src/Parser'

(vows.describe 'Parser class core functionality')
    .addBatch
        'Parser.Succeed':
            topic: ->
                p = new Parser.Succeed 'foo'
                p.parse 'source'

            'It succeeds': (result) -> 
                assert.ok result.didSucceed

            'With the correct value': (result) ->
                {value} = result.value
                assert.equal value, 'foo'

            'Leaving the rest of the source behind': (result) ->
                {source} = result.value
                assert.equal source, source

        'Parser.Fail':
            topic: ->
                p = new Parser.Fail 'oops!'
                p.parse 'source'

            'It fails!': (result) ->
                assert.ok not result.didSucceed

            'With the correct message': (result) ->
                {message} = result
                assert.equal message.text, 'oops!'
                assert.equal message.source, 'source'

    .export module

