var $ = require('../');
var should = require('should');

function extractPosts (html) {
	return html('.post_block').toArray().map($.wrapHtml).map(extractPost);
}

function extractPostText (html) {
	return html.contents().filter(function () {
		return this.type === 'text' || 
			this.type === 'tag' && 
				this.name !== 'blockquote' && 
				$.wrapHtml(this).attr('class') !== 'edit';
	}).map(function () {
		return $.wrapHtml(this).text();
	}).get();
}

function extractPost (html) {
	return {
		author: html.find('[post-author]').attr('post-author'),
		time: html.find('[itemprop="commentTime"]').attr('title'),
		text: extractPostText(html.find('[itemprop="commentText"]')),
		citation: {
			author: html.find('blockquote').attr('data-author'),
			time: html.find('blockquote').attr('data-time'),
			text: extractPostText(html.find('blockquote'))
		}
	};
}

function cleanPost (post) {
	return $.cleanObject({
		author: $.cleanText(post, 'author'),
		time: $.cleanDateTime(post, 'time'),
		text: $.cleanText(post, 'text', { singleline: true }),
		citation: $.cleanObject({
			author: $.cleanText(post, 'citation.author', { remove: '\'' }),
			time: $.cleanDateTime(post, 'citation.time'),
			text: $.cleanText(post, 'citation.text', { singleline: true })
		})
	});
}

function getAllPageNumbers (indexPageHtml) {
	var lastPage = +indexPageHtml('link[rel="last"]').attr('href').split('page-')[1];
	return $.range(lastPage, lastPage + 1);
}

function getPage (pageNumber) {
	var url = $.format('http://forum.kurs.com.ua/topic/181-prognoz-kursa-dollara-k-grivne/page-%d', pageNumber);
	return $.getHtml(url);
}

function getForumThread () {
	return $.getHtml('http://forum.kurs.com.ua/topic/181-prognoz-kursa-dollara-k-grivne/page')
		.then(getAllPageNumbers)
		.map(getPage, { concurrency: 10 })
		.map(extractPosts)
		.then($.flatten)
		.map(cleanPost)
		.filter($.identity)
		.catch(function (error) {
			console.error(error.stack);
		});
}

describe('xstruct', function () {
	this.timeout(10000);
	it('should pass integration test (forum.kurs.com.ua)', function (done) {
		getForumThread().then(function (posts) {
			(posts && posts.length > 1).should.be.ok;
			done();
		}).catch(done);
	});
});
