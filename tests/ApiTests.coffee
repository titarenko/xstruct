should = require "should"
replay = require "replay"
xstruct = require "../index"

isLogEnabled = false
isLiveHttp = false

replay.mode = if isLiveHttp then "record" else "replay"
replay.fixtures = __dirname + "/../../tests/fixtures"

if isLogEnabled
	winston = require "winston"
	winston.remove winston.transports.Console
	winston.add winston.transports.Console, colorize: true

describe "API", ->

	it "should allow to do query for auto.ria.ua data", (done) ->

		brand = 5
		model = 0

		xstruct("http://auto.ria.ua")

			.json("/blocks_search_ajax/search?marka=#{brand}&model=#{model}")
		
			.then((json) -> 
				x for x in [0..json.result.search_result.count] by 1000
			)
		
			.map((page) -> 
				@json(".&page=#{page}&countpage=1000")
				.then((json) -> 
					json.result.search_result.ids
				)
			)
		
			.flatten()
		
			.start()
		
			.map((id) ->
				@html("/blocks_search/view/auto/#{id}")
				.then((html) ->
					@advance()
					link: @root + html.get (el) -> 
						el
							.css("h3.head-car a")
							.attr("href")
					year: html.get (el) -> 
						el
							.css("h3.head-car a")
							.attr("title")
							.regex(/\d{4}$/)
							.float()
					mileage: html.get (el) -> 
						el
							.css(".characteristic .item-char")
							.at(1)
							.text()
							.trim()
							.regex(/^\d+/)
							.float()
							.coalesce(0)
					location: html.get (el) -> 
						el
							.css("span.city a")
							.text()
					price: html.get (el) -> 
						el
							.css("div.price strong.green")
							.text()
							.replace(" ", "")
							.float()
					date: html.get (el) -> 
						el
							.css("span.date-add span")
							.text()
							.parse("DD.MM.YYYY")
							.format("YYYY-MM-DD")
					phone: html.get (el) -> 
						el
							.css(".phone")
							.text()
							.replace(/[() \-]/g, "")
							.coalesce(null)
				)
			)	

			.on("progress", (percentage) -> 
				should.exist percentage
				percentage.should.be.ok
			)
			
			.on("error", (error) ->
				done error
			)
			
			.on("log", (message, meta) ->
				should.exist message
				should.exist meta
				message.should.be.ok
				meta.should.be.ok
				winston.info message, meta if isLogEnabled
			)

			.on("finished", (data) ->
				should.exist data
				data.should.be.ok
				winston.info data if isLogEnabled
				done()
			)

			.done()

	it "should allow to do query for dou.ua forum data", (done) ->

		xstruct("http://dou.ua")

			.html("/forums/topic/8751")

			.then((html) -> 
				html.get (el) -> 
					el.css(".b-comment").map (el) ->
						author: el.get (child) -> child.css(".avatar").text().trim()
						time: el.get (child) -> child.css(".date").text().trim()
						text: el.get (child) -> child.css(".text p").text()
			)
			
			.on("progress", (percentage) -> 
				should.exist percentage
				percentage.should.be.ok
			)
			
			.on("error", (error) ->
				done error
			)
			
			.on("log", (message, meta) ->
				should.exist message
				should.exist meta
				message.should.be.ok
				meta.should.be.ok
				winston.info message, meta if isLogEnabled
			)

			.on("finished", (data) ->
				should.exist data
				data.should.be.ok
				winston.info "result", data if isLogEnabled
				done()
			)

			.done()
