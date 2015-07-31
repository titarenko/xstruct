# xstruct

Set of tools for structured data extraction from web.

[![Build Status](https://secure.travis-ci.org/titarenko/xstruct.png?branch=master)](https://travis-ci.org/titarenko/xstruct) [![Coverage Status](https://coveralls.io/repos/titarenko/xstruct/badge.png)](https://coveralls.io/r/titarenko/xstruct)

[![NPM](https://nodei.co/npm/xstruct.png?downloads=true&stars=true)](https://nodei.co/npm/xstruct/)

## Installation

```bash
npm i xstruct --save
```

## Example

Example of how easy it is to extract, for example, comments from [dou.ua forum](http://dou.ua/forum).

```js
var $ = require('xstruct');

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
	})
	.done(console.log, console.log);
```

## Description

### getHtml(url[, encoding])

Returns promise with downloaded and cheerio-wrapped HTML (optionally, if encoding is specified, document will be converted before passing it to cheerio).

### getJson(url)

Returns promise with downloaded and parsed JSON.

### postForm(url, form)

Returns promise with result of form posting. Activates cookie persistence.

### request(options)

Promised version of `request.js` root function.

### wrapHtml(cheerioElement)

Calls `cheerio(cheerioElement)` and returns result synchronously.

### format

Alias for `util.format`.

### cleanText(obj, path[, options])

Takes text from object using path and cleans it by removing heading and trailing spaces, removing space and period repetitions, converting to single-line text if `options.singleline` is specified, and also removing any characters from ones specified via `options.remove` (if specified). Returns null if result is empty string or nothing.

### cleanNumber(obj, path)

Acts like `cleanText`, but casts result to number in the end. If result is not-a-number, returns null.

### cleanDateTime(obj, path[, options])

Acts like `cleanText`, but casts result to date in the end (using moment.js). If result is not a valid date, returns null. You can optionally specify date-time format via `options.format`.

## cleanObject(obj)

Returns object as is or null if all its properties do not have value.

### _.*

Exposes all functions from `lodash`.

## Building blocks

This library is built with heavy usage of `request`, `cheerio`, `lodash` and `bluebird`. Also it uses `iconv-lite`, `moment` and `util` as additional utils.

# License

MIT
