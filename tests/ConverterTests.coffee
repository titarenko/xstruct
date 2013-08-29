Converter = require '../models/Converter'

describe "Converter", ->

	describe "#ctor()", ->

		it "should throw if requested converter is unknown", ->

			(() ->
				new Converter
					property: unknownConverter: param1: "value1"
			).should.throw("Converter knows nothing about following method: unknownConverter.")
