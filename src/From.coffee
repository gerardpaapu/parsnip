typeString = (obj) ->
    if obj?
        full = Object::toString.call obj
        full.slice 8, -1
    else
        String obj

###
Adds the static methods `from` and `addConverter` to the
class to provide ways to easily coerce other javascript
values into that class
###
exports.addMethods = (Klass) ->
    converters = {}

    Klass.addConverter = (type, fn) ->
        if converters[type]?
            throw new Error "#{type} is already defined"

        converters[type] = fn

    Klass.from = (obj) ->
        instance = converters[typeString obj](obj)
        unless instance instanceof Klass
            throw new TypeError "converted value is not a instance of #{Klass}"

        instance
