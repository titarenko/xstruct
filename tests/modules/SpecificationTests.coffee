Specification = require "../../modules/Specification"
fs = require 'fs'

describe "Specification", ->

	describe "::parse()", ->

		beforeEach (done) ->

			@specification = Specification.parse fs.readFileSync("tests/data/dou.query").toString()

			done()

		it "should parse first level of correct specification", (done) ->
					
			@specification.op.should.eql "fetch"
			@specification.args.should.eql ["dou.ua"]

			done()

		it "should parse second level of correct specification", (done) ->

			children = @specification.children

			children.should.have.lengthOf 1
			children[0].op.should.eql "select"
			children[0].args.should.eql [".comments"]

			done()

		it "should parse third level of correct specification", (done) ->

			children = @specification.children[0].children

			children.should.have.lengthOf 3

			children[0].op.should.eql "select"
			children[0].args.should.eql [".message"]

			children[1].op.should.eql "select"
			children[1].args.should.eql [".a:text"]

			children[2].op.should.eql "select"
			children[2].args.should.eql [".d:@title"]

			done()

		it "should parse fourth level (collapsed) of correct specification", (done) ->

			children = @specification.children[0].children[1].children

			children.should.have.lengthOf 1

			children[0].op.should.eql "add"
			children[0].args.should.eql ["author"]

			done()
