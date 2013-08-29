should = require 'should'
nock = require 'nock'
Query = require '../models/Query'

describe "Query", ->

	describe "#execute()", ->

		it "should parse example page from dou.ua", (done) ->

			nock("http://dou.ua")
				.get('/forums/topic/8046/')				
				.replyWithFile(200, "#{__dirname}/data/http___dou.ua_forums_topic_8046_.html");

			query = new Query
				fetch: "http://dou.ua/forums/topic/8046/"
				extract:
					scope: "#commentsList"
					items: ".b-comment"
					properties:
						name: {".g-avatar": "@title"}
						text: {".l-text": "text"}

			query.execute (error, results) ->

				should.not.exist error
				
				results.should.have.lengthOf 246

				last = results[245]

				last.should.have.keys "name", "text"

				last.name.should.eql "gorik"
				last.text.should.eql "И свою не разглашаю, и зарплатой других не интересуюсь. Откуда знаю? Некоторые друзья-знакомые сами спешат похвастаться. Еще довольно часто хожу по собеседованиям, где часто получаю офферы."

				nock.restore()
				done()
