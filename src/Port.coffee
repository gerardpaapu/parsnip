class Port
	# A wrapper for a string, to support multiple readers
	# navigating over a single string and human readable
	# source location information
	constructor: (@source, @_index=0) ->

	@from: (str) ->
		if str instanceof Port
			str
		else
			new Port(str)

	take: (n) ->
		@slice(0, n)

	drop: (n) ->
		@move(n)

	isEmpty: ->
		@source.length <= @_index

	move: (n) ->
		new Port(@source, @_index + n)

	index: (n) ->
		if n < 0 then n else @_index + n

	slice: (a, b) ->
		switch arguments.length
			when 0 then @source.slice @index(0)
			when 1 then @source.slice @index(a)
			else @source.slice @index(a), @index(b)

	location: ->
		row = 0
		column = 0

		while i < @_index
			if @source[i++] is '\n'
				column = 0
				row++
			else
				column++

		new Location(row, column)

	toString: -> @slice(0)

exports.Port = Port

class Location
	constructor: (@row, @column) ->

exports.Location = Location