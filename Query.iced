request = require "request"
cheerio = require "cheerio"
iconv = require "iconv"
moment = require 'moment'

class Document
	
	constructor: (options) ->
		@uri = options.uri

	fetch: (done) ->
		await request {uri: @uri, encoding: "binary"}, defer error, response, body
		return done(error or response.statusCode) if error or response.statusCode != 200

		@body = body
		@_decode()
		@_extractTitle()
		@_prepareNavigator()

		done null

	_decode: ->
		buffer = new Buffer(@body, "binary")
		encoding = buffer.toString().match /text.html;\s*charset=([\d\w\-]+)/
		buffer = (new iconv.Iconv encoding[1], "utf8").convert(buffer) if encoding
		@body = buffer.toString()

	_extractTitle: ->
		match = @body.match /<title>([\S\s]+)<\/title>/
		@title = if match then match[1] else @uri

	_prepareNavigator: ->
		@navigator = cheerio.load @body

# {
# 	"fetch": "http://dou.ua/forums/topic/7337/",
# 	"extract": {
# 		"scope": "#commentsList",
# 		"items": "b-comment",
# 		"properties": {
# 			"date": {".comment": "@date"},
# 			"name": {".g-avatar": "@title"},
# 			"text": {".l-text": "text"}
# 		}
# 	},
# 	"convert": {
# 		"date": {"moment": "YYYY/MM/DD hh:mm:ss"}
# 	}
# }

class Extractor

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
			throw new Error "Unknown value selector."

class Converter

	constructor: (properties) ->

	convert: (item) ->
		item

module.exports = class Query

	constructor: (@definition) ->

	execute: (done) ->
		async.waterfall [
			@_fetch.bind @definition.fetch
			@_extract.bind @definition.extract
			@_convert.bind @definition.convert
		], done

	_fetch: (done) ->
		document = new Document url: @
		document.fetch (error) -> 
			done error, document

	_extract: (document, done) ->
		scope = document.navigator.find @scope
		items = scope.find @items
		extractor = new Extractor @properties
		done null, items.map (item) ->
			extractor.extract item

	_convert: (items, done) ->
		converter = new Converter @
		done null, items.map (item) ->
			converter.convert item
