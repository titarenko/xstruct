class Visitable
	constructor: (@className) ->
	accept: (visitor) ->
		visitor["visit#{@className}"] @

class NullReferenceError extends Error

	constructor: (variableName) ->
		super("Unexpected null '#{variableName}'.")

class VisitorMethodNotFoundError extends Error

	constructor: (instance) ->
		super("Can't visit #{instance.toString()}.")

###
Visitor implementation.
###
class Visitor
	constructor: (@methodResolutionPolicy) ->
	visit: (instance) ->
		if not instance
			throw new NullReferenceError "instance"
		methodName = @methodResolutionPolicy instance
		if not @[methodName]
			throw new VisitorMethodNotFoundError instance
		@[methodName] instance

###
Abstract syntax tree visitor.
###
class AstVisitor extends Visitor
	
	constructor: ->
		super((node) -> "_#{node.name}")
	
	buildScope: (tree, parent) ->
		@scope = new Scope parent
		for node in tree
			@visit node
		@scope
	
	_step: (node) ->
		visitor = new CommandTreeVisitor
		@scope.addStep node.name, visitor.buildScope node.body, @scope

	_assign: (node) ->
		if node.source.constant
			@scope.addConstant, node.destination, node.source.constant
		else
			@scope.addOperation node.destination, new Operation node.source

	_yield: (node) ->
		@scope.setResult node.result

	_extractor: (node) ->
		@scope.addExtractor node.name, new Extractor node.operations

###
Dictionary, which values can be overwritten by using same key.
###
class OverwritableDictionary

	constructor: ->
		@storage = []

	add: (key, value) ->
		if not key
			throw new NullReferenceError "key"
		if not value 
			throw new NullReferenceError "value"
		@storage[key] = value

	asArray: ->
		@storage

###
Execution scope.
###
class Scope
	
	constructor: (@parent) ->
		@steps = new OverwritableDictionary
		@constants = new OverwritableDictionary
		@operations = new OverwritableDictionary
		@extractors = new OverwritableDictionary
		@result = null

	addExtractor: (name, instance) ->
		@extractors.add name, instance

	addConstant: (name, instance) ->
		@constants.add name, instance

	addOperation: (name, instance) ->
		@operations.add name, instance

	addStep: (name, instance) ->
		@steps.add name, instance

	setResult: (name) ->
		if not name
			throw new NullReferenceError "name"
		@result = name

	resolve: (names) ->
		names = [names] unless names instanceof Array
		if names.length is 1
			stage = @stages[name]
			@sequence.push stage
		else
			stages = @stages[name] for name in names
			@sequence.push new ParallelStage 
		
		@sequence

		if @constants[name]


		@sequence.push operation
		operation.dependencies

	evaluate: ->
		if @constants[@result]
			new Return @constants[@result]
		else
			@sequence = new Sequence
			@resolve @operations[@result]
			@sequence

class ScopeWithoutResultError extends Error

	constructor: ->
		super("Given scope doesn't have a result.")

class CoffeeStepGenerator
	generate: (step) ->

class Code
	constructor: ->
		@indentation = ""
		@markedIndentations = []
		@lines = []
	push: (line) ->
		@lines.push @indentation + line
	indent: (marker) ->
		@markedIndentations[marker] = @indentation if marker
		@indentation += "\t"
	unindent: ->
		@indentation = @indentation.substring(1)
	restoreIndentation: (marker) ->
		@indentation = @markedIndentations[marker]
	toString: ->
		@lines.join "\n"

class Constant
	constructor: (@command) ->
	toString: ->


class Extractor
class Step
class Call
class Return

class CoffeeGenerator



	generate: (scope) ->
		code = new Code
		for name, step of scope.steps
			args = step.args
			args.push "done"
			code.push "#{name} = (#{step.args.join(", ")}) ->"
			code.indent(name)
			code.push "return done error if error"
			code.push ""
			for command in step.body
				if command.command is "assign"
					if command.source.constant
						code.push "#{command.destination} = #{command.source.constant}"
					else if command.source.command
						args = command.source.args
						args.push "(error, #{command.destination})"
						code.push "#{command.source.command} #{args.join(", ")} ->"
						code.indent()
						code.push "return done if error"
						code.push ""
				else if command.command is "yield"
					code.push "done null, #{command.result}"
					code.restoreIndentation name
		for extra

class Constant

	constructor: (@scope, @value) ->
		@dependencies = []

	resolve: ->
		@value

class Download

	constructor: (@url, @dataType, @scope) ->

###
Entry point.
###
class Translator
	translate: (code, done) ->
		tree = new Parser().parse code
		scope = new ScopeBuilder().build tree
		coffee = new CoffeeGenerator().generate scope
		done null, coffee
			
module.exports = Translator
