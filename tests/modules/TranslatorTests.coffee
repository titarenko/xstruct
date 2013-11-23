should = require "should"
fs = require "fs"
Translator = require "../../modules/Translator"

describe "Translator", ->

	describe "#translate()", ->

		it "should translate autoriaua.deq", ->

			code = fs.readFileSync __dirname + "/../data/autoriaua.deq"
			# tree = JSON.parse fs.readFileSync __dirname + "/../data/autoriaua.deq.tree.json"

			coffee = new Translator().translate code
			fs.writeFileSync __dirname + "/../data/autoriaua.coffee", coffee 
