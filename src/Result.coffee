class Result
    @succeedWithValue: (value) ->
        new Success value

    @failWithMessage: (message) ->
        new Failure message

    @bind: (m, f) ->
        m.bind f

    @mzero: -> 
        Result.failWithMessage 'failed'

    @mreturn: (value) ->
        Result.succeedWithValue value

class Success extends Result
    constructor: (@value) ->
    didSucceed: true
    bind: (fn) -> fn @value

class Failure extends Result
    constructor: (@message) ->
    didSucceed: false
    bind: (_) -> this

exports.Result = Result
exports.Success = Success
exports.Failure = Failure
