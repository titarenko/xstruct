nock = require 'nock'
Document = require '../models/Document'

describe "Document", ->

	describe "#fetch()", ->

		it "should return error if request has been failed", (done) ->

			nock("http://resource.com")
				.get("/")
				.reply(404)

			document = new Document "http://resource.com/"

			document.fetch (error) ->
				error.should.eql 404
				done()
