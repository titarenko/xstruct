# std functions here

module.exports = (options, done) ->
	
	done = done or options

	brand = options.brand
	model = options.model

	catalog_url = "http://auto.ria.ua/blocks_search_ajax/search?marka=<%= brand %>&model=<%= model %>"
	
	get_ads (error, result) ->
		return done error if error
		
		done null, result

	get_ads = (done) ->

		download "json", catalog_url, (error, data) ->
			return done error if error

			range 0, data.result.search_result.count, 1000, (error, pages) ->
				return done error if error
				
				async.map pages, get_ids, (error, chunked_ids) ->
					return done error if error
					
					flatten chunked_ids, (error, ids) ->
						return done error if error
						
						async.map ids, get_ad, (error, ads) ->
							return done error if error
							
							done null, ads

	get_ids = (page, done) ->

		concatenate catalog_url, "&page=<%= page %>", (error, page_url) ->
			return done error if error

			download "json", page_url, (error, data) ->
				return done error if error
				
				done null, data.result.search_result.ids

	get_ad = (id, done) ->

		ad_url = "http://auto.ria.ua/blocks_search/view/auto/<%= id %>"

		data = download "html", catalog_url, (error, ad_html) ->
			return done error if error

			extract extractors, ["link", "year", "mileage", "location", "price", "date", "phone"], ad_html, (error, ad) ->
				return done error if error

				done null, ad

	extractors =
		link: ($) -> 
			try
				r1 = $("h3.head-car h1")
				r2 = r1.attr("href")
				r3 = "http://auto.ria.ua" + r2
			catch e
				null
