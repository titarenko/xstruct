execute = require "../../modules/execute"
sinon = require 'sinon'
should = require 'should'

describe "execute", ->

	describe "#()", ->

		stubTaskFactory = (result) ->
			(params, done) ->
				done null, result

		it "should call resolve if specified", (done) ->

			tree =
				op: "myop1",
				children: []
			context =
				resolve: sinon.stub().withArgs("myop1").returns stubTaskFactory 1

			execute tree, context, (error, result) ->
				should.not.exist error
				result.should.eql
					op: "myop1"
					result: 1
					children: []
				done()

		it "should go deep into the tree building proper result tree", (done) ->

			tree =
				op: "myop1"
				children: [
					op: "myop11", children: [
						op: "myop111", children: []
					]
					op: "myop12", children: []
				]
			context =
				resolve: sinon.stub()

			context.resolve.withArgs("myop1").returns(stubTaskFactory 1)
			context.resolve.withArgs("myop11").returns(stubTaskFactory 11)
			context.resolve.withArgs("myop12").returns(stubTaskFactory 12)
			context.resolve.withArgs("myop111").returns(stubTaskFactory 111)

			execute tree, context, (error, result) ->
				should.not.exist error
				result.should.eql
					op: "myop1"
					result: 1
					children: [
						op: "myop11", result: 11, children: [
							op: "myop111", result: 111, children: []
						]
						op: "myop12", result: 12, children: []
					]
				done()
