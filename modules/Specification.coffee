$ = require 'string'

split = (line, separator) ->
	line
		.split(separator)
		.map((x) -> $(x).trim().s)
		.filter((x) -> x.length)

getLevel = (line) ->
	tabs = text.match /^(\t+)/
	spaces = text.match /^( +)/
	if tabs and spaces
		throw new Error "Wrong indentation: tabs and spaces are mixed."
	indentation = tabs or spaces or ""
	return indentation.length

getTask = (line) ->
	tokens = split line, " "
	if tokens.length < 1
		throw new Error "Task definition should contain at least operation name."
	op: tokens[0]
	args: tokens.slice(1)
	children: []

getTaskChain = (line) ->
	split(line, "|").map(getTask)

chainToHierarchy: (chain) ->
	parent = chain[0]
	for task in chain.slice(1)
		parent.children.push task
		parent = task
	return chain[0]

parseSpecification: (text) ->
	grandParent = null
	for line in $(text).lines() when line.length
		level = getLevel line
		task = chainToHierarchy getTaskChain line
		if grandParent is null
			grandParent = task
	return grandParent

module.exports = class Specification

	@parse: parseSpecification