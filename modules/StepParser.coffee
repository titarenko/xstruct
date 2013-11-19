parser = require "./StepParserPeg"

module.exports = class StepParser

	parse: (code, done) ->
		try
			done null, parser.parse code
		catch error
			done error
