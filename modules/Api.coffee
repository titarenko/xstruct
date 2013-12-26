Q = require "q"
request = require "request"
cheerio = require "cheerio"
async = require "async"
events = require "events"
HtmlProcessor = require "./HtmlProcessor"

module.exports = class Api

	@concurrency: 100

	constructor: (@root) ->
		@_emitter = new events.EventEmitter
		@_done = []
		@_total = []
	
	json: (uri) ->
		@_download "json", uri

	html: (uri) ->
		@_promise = @_download("html", uri)._promise.then (root) =>
			Q(new HtmlProcessor root, @_emitter.emit.bind @_emitter, "log")
		@

	then: (func) ->
		@_promise = @_promise.then func.bind @
		@

	map: (func) ->
		mapper = (item, done) ->
			func.bind(@)(item)
				._promise
				.then((value) -> done null, value)
				.catch((error) -> done error)
		@_promise = @_promise.then (value) =>
			Api._Map(value, Api.concurrency, mapper.bind @).then Q.all
		@

	flatten: ->
		@_promise = @_promise.then (value) ->
			array = []
			for i in value
				for j in i
					array.push j
			Q(array)
		@

	start: (marker) ->
		marker = "default" unless marker
		@_promise = @_promise.then (value) =>
			@_total[marker] = value.length
			value
		@

	advance: (marker) ->
		marker = "default" unless marker
		@_done[marker] = if @_done[marker]? then @_done[marker] + 1 else 1
		@_emitter.emit "progress", 
			marker: marker
			fraction: @_done[marker]/@_total[marker] 
			total: @_total[marker]
			done: @_done[marker]
		@

	on: (eventName, handler) ->
		@_emitter.on eventName, handler
		@

	done: ->
		@_promise.then @_emitter.emit.bind @_emitter, "finished"
		@_promise.catch @_emitter.emit.bind @_emitter, "error"
		@

	promise: ->
		@_promise

	_download: (type, uri) ->
		uri = @_getFullUrl uri
		@_promise = Api._Download type, uri
		@		 

	@_Download: Q.denodeify (type, uri, done) ->
		dataTypeHandlerMap =
			json: (body) -> JSON.parse body
			html: (body) -> cheerio.load body
		knownDataTypes = (dataType for dataType, handler of dataTypeHandlerMap).join(', ')
		request uri, (error, response, body) ->
			return done error if error
			return done new Error "Bad response code: #{response.statusCode}." if response.statusCode isnt 200
			handler = dataTypeHandlerMap[type]
			return done new Error "Can't handle unknown data type: #{type}. Known ones are: #{knownDataTypes}" if not handler
			done null, dataTypeHandlerMap[type] body

	@_Map: Q.denodeify async.mapLimit

	_getFullUrl: (uri) ->
		if uri[0] is '.'
			@last = @last + uri.substring(1)
		else
			@last = @root + uri
