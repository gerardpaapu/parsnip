{Parser} = require '../../src/Parser'
require '../../src/Parser.Matchers'
require '../../src/Combinators'
{Or} = Parser

stringParser = do ->
    quote = '"'
    backslash = '\\'

    characterParser = ->
        Or escaped(), unescaped()

    isControl = (c) ->
        pattern = ///
            [ \u0000 \u00ad \u0600-\u0604 \u070f \u17b4 \u17b5
              \u200c-\u200f \u2028-\u202f \u2060-\u206f \ufeff
              \ufff0-\uffff ]
            ///
        c.match pattern

    unescaped = ->
        new Parser.Item().isnt (x) ->
            x is quote or
            x is backslash or
            isControl x

    escapeTable =
        '"': '"'
        '\'': '\''
        '\\': '\\'
        '/': '/'
        'b': '\b'
        'f': '\f'
        'n': '\n'
        'r': '\r'
        't': '\t'

    unicodeSeq = ->
        (Parser.from ['\\u', /^[a-f0-9]{4}/i])
            # discard the '\u'
            .convert (x) ->
                x[1]

            .convert (code) ->
                String.fromCharCode (parseInt code, 16)

    simpleEscape = ->
        (Parser.from ['\\', new Parser.Item() ])
            # discard the leading slash
            .bind ([_, code]) ->
                v = escapeTable[code]
                if v?
                    new Parser.Succeed v
                else
                    new Parser.Fail "Illegal escape code #{v}"

    escaped = ->
        Or unicodeSeq(), simpleEscape()

    characterParser()
        .zeroOrMore()
        .surroundedBy(quote, quote)
        .convert (arr) ->
            arr.join ''

exports.stringParser = stringParser