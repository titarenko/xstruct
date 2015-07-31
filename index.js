var Promise = require('bluebird');
var request = require('request');
var cheerio = require('cheerio');
var util = require('util');
var iconv = require('iconv-lite');
var _ = require('lodash');
var moment = require('moment');

function get (url) {
	return new Promise(function (resolve, reject) {
		request({
			url: url,
			encoding: null
		}, function (error, response, body) {
			if (error) {
				return reject(error);
			}
			var code = response.statusCode;
			if (code != 200) {
				throw new Error(util.format('GET %s failed with code %d!', url, code));
			}
			return resolve(body);
		});
	});
}

function decode(encoding) {
	return function (body) {
		return iconv.decode(body, encoding || 'utf-8');
	};
}

function getJson (url) {
	return get(url).then(JSON.parse);
}

function getHtml (url, encoding) {
	return get(url).then(decode(encoding)).then(cheerio.load);
}

function cleanText (obj, path, options) {
	var defaultSeparator = '. ';
	var t = _.get(obj, path);
	if (t === null || t === undefined || _.isArray(t) && _.isEmpty(t)) {
		return null;
	}
	if (!_.isString(t)) {
		if (_.isArray(t) && options && options.singleline) {
			t = t.map(function (i) {
				return cleanText({ i: i }, 'i', options);
			}).filter(_.identity).join(options.singleline.separator || defaultSeparator);
		} else {
			t = t.toString();
		}
	}
	t = _.trim(t);
	if (options && options.remove) {
		t = t.replace(new RegExp('[' + options.remove + ']+', 'g'), '');
	}
	if (!t.length) {
		return null;
	}
	t = t.replace(/\s{2,}/g, ' ');
	if (options && options.singleline) {
		t = t.replace(/[\n]+/g, options.singleline.separator || defaultSeparator);
	}
	t = t.replace(/\.{2,}/g, '.');
	return t;
}

function cleanDateTime (obj, path, options) {
	var t = cleanText(obj, path);
	if (!t) {
		return t;
	}
	if (/\d{10}/.test(t)) {
		return new Date(+t);
	}
	var m = options && options.format ? moment(t, options.format) : moment(t);
	if (!m.isValid()) {
		return null;
	}
	return m.toDate();
}

function cleanNumber (obj, path) {
	var t = cleanText(obj, path);
	if (!t) {
		return t;
	}
	var n = +t;
	if (isNaN(n)) {
		return null;
	}
	return n;
}

function cleanObject (obj) {
	var compact = compactObject(_.cloneDeep(obj));
	if (_.isEmpty(compact)) {
		return null;
	}
	return obj;
}

function compactObject (o) {
	_.each(o, function checkProperty (v, k) {
		if (v === null || v === undefined || (_.isArray(v) || _.isString(v)) && _.isEmpty(v)) {
			delete o[k];
		}
	});
	return o;
}

module.exports = _.assign({
	getJson: getJson,
	getHtml: getHtml,
	wrapHtml: cheerio,
	format: util.format,
	cleanText: cleanText,
	cleanDateTime: cleanDateTime,
	cleanNumber: cleanNumber,
	cleanObject: cleanObject
}, _);
