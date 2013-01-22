vows = require 'vows'
assert = require 'assert'

{Parser, Continuation, Message, Port} = require '../src/index'

takeFoo = Parser.from 'foo'
takeBar = Parser.from 'bar'
takeDigit = Parser.from /\d/
big = (n) -> +n >= 5

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

        'Parser.Seq':
            topic: ->
                Parser.Seq ['foo', 'bar', 'baz']

            'Succeeds on foobarbaz': (topic) ->
                result = topic.parse 'foobarbazrest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation ['foo', 'bar', 'baz'], 'rest'),
                    result.value)

            'Fails on other input': (topic) ->
                result = topic.parse 'foorest'
                assert.ok not result.didSucceed
                assert.deepEqual(
                    (new Message "Source didn't match: 'bar'", new Port 'rest'),
                    result.message)

        'Parser.from Array':
            topic: ->
                Parser.from ['foo', 'bar', 'baz']

            'Succeeds on foobarbaz': (topic) ->
                result = topic.parse 'foobarbazrest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation ['foo', 'bar', 'baz'], 'rest'),
                    result.value)

            'Fails on other input': (topic) ->
                result = topic.parse 'foorest'
                assert.ok not result.didSucceed
                assert.deepEqual(
                    (new Message "Source didn't match: 'bar'", new Port 'rest'),
                    result.message)

        'Parser::maybe':
            topic: ->
                takeFoo.maybe 'failed'

            'Succeeds as original': (topic) ->
                result = topic.parse 'foorest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation 'foo', 'rest'),
                    result.value)

            'Succeeds with fallback': (topic) ->
                result = topic.parse 'barrest'
                assert.ok result.didSucceed
                assert.deepEqual(
                    (new Continuation 'failed', 'barrest'),
                    result.value)

        'Parser::surroundedBy':
            topic: ->
                takeFoo.surroundedBy takeBar, takeBar

            'Fails on original': (topic) ->
                result = topic.parse 'foo'
                assert.ok not result.didSucceed

            'Fails with left half': (topic) ->
                result = topic.parse 'barfoo'
                assert.ok not result.didSucceed

            'Succeeds when surrounded': (topic) ->
                result = topic.parse 'barfoobarrest'
                assert.deepEqual(
                    (new Continuation 'foo', 'rest'),
                    result.value)

        'Parser::separatedBy':
            topic: ->
                takeFoo.separatedBy takeBar

            'Succeeds on original': (topic) ->
                result = topic.parse 'foo'
                assert.ok result.didSucceed
                cont = result.value
                assert.deepEqual cont.value, ['foo']

            'Succeeds with a comma': (topic) ->
                result = topic.parse 'foobarfoorest'
                assert.ok result.didSucceed
                cont = result.value
                assert.deepEqual cont.value, ['foo', 'foo']
                assert.equal (String cont.source), 'rest'

            'Excludes trailing comma': (topic) ->
                result = topic.parse 'foobarfoobarrest'
                assert.ok result.didSucceed
                cont = result.value
                assert.deepEqual cont.value, ['foo', 'foo']
                assert.equal (String cont.source), 'barrest'

            'Fails on just the comma': (topic) ->
                result = topic.parse 'bar'
                assert.ok not result.didSucceed

        'Parser::is':
            topic: ->
                takeDigit.is big

            'Succeeds on big digits': (topic) ->
                [5, 6, 7, 8, 9].forEach (n) ->
                    result = topic.parse "#{n} rest"
                    assert.ok result.didSucceed 
                    assert.equal result.value.value, n
                    assert.equal (String result.value.source), ' rest'

            'Fails on small digits': (topic) ->
                [0, 1, 2, 3, 4].forEach (n) ->
                    result = topic.parse "#{n} rest"
                    assert.ok not result.didSucceed 

        'Parser::isnt':
            topic: ->
                takeDigit.isnt big

            'Fails on big digits': (topic) ->
                [5, 6, 7, 8, 9].forEach (n) ->
                    result = topic.parse "#{n} rest"
                    assert.ok not result.didSucceed 

            'Succeeds on small digits': (topic) ->
                [0, 1, 2, 3, 4].forEach (n) ->
                    result = topic.parse "#{n} rest"
                    assert.ok result.didSucceed 
                    assert.equal result.value.value, n
                    assert.equal (String result.value.source), ' rest'

    .export module
