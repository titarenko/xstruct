util = require "util"

module.exports = 

	mustExist: (anything, name) ->
		if not anything
			throw new Error "#{name or 'Value'} must be specified."

	mustBeFunction: (anything) ->
		if not anything or typeof anything isnt "function"
			throw new Error "Function must be specified."

	mustBePositive: (anything) ->
		if anything < 1
			throw new Error "Positive number must be specified."

	mustBeArray: (anything) ->
		if not util.isArray anything
			throw new Error "Array must be specified."
