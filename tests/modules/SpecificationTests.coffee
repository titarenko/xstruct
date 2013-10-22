Specification = require '../../modules/Specification'
fs = require 'fs'

describe "Specification", ->

	describe "::parse()", ->

		beforeEach ->

			@tree = Specification.parse fs.readFileSync("tests/data/dou").toString()

		it "should parse first level", ->

			@tree.op.should.eql "fetch"
			@tree.args.should.eql ["dou.ua"]
