Q = require "q"
HtmlProcessor = require "./HtmlProcessor"
Util = require "./Util"
Guard = require "./Guard"

module.exports = class Pipeline

	constructor: (@rootUrl) ->
		Guard.mustExist @rootUrl, "Root URL"
		@_log = ->
		@_progress = ->
		@_done = {}
		@_total = {}
		@_concurrency = 1000
		@_marker = "default"
		@_promise = Q @rootUrl

	concurrency: (value) ->
		Guard.mustBePositive value
		@_concurrency = value
		@

	marker: (marker) ->
		Guard.mustExist marker, "Marker"
		@_promise = @_promise.then (value) =>
			@_marker = marker
			value
		@

	log: (log) ->
		Guard.mustBeFunction log
		@_log = log
		@

	progress: (delay, progress) ->
		if progress
			Guard.mustBePositive delay
		else
			progress = delay
			delay = 1000
		Guard.mustBeFunction progress
		@_progress = progress # Util.delayed delay, progress
		@

	json: (url) ->
		@_promise = @_promise
			.then((result) => Util.download @_getFullUrl url or result)
			.then((body) -> JSON.parse body)
		@

	html: (url) ->
		@_promise = @_promise
			.then((result) => Util.download @_getFullUrl url or result)
			.then((body) => new HtmlProcessor body, @_log)
		@

	then: (func) ->
		Guard.mustBeFunction func
		@_promise = @_promise.then func.bind @
		@

	map: (func) ->
		Guard.mustBeFunction func
		results = []
		context = @_getInnerContext()
		context._getFullUrl = @_getFullUrl.bind @
		mapper = =>
			args = Array::slice.call arguments 
			result = func.apply context, args
			result = result.promise() unless Q.isPromise result
			result.then((result) =>
				results.push result
				@_advance() 
			)
		@_promise = @_promise.then((value) =>
			@_total[@_marker] = value.length 
			Util.each value, mapper, @_concurrency
		).then(-> results)
		@

	each: (func) ->
		Guard.mustBeFunction func
		context = @_getInnerContext()
		func = =>
			args = Array::slice.call arguments
			func.apply context, args
			@_advance()
			Q()
		@_promise = @_promise.then (value) => 
			@_total[@_marker] = value.length
			Util.each value, func, @_concurrency
		@

	flatten: ->
		@_promise = @_promise.then (value) -> 
			Array::concat.apply [], value
		@

	promise: ->
		@_promise

	_getFullUrl: (url) ->
		Guard.mustExist url, "URL"
		if url[0] is '.'
			@lastUrl = @lastUrl + url.substring(1)
		else
			@lastUrl = @rootUrl + url

	_getInnerContext: ->
		context = new Pipeline @rootUrl
		context._getFullUrl = @_getFullUrl.bind @
		context

	_advance: ->
		@_done[@_marker] = if @_done[@_marker]? then @_done[@_marker] + 1 else 1
		@_progress
			marker: @_marker
			fraction: @_done[@_marker]/@_total[@_marker] 
			total: @_total[@_marker]
			done: @_done[@_marker]
