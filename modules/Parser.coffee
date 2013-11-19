parser = require "./parser"
S = require "string"

module.exports = class Parser

	parse: (code, done) ->
		code = S(code.toString())
			.lines()
			.map((line) -> S(line).trim().toString())
			.filter((line) -> line)
		code = code.join("\n")
		tree = null
		try
			tree = parser.parse code
		catch e
			done e
		done null, tree
