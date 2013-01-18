vows = require 'vows'
assert = require 'assert'

{Parser} = require '../src/Parser'
require '../src/Parser.Matchers'

(vows.describe 'Parser: Simple Matchers')
    .addBatch
        'Parser.Exactly':
            topic: ->
                new Parser.Exactly '_this_text_'

            'Succeeds on the right text': (topic) ->
                result = topic.parse '_this_text_rest'
                assert.ok result.didSucceed
                
                continuation = result.value
                assert.equal continuation.value, '_this_text_'
                assert.equal continuation.source, 'rest'

            'Fails on other text': (topic) ->
                result = topic.parse 'anything_else'
                assert.ok not result.didSucceed

                {message} = result
                assert.equal message.source, 'anything_else'
                assert.equal message.text, "Source didn't match: '_this_text_'"

        'Parser.from String':
            topic: ->
                Parser.from 'foo'

            'Creates a Parser.Exactly': (topic) ->
                assert.deepEqual (new Parser.Exactly 'foo'), topic

        'Parser.RegExp':
            topic: ->
                new Parser.RegExp /f[o]+/

            'Matches at the front': (topic) ->
                result = topic.parse 'fooobar'
                assert.ok result.didSucceed

                continuation = result.value
                assert.equal 'fooo', continuation.value
                assert.equal 'bar', continuation.source

            'Doesn\'t match in the middle': (topic) ->
                result = topic.parse '!fooobar'
                assert.ok not result.didSucceed

                {message} = result
                assert.equal message.source, '!fooobar'
                assert.equal message.text, "Source didn't match: /^f[o]+/"

            'Doesn\'t match other strings': (topic) ->
                result = topic.parse 'other_string'
                assert.ok not result.didSucceed

        'Parser.from RegExp':
            topic: ->
                Parser.from /foo/

            'Creates a Parser.RegExp': (topic) ->
                assert.deepEqual (new Parser.RegExp /foo/), topic

    .export module
