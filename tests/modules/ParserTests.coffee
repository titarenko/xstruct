should = require "should"
fs = require "fs"
Parser = require "../../modules/Parser"

describe "Parser", ->

	describe "#parse()", ->

		it "should parse autoriaua.deq", ->

			code = fs.readFileSync __dirname + "/../data/autoriaua.deq"
			tree = JSON.parse fs.readFileSync __dirname + "/../data/autoriaua.deq.tree"

			parsed = new Parser().parse code
			parsed.should.eql tree 

		it "should parse douua.deq", ->

			code = fs.readFileSync __dirname + "/../data/douua.deq"
			tree = JSON.parse fs.readFileSync __dirname + "/../data/douua.deq.tree"

			parsed = new Parser().parse code
			parsed.should.eql tree 
