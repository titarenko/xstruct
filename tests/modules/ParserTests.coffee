should = require "should"
fs = require "fs"
Parser = require "../../modules/Parser"

describe "Parser", ->

	describe "#parse()", ->

		it "should parse autoriaua.deq", (done) ->

			code = fs.readFileSync __dirname + "/../data/autoriaua.deq"
			tree = JSON.parse fs.readFileSync __dirname + "/../data/autoriaua.deq.tree.json"

			new Parser().parse code, (error, commands) ->

				should.not.exist error
				commands.should.eql tree 

				done()
