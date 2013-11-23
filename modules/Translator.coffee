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

class ExtractionOperation
	constructor: (expression) ->
		@func = expression.func
		@args = expression.args
		@args.unshift "$"
	getCode: ->
		code = new Code
		code.push "$ = #{@func} #{@args.join(", ")}"
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
		code.push "#{@name} = (#{@args.join(", ")}) ->"
		code.indent()
		for operation in @body
			for line in operation.getCode().toLineArray()
				code.push line
			code.indent() if operation instanceof Call
			code.push ""
		code

class Call
	constructor: (expression) ->
		@result = expression.result
		@func = expression.func
		@args = expression.args
		@args.push "(error, #{@result})"
	getCode: ->
		code = new Code
		code.push "#{@func} #{@args.join(", ")} ->"
		code.indent()
		code.push "return done error if error"
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
