vows = require 'vows'
assert = require 'assert'

{Parser, Continuation, Message} = require '../src/Parser'
{Port} = require '../src/Port'
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

            'Fails as on other text': (topic) ->
                result = topic.parse 'othershit'
                assert.ok not result.didSucceed

        'Parser::or':
            topic: ->
                takeFoo.or takeBar

            'Succeeds as with the left parser': (topic) ->
                result = topic.parse 'foorest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation 'foo', 'rest'),
                    result.value)

            'Succeeds as with the right parser': (topic) ->
                result = topic.parse 'barrest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation 'bar', 'rest'),
                    result.value)

            'Fails with other input': (topic) ->


        'Parser::onceOrMore':
            topic: ->
                do takeFoo.onceOrMore

            'Succeeds as the original': (topic) ->
                result = topic.parse 'foorest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation ['foo'], 'rest'),
                    result.value)

            'Succeeds multiple times': (topic) ->
                result = topic.parse 'foofoofoorest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation ['foo', 'foo', 'foo'], 'rest'),
                    result.value)


            'Fails as the original': (topic) ->
                result = topic.parse 'bar'
                assert.ok not result.didSucceed
                assert.deepEqual(
                    (new Message "Source didn't match: 'foo'", new Port 'bar'),
                    result.message)

        'Parser::zeroOrMore':
            topic: ->
                do takeFoo.zeroOrMore

            'Succeeds as the original': (topic) ->
                result = topic.parse 'foorest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation ['foo'], 'rest'),
                    result.value)

            'Succeeds multiple times': (topic) ->
                result = topic.parse 'foofoofoorest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation ['foo', 'foo', 'foo'], 'rest'),
                    result.value)


            'Doesn\'t fail': (topic) ->
                result = topic.parse 'bar'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation [], 'bar'),
                    result.value)


    .export module
