vows = require 'vows'
assert = require 'assert'

numberParser = (require '../src/Number').numberParser
{Message, Continuation} = require './lib/Parser'

(vows.describe 'Parsing Numbers')
    .addBatch
        'When Parsing a simple integer':
            topic: ->
                numberParser.parse '8989923 rest'

            'Succeeds': (t) ->
                assert.ok t.didSucceed
                cont = t.value

                assert.equal cont.value, 8989923
                assert.equal cont.source, ' rest'

        'When Parsing a float':
            topic: ->
                numberParser.parse '4.89763 rest'

            'Succeeds': (t) ->
                assert.ok t.didSucceed
                cont = t.value

                assert.equal cont.value, +'4.89763'
                assert.equal cont.source, ' rest'

        'When Parsing a float with Exponent':
            topic: -> 
                numberParser.parse '4.2e100 rest'

            'Succeeds': (t) ->
                assert.ok t.didSucceed
                cont = t.value

                assert.equal cont.value, +'4.2e100'
                assert.equal cont.source, ' rest'


        'When parsing a non-number':
            topic: ->
                numberParser.parse 'not a number'

            'Fails': (t) ->
                assert.ok not t.didSucceed

    .export module
