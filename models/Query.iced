async = require 'async'
Document = require './Document'
Extractor = require './Extractor'
Converter = require './Converter'

module.exports = class Query

	constructor: (definition) ->
		@definition = definition

	execute: (done) ->
		async.waterfall [
			@_fetch.bind @, @definition.fetch
			@_extract.bind @, @definition.extract
			@_convert.bind @, @definition.convert
		], done

	_fetch: (fetch, done) ->
		document = new Document fetch
		document.fetch (error) ->
			done error, document

	_extract: (extract, document, done) ->
		scope = document.root.find extract.scope
		items = scope.find extract.items
		extractor = new Extractor extract.properties
		done null, items.map (index, item) ->
			extractor.extract item

	_convert: (convert, items, done) ->
		converter = new Converter convert
		done null, items.map (item, index) ->
			converter.convert item
