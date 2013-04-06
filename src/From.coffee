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
        type = typeString obj
        if obj instanceof Klass
            obj
        else if (typeof converters[type] is 'function')
            instance = converters[type](obj)
            unless instance instanceof Klass
                throw new TypeError "converted value is not a instance of #{Klass}"

            instance
        else
            throw new TypeError "No converter from #{type} is defined"