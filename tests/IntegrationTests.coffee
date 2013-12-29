should = require "should"
replay = require "replay"
xstruct = require "../index"

isLogEnabled = false

replay.mode = "record"
replay.fixtures = "#{__dirname}/../../tests/cache"

if isLogEnabled
	winston = require "winston"
	winston.remove winston.transports.Console
	winston.add winston.transports.Console, colorize: true

describe "API", ->

	it "should allow to do query for auto.ria.com data", (done) ->
		brand = 5
		model = 0
		xstruct("http://auto.ria.com")
			.progress((info) -> 
				should.exist info
				info.should.be.ok
				winston.info info.marker, info if isLogEnabled
			)
			.log((info) ->
				should.exist info
				info.should.be.ok
				winston.info meta.func, meta if isLogEnabled
			)
			.json("/blocks_search_ajax/search/?marka=#{brand}&model=#{model}")
			.then((json) -> x for x in [0..json.result.search_result.count] by 1000)
			.marker("id")
			.map((page) ->
				@json(".&page=#{page}&countpage=1000")
				.then((json) -> json.result.search_result.ids)
			)
			.flatten()
			.marker("ad")
			.map((id) ->
				@html("/blocks_search/view/auto/#{id}")
				.then((html) ->
					link: @rootUrl + html.get (el) -> 
						el
							.css("h3.head-car a")
							.attr("href")
					year: html.get (el) -> 
						el
							.css("h3.head-car a")
							.attr("title")
							.regex(/(\d{4})$/)
							.float()
					mileage: html.get (el) -> 
						el
							.css(".characteristic .item-char")
							.at(1)
							.text()
							.trim()
							.regex(/^(\d+)/)
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
			.each((ad) ->
				should.exist ad
				ad.should.be.ok
				winston.info ad if isLogEnabled
			)
			.promise()
			.catch((error) -> done error)			
			.done(-> done())

	it "should allow to do query for dou.ua forum data", (done) ->

		xstruct("http://dou.ua")
			.progress((info) -> 
				should.exist info
				info.should.be.ok
				winston.info info.marker, info if isLogEnabled
			)
			.log((info) ->
				should.exist info
				info.should.be.ok
				winston.info info.func, info if isLogEnabled
			)
			.html("/forums/topic/8751")
			.then((html) -> 
				html.get (el) -> 
					el.css(".b-comment").map (el) ->
						author: el.get (child) -> child.css(".avatar").text().trim()
						time: el.get (child) -> child.css(".date").text().trim()
						text: el.get (child) -> child.css(".text p").text()
			)
			.promise()
			.catch((error) -> done error)
			.done((data) ->
				should.exist data
				data.should.be.ok
				winston.info data if isLogEnabled
				done()
			)
