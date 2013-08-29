request = require "request"
cheerio = require "cheerio"
iconv = require "iconv"

###
Represents HTML document.
###
module.exports = class Document
	
	###
	Constructs instance using given URI.
	###
	constructor: (@uri) ->

	###
	Fetches document.
	###
	fetch: (done) ->
		request {uri: @uri, encoding: "binary"}, (error, response, body) =>
			return done(error or response.statusCode) if error or response.statusCode is not 200
			@body = body
			@_decode()
			@_extractTitle()
			@_initializeRoot()
			done null

	_decode: ->
		buffer = new Buffer(@body, "binary")
		encoding = buffer.toString().match /text.html;\s*charset=([\d\w\-]+)/
		buffer = (new iconv.Iconv encoding[1], "utf8").convert(buffer) if encoding
		@body = buffer.toString()

	_extractTitle: ->
		match = @body.match /<title>([\S\s]+)<\/title>/
		@title = if match then match[1] else @uri

	_initializeRoot: ->
		@root = cheerio.load(@body) "body"
