should = require "should"
fs = require "fs"
StepParser = require "../../modules/StepParser"

describe "StepParser", ->

	describe "#parse()", ->

		it "should parse constant assignment and entry point call", (done) ->

			code = fs.readFileSync __dirname + "/../data/autoriaua/step1.txt"

			new StepParser().parse code.toString(), (error, commands) ->

				should.not.exist error
				commands.should.eql [
					{
						"command": "assign",
						"source": "http://auto.ria.ua/blocks_search_ajax/search?marka=<%= brand %>&model=<%= model %>",
						"destination": "catalog_url"
					},
					{
						"command": "yield",
						"result": "get_ads"
					}
				]
				done()
