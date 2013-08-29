$ = require 'cheerio'

###
Extracts structured data from HTML document.
###
module.exports = class Extractor

	@_nodeSelector = (selector, node) -> node.find selector

	@_valueSelectors =
		attribute: (attributeName, node) -> node.attr attributeName
		text: (node) -> node.text()
		html: (node) -> node.html() 

	###
	Constructs extractor for given set of properties (name: query).
	###
	constructor: (properties) ->
		@selectors = {}
		for name, selectorObject of properties
			for nodeSelector, valueSelectorDefinition of selectorObject
				@selectors[name] =
					node: Extractor._nodeSelector.bind @, nodeSelector
					value: @_getValueSelector valueSelectorDefinition

	###
	Extracts structured object from given node.
	###
	extract: (node) ->
		result = {}
		for name, selector of @selectors
			result[name] = selector.value $ selector.node $ node
		result

	_getValueSelector: (definition) ->
		if definition.indexOf("@") == 0
			Extractor._valueSelectors.attribute.bind @, definition.substring(1)
		else if definition == "text"
			Extractor._valueSelectors.text
		else if definition == "html"
			Extractor._valueSelectors.html
		else
			throw new Error "Extractor knows nothing about following value selector: #{definition}."
