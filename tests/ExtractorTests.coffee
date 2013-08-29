Extractor = require '../models/Extractor'
cheerio = require 'cheerio'

describe "Extractor", ->

	describe "#extract()", ->

		it "should extract HTML if html extraction is specified for certain node", ->

			extractor = new Extractor
				prop1: ".class": "html"

			node = cheerio.load("<html><body><div class='class'><p>Para</p></div></body></html>") "body"
			result = extractor.extract node

			result.should.have.keys "prop1"
			result.prop1.should.eql "<p>Para</p>"
