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
	toString: ->
		"#{@name} = #{@value}"

class ExtractionOperation
	constructor: (expression) ->
		@func = expression.func
		@args = expression.args
		@args.unshift "$"
	toString: ->
		"$ = #{@func} #{@args.join(", ")}"

class Extractor
	constructor: (expression) ->
		@name = expression.name
		@operations = expression.operations.map Expression.construct
	toString: ->
		code = new Code
		code.push "#{@name}Extractor = ($) ->"
		code.indent()
		for operation in @operations
			code.push operation.toString()
		code.toString()

class Block
	constructor: (expression) ->
		@name = expression.name
		@args = expression.args
		@args.push "done"
		@body = expression.body.map Expression.construct
	toString: ->
		code = new Code
		code.push "#{@name} = (#{@args.join(", ")}) ->"
		code.indent()
		for operation in @body
			# for line in operation.toLineArray()
			# 	code.push line
			code.push operation.toString()
			code.indent()
		code.toString()

class Call
	constructor: (expression) ->
		@result = expression.result
		@func = expression.func
		@args = expression.args
		@args.push "(error, #{@result})"
	toString: ->
		code = new Code
		code.push "#{@func} #{@args.join(", ")} ->"
		code.indent()
		code.push "return done error if error"
		code.toString()

class Return
	constructor: (expression) ->
		@result = expression.result
	toString: ->
		"done null, #{@result}"

class CoffeeGenerator
	generate: (syntaxTree) ->
		code = new Code
		code.push "module.exports = (done) ->"
		code.indent()
		for node in syntaxTree
			expression = Expression.construct node
			code.push expression.toString()
		code.toString()

class Translator
	translate: (dsl) ->
		tree = new Parser().parse dsl
		coffee = new CoffeeGenerator().generate tree

module.exports = Translator
