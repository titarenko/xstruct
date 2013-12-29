Q = require "q"
request = require "request"
Guard = require "./Guard"

module.exports =
	
	each: (array, func, concurrency) ->
		Guard.mustBeArray array
		Guard.mustBeFunction func
		Guard.mustBePositive concurrency
		deferred = Q.defer()
		started = 0
		running = 0
		completed = 0
		replenish = ->
			while running < concurrency and started < array.length
				running++
				func(array[started++]).catch((error) -> 
					deferred.reject error
				).done(->
					completed++
					running--
					replenish()
				)
			if completed == array.length
				deferred.resolve()
		replenish()
		deferred.promise

	download: (url) ->
		Guard.mustExist url, "URL"
		deferred = Q.defer()
		request url, (error, response, body) ->
			if error
				deferred.reject error
			else if response.statusCode isnt 200
				deferred.reject new Error "Bad response code: #{response.statusCode}."
			else
				deferred.resolve body
		deferred.promise

	# delayed: (delay, func) ->
	# 	Guard.mustBePositive delay
	# 	Guard.mustBeFunction func
	# 	(->
	# 		lastCallAt = null
	# 		->
	# 			args = Array::slice.call arguments
	# 			thisCallAt = new Date
	# 			if not lastCallAt or thisCallAt - lastCallAt > delay
	# 				lastCallAt = thisCallAt 
	# 				func.apply args
	# 	)()
