nock = require 'nock'
should = require 'should'
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

		it "should use document URI as title if title tag was not found", (done) ->

			nock("http://titleless.com")
				.get("/")
				.reply(200, "<html></html>")

			document = new Document "http://titleless.com/"

			document.fetch (error) ->
				should.not.exist error
				document.title.should.eql "http://titleless.com/"
				done()
