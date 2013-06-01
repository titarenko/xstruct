module.exports = class Extractor

	@_valueSelectors =
		attribute: (attributeName, node) -> node.attr attributeName
		text: (node) -> node.text()
		html: (node) -> node.html() 

	constructor: (properties) ->
		@selectors = {}
		for name, selectorObject of properties
			for nodeSelector, valueSelectorDefinition of selectorObject
				@selectors[name] =
					node: nodeSelector
					value: @_getValueSelector valueSelectorDefinition

	extract: (node) ->
		result = {}
		for name, selector of @selectors
			result[name] = selector.value selector.node node
		result

	_getValueSelector: (definition) ->
		if definition.indexOf("@") == 0
			@_valueSelectors.attribute.bind @, definition.substring(1)
		else if definition == "text"
			@_valueSelectors.text
		else if definition == "html"
			@_valueSelectors.html
		else
			throw new Error "Extractor knows nothing about following value selector: #{definition}."
