should = require "should"
fs = require "fs"
Translator = require "../../modules/Translator"

describe "Translator", ->

	describe "#translate()", ->

		it "should translate autoriaua.deq", ->

			code = fs.readFileSync __dirname + "/../data/autoriaua.deq"
			expected = fs.readFileSync __dirname + "/../data/autoriaua.deq.code"

			coffee = new Translator().translate code
			coffee.should.eql expected.toString()

		it "should translate douua.deq", ->

			code = fs.readFileSync __dirname + "/../data/douua.deq"
			expected = fs.readFileSync __dirname + "/../data/douua.deq.code"

			coffee = new Translator().translate code
			coffee.should.eql expected.toString()
