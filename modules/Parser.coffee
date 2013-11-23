parser = require "./parser"
S = require "string"

module.exports = class Parser

	parse: (code) ->
		code = S(code.toString())
			.lines()
			.map((line) -> S(line).trim().toString())
			.filter((line) -> line)
		code = code.join("\n")
		try
			tree = parser.parse code
		catch e
			tree = null
		tree
