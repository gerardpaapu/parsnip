vows = require 'vows'
assert = require 'assert'

{Result, Success, Failure} = require '../src/Result'
{mreturn, bind, fail} = Result

# reverse: (str:String) -> Result<String>
reverse = (str) ->
    chars = str.split ''
    reversed = do chars.reverse
    mreturn reversed.join ''

# capitalize: (str:String) -> Result<String>
capitalize = (str) ->
    first = do (str.charAt 0).toUpperCase
    rest = str.slice 1

    mreturn first + rest

(vows.describe 'Result monad operations')
    .addBatch
        'Left identity: (return a) >>= f is f a':
            topic: ->
                left  = bind (mreturn 'foo'), reverse
                right = reverse 'foo'
                [left, right]

            'Are equal': ([left, right]) ->
                assert.deepEqual left, right

            'Are a success': ([left, right]) ->
                assert.ok left.didSucceed
                assert.ok right.didSucceed

        'Right identity (failure): m >>= return is m':
            topic: -> 
                bind (fail 'oops'), mreturn

            'is failure': (t) ->
                not t.didSucceed

            'with the correct message': (t) ->
                t.message is 'oops'

        'Right identity (success): m >>= return is m':
            topic: -> 
                bind (mreturn 'okay'), mreturn

            'is success': (t) ->
                t.didSucceed

            'with the correct value': (t) ->
                t.value is 'okay'

        'Associativity (success): (m >>= f) >>= g is m >>= (\\x -> f x >>= g)':
            topic: ->
                m = new Success 'okay'
                a = bind (bind m, reverse), capitalize
                b = bind m, ((x) -> bind (reverse x), capitalize)
                [a, b]

            'left and right are a success': ([left, right]) ->
                assert.ok left.didSucceed
                assert.ok right.didSucceed

            'left == right': ([left, right]) ->
                assert.deepEqual left, right

        'Associativity (failure): (m >>= f) >>= g is m >>= (\\x -> f x >>= g)':
            topic: ->
                m = new Failure 'okay'
                a = bind (bind m, reverse), capitalize
                b = bind m, ((x) -> bind (reverse x), capitalize)
                [a, b]

            'left and right are not a success': ([left, right]) ->
                assert.ok not left.didSucceed
                assert.ok not right.didSucceed

            'left == right': ([left, right]) ->
                assert.deepEqual left, right

    .export(module)