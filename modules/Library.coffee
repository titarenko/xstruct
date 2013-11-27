Document = require './Document'
async = require 'async'
S = require "string"
$ = require "cheerio"

module.exports =

	# async
	
	download: (dataType, url, done) ->
		document = new Document url
		document.fetch (error) ->
			switch dataType
				when "json"
					done error, JSON.parse document.body
				when "html"
					done error, document.root
	
	process: (array, mapper, args, done) ->
		if not done
			done = args
			args = null
		if args
			args.unshift @
			mapper = Function::bind.apply mapper, args
		if array.html
			array = array.map (index, element) -> $ element 
		async.map array, mapper, done
	
	extract: (columns, source, done) ->
		try
			result = []
			for name, func of columns
				result[name] = func source
			done null, result	
		catch e
			done e
	
	range: (from, to, step, done) ->
		try
			result = []
			i = from
			while i < to
				result.push i
				i += step
			done null, result
		catch e
			done e
	
	flatten: (array, done) ->
		try
			result = []
			for subarray in array
				for item in subarray
					result.push item
			done null, result
		catch e
			done e
	
	concatenate: (left, right, done) ->
		try
			done null, "" + left + right
		catch e
			done e

	select: (css, html, done) ->
		done null, html(css)

	# sync

	parseDate: (date, format) ->
		moment(date, format)._d

	indexer: (array, index) ->
		array[index]

	formatDate: (date, format) ->
		moment(date).format format

	parseInteger: (integer) ->
		parseInt integer, 10

	getText: (node) ->
		node.text()

	getAttribute: (node, name) ->
		node.attr name

	trim: (string) ->
		S(string).trim().toString()

	addPrefix: (string, prefix) ->
		prefix + string

	replace: (string, what, replacement) ->
		string.replace what, replacement

	regexSelect: (string, regex) ->
		string.match(regex)[1]

	cssSelect: (node, css) ->
		node(css)
