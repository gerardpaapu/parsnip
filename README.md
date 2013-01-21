Parser - Monad parsing combinators for javascript
-------------------------------------------------

This library is intended to make it easy to write correct 
parsers for the javascript platform, by composing simple and
correct parsers into larger parsers.

Install vows to run the tests:

    > vows --spec spec/*


Example JSON Parser
-------------------

There's a complete JSON parser defined in `json/` require `'./json/Json'` to 
get it. The module provides the function `parseJSON` and an instance of 
`Parser` called `JSONParser`.

`parseJSON` takes a single string parameter and will either return a javascript 
value, or throw a `SyntaxError`.

Run the JSON tests with vows:

    > vows --spec json/spec/*


Documentation
-------------

There will be some soon. The source is commented and the tests describe the 
intent of most methods.
