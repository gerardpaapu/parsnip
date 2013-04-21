class Result
    @succeedWithValue: (value) ->
        new Success value

    @failWithMessage: (message) ->
        new Failure message

    @chain: (m, f) ->
        m.chain f

    @zero: -> 
        Result.failWithMessage 'failed'

    @of: (value) ->
        Result.succeedWithValue value

    concat: (v) ->
        @lconcat (-> v)

class Success extends Result
    constructor: (@value) ->
    didSucceed: true
    chain: (fn) -> fn @value
    lconcat: (_) -> this


class Failure extends Result
    constructor: (@message) ->
    didSucceed: false
    chain: (_) -> this
    lconcat: (f) -> f()

exports.Result = Result
exports.Success = Success
exports.Failure = Failure
