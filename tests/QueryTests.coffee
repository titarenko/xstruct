should = require 'should'
nock = require 'nock'
Query = require '../models/Query'

describe "Query", ->

	describe "#execute()", ->

		it "should parse example page from dou.ua", (done) ->

			nock("http://dou.ua")
				.get('/forums/topic/8046/')				
				.replyWithFile(200, "#{__dirname}/data/http___dou.ua_forums_topic_8046_.html")

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

				done()

		it "should parse example page from livejournal.com", (done) ->

			nock("http://pauluskp.livejournal.com")
				.get('/407584.html')
				.replyWithFile(200, "#{__dirname}/data/http___pauluskp.livejournal.com_407584.html")

			query = new Query
				fetch: "http://pauluskp.livejournal.com/407584.html"
				extract:
					scope: "#comments"
					items: ".comment-wrap"
					properties:
						author: {".comment-head-in > p:first-child": "text"}
						message: {".comment-text": "text"}
						timestamp: {".comment-permalink > span": "text"}
				convert:
					timestamp: {"moment": "YYYY-MM-DD HH:mm"}

			query.execute (error, results) ->

				should.not.exist error
				
				results.should.have.lengthOf 45

				last = results[4]

				last.should.have.keys "author", "message", "timestamp"

				last.author.should.eql "Constantin Titarenko"
				last.message.should.eql "Вот это поворот! Значит можно сбивать всех, кто способен найти деньги на лечение? Вы действительно хотите жить в таком обществе?"
				last.timestamp.should.eql new Date Date.UTC 2013, 6, 28, 20, 3

				done()
