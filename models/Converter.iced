moment = require 'moment'

module.exports = class Converter

	@_converters =
		moment: (format, value) -> moment(value, format)._d

	constructor: (properties) ->
		@_properties = {}
		for name, converter of properties
			@_properties[name] = @_getConverter converter

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
