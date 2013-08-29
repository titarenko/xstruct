moment = require 'moment'

###
Converts raw (string) value to typed one.
###
module.exports = class Converter

	###
	Dictionary of functions-converters (name: function).
	###
	@_converters =
		moment: (format, value) -> 
			if typeof format isnt "string"
				moment.lang format.lang
				format = format.format
			moment.utc(value, format)._d

	###
	Constructs converter for object with given properties.
	###
	constructor: (properties) ->
		@_properties = {}
		for name, converter of properties
			@_properties[name] = @_getConverter converter

	###
	Converts item's properties according to converter configuration passed to ctor.
	###
	convert: (item) ->
		for name, converter of @_properties
			item[name] = converter item[name]
		item

	_getConverter: (definition) ->
		for name, parameters of definition
			converter = Converter._converters[name]
			if not converter
				throw new Error "Converter knows nothing about following method: #{name}." 
			return converter.bind @, parameters
