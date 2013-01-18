vows = require 'vows'
assert = require 'assert'

{Parser, Continuation, Message} = require '../src/Parser'
require '../src/Parser.Matchers'
require '../src/Combinators'

takeFoo = Parser.from 'foo'
takeBar = Parser.from 'bar'

(vows.describe 'Testing combinators')
    .addBatch
        'Parser::andThen':
            topic: ->
                takeFoo.andThen takeBar

            'Succeeds on \'foobar\'': (topic) ->
                result = topic.parse 'foobarrest'
                assert.ok result.didSucceed

            'With the correct value': (topic) ->
                result = topic.parse 'foobarrest'
                assert.deepEqual(
                    (new Continuation ['foo', 'bar'], 'rest'),
                    result.value)

            'Fails on \'foosomething\'': (topic) ->
                result = topic.parse 'foosomething'
                assert.ok not result.didSucceed

        'Parser::convert':
            topic: ->
                takeFoo.convert (v) -> 'text'

            'Succeeds on \'foo\'': (topic) ->
                result = topic.parse 'foorest'
                assert.ok result.didSucceed

            'With the correct value': (topic) ->
                result = topic.parse 'foorest'
                assert.deepEqual(
                    (new Continuation 'text', 'rest'),
                    result.value)

    .export module
