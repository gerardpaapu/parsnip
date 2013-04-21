###
Tests that the Monad laws hold using parser values
and the static methods chain, of, and zero.
###
vows = require 'vows'
assert = require 'assert'
{Result, Success, Failure} = require '../src/Parser'
{of: $of, chain} = Result
fail = Result.failWithMessage

# reverse: (str:String) -> Result<String>
reverse = (str) ->
    chars = str.split ''
    reversed = do chars.reverse
    $of reversed.join ''

# capitalize: (str:String) -> Result<String>
capitalize = (str) ->
    first = do (str.charAt 0).toUpperCase
    rest = str.slice 1

    $of first + rest

(vows.describe 'Result monad operations')
    .addBatch
        'Left identity: (return a) >>= f is f a':
            topic: ->
                left  = chain ($of 'foo'), reverse
                right = reverse 'foo'
                [left, right]

            'Are equal': ([left, right]) ->
                assert.deepEqual left, right

            'Are a success': ([left, right]) ->
                assert.ok left.didSucceed
                assert.ok right.didSucceed

        'Right identity (failure): m >>= return is m':
            topic: -> 
                chain (fail 'oops'), $of

            'is failure': (t) ->
                assert.ok not t.didSucceed

            'with the correct message': (t) ->
                assert.equal t.message, 'oops'

        'Right identity (success): m >>= return is m':
            topic: -> 
                chain ($of 'okay'), $of

            'is success': (t) ->
                assert.ok t.didSucceed

            'with the correct value': (t) ->
                assert.ok t.value is 'okay'

        'Associativity (success): (m >>= f) >>= g is m >>= (\\x -> f x >>= g)':
            topic: ->
                m = new Success 'okay'
                a = chain (chain m, reverse), capitalize
                b = chain m, ((x) -> chain (reverse x), capitalize)
                [a, b]

            'left and right are a success': ([left, right]) ->
                assert.ok left.didSucceed
                assert.ok right.didSucceed

            'left == right': ([left, right]) ->
                assert.deepEqual left, right

        'Associativity (failure): (m >>= f) >>= g is m >>= (\\x -> f x >>= g)':
            topic: ->
                m = new Failure 'okay'
                a = chain (chain m, reverse), capitalize
                b = chain m, ((x) -> chain (reverse x), capitalize)
                [a, b]

            'left and right are not a success': ([left, right]) ->
                assert.ok not left.didSucceed
                assert.ok not right.didSucceed

            'left == right': ([left, right]) ->
                assert.deepEqual left, right

    .export module