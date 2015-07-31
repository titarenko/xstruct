var $ = require('../');
var should = require('should');

function getForumThread () {
	return $.getHtml('http://dou.ua/forums/topic/14416/')
		.then(function (html) {
			return html('.b-comment').map(function () {
				var el = $.wrapHtml(this);
				return {
					author: el.find('.avatar').text(),
					time: el.find('.comment-link').text(),
					text: el.find('.text').contents().map(function () {
						return $.wrapHtml(this).text();
					}).get()
				};
			}).toArray();
		})
		.map(function (post) {
			return {
				author: $.cleanText(post, 'author'),
				time: $.cleanText(post, 'time'),
				text: $.cleanText(post, 'text', { singleline: true })
			};
		});
}


describe('xstruct', function () {
	this.timeout(5000);
	it('should pass integration test (dou.ua/forums)', function (done) {
		getForumThread().then(function (posts) {
			(posts && posts.length > 1).should.be.ok;
			done();
		}).catch(done);
	});
});
