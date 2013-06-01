Document = require './Document'
Extractor = require './Extractor'
Converter = require './Converter'

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
		scope = document.root.find @scope
		items = scope.find @items
		extractor = new Extractor @properties
		done null, items.map (item) ->
			extractor.extract item

	_convert: (items, done) ->
		converter = new Converter @
		done null, items.map (item) ->
			converter.convert item
