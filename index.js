var Promise = require('bluebird');
var request = require('request');
var cheerio = require('cheerio');
var util = require('util');
var iconv = require('iconv-lite');
var _ = require('lodash');
var moment = require('moment');
var limit = require('simple-rate-limiter');

var defaultOptions = {};

function doRequest (options) {
	if (!_.isEmpty(defaultOptions)) {
		options = _.clone(options);
		_.defaults(options, defaultOptions);
	}
	var promise = new Promise(function (resolve, reject) {
		request(options, function (error, response, body) {
			if (error) {
				return reject(error);
			}
			return resolve(response);
		});
	});
	return promise.then(function (response) {
		var code = response.statusCode;
		if (code >= 400) {
			throw new Error(util.format('Request %j failed with code %d!', options, code));
		}
		return response.body;
	});
}

function decode(encoding) {
	return function (body) {
		return iconv.decode(body, encoding || 'utf-8');
	};
}

function getJson (url, qs) {
	var options = { url: url };
	if (qs) {
		options.qs = qs;
	}
	return doRequest(options).then(JSON.parse);
}

function getHtml (url, qs, encoding) {
	var options = { url: url };
	if (_.isObject(qs)) {
		options.qs = qs;
	} else {
		encoding = qs;
	}
	if (encoding) {
		options.encoding = null;
	}
	return (encoding
		? doRequest(options).then(decode(encoding))
		: doRequest(options)
	).then(cheerio.load);
}

function postForm(url, form) {
	defaultOptions.jar = true;
	return doRequest({ method: 'POST', url: url, form: form });
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
		return new Date(+t*1000);
	}
	var func = options && options.utc ? moment.utc : moment;
	var m = options && options.format ? func(t, options.format) : func(t);
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
	limit: function (count, period) {
		request = limit(require('request')).to(count).per(period);
	},
	getJson: getJson,
	getHtml: getHtml,
	postForm: postForm,
	request: doRequest,
	wrapHtml: cheerio,
	format: util.format,
	cleanText: cleanText,
	cleanDateTime: cleanDateTime,
	cleanNumber: cleanNumber,
	cleanObject: cleanObject
}, _);
