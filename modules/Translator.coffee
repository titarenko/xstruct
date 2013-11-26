Parser = require "./Parser"

class Code
	constructor: ->
		@indentation = ""
		@lines = []
	push: (line) ->
		@lines.push @indentation + line
	indent: ->
		@indentation += "\t"
	toString: ->
		@lines.join "\n"
	toLineArray: ->
		@lines

class Expression
	@construct: (syntaxTreeNode) ->
		switch syntaxTreeNode.type
			when "constant"
				new Constant syntaxTreeNode
			when "extractionOperation"
				new ExtractionOperation syntaxTreeNode
			when "extractor"
				new Extractor syntaxTreeNode
			when "block"
				new Block syntaxTreeNode
			when "call"
				new Call syntaxTreeNode
			when "return"
				new Return syntaxTreeNode

class Constant
	constructor: (expression) ->
		@name = expression.name
		@value = expression.value
	getCode: ->
		code = new Code
		code.push "#{@name} = #{@value}"
		code

class Arguments
	constructor: (args) ->
		@args = args.map @_mapper.bind @
	_mapper: (arg) ->
		if arg == null
			"null"
		else if arg instanceof Array
			"[#{arg.map(@_mapper.bind @).join(", ")}]"
		else
			"#{arg}"
	toString: ->
		"#{@args.join(", ")}"

class ExtractionOperation
	constructor: (expression) ->
		@func = "std.#{expression.func}"
		@args = expression.args
		@args.unshift "$"
	getCode: ->
		code = new Code
		args = new Arguments @args
		code.push "$ = #{@func} #{args.toString()}"
		code

class Extractor
	constructor: (expression) ->
		@name = expression.name
		@operations = expression.operations.map Expression.construct
	getCode: ->
		code = new Code
		code.push "#{@name}Extractor = ($) ->"
		code.indent()
		for operation in @operations
			for line in operation.getCode().toLineArray()
				code.push line
		code

class Block
	constructor: (expression) ->
		@name = expression.name
		@args = expression.args
		@args.push "done"
		@body = expression.body.map Expression.construct
	getCode: ->
		code = new Code
		args = new Arguments @args
		code.push "#{@name} = (#{args.toString()}) ->"
		code.indent()
		for operation in @body
			for line in operation.getCode().toLineArray()
				code.push line
			code.indent() if operation instanceof Call
		code

class Call
	constructor: (expression) ->
		@result = expression.result
		@func = "std.#{expression.func}"
		@args = expression.args
		@args.push "(error, #{@result})"
	getCode: ->
		code = new Code
		args = new Arguments @args
		code.push "#{@func} #{args.toString()} ->"
		code.indent()
		code.push "return done error if error"
		code.push ""
		code

class Return
	constructor: (expression) ->
		@result = expression.result
	getCode: ->
		code = new Code
		code.push "done null, #{@result}"
		code

class CoffeeGenerator
	generate: (syntaxTree) ->
		code = new Code
		code.push "std = require('xstruct').Library"
		code.push ""
		code.push "module.exports = start"
		code.push ""
		for node in syntaxTree
			expression = Expression.construct node
			for line in expression.getCode().toLineArray()
				code.push line
			code.push ""
		code.toString()

class Translator
	translate: (dsl) ->
		tree = new Parser().parse dsl
		coffee = new CoffeeGenerator().generate tree

module.exports = Translator
