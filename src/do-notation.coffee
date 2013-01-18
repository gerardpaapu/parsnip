###
This is a clumsy way to emulate do notation in
coffeescript.

Here's an example:

    Parser::surroundedBy = (left, right) ->
        parser = this

        (Monad Parser).do(
            (_     :-> left),
            (inner :-> parser),
            (_     :-> right),
            -> @mreturn @inner)

    result = (Parser.from 'foo')
        .surroundedBy '(', ')'
        .parse '(foo)rest'

    result.didSucceed is true
    result.value.value is 'foo'
    result.value.source is 'rest'
###
Monad = (Type) ->
    do: (arr...) ->
        DO = (arr, env) ->
            if arr.length is 0
                throw new SyntaxError

            if arr.length is 1
                unless (typeof arr[0]) is 'function'
                    throw new TypeError

                arr[0].call env

            [item, rest...] = arr
            unless (typeof item) is 'object'
                throw new TypeError


            key = (Object.keys item)[0]
            block = item[key]

            Type.bind (block.call env), (value)->
                env[key] = value
                DO (arr.slice 1), env

        env =
            bind: Type.bind
            mzero: Type.mzero
            mreturn: Type.mreturn

        DO arr, env
