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

        
    .export module
