XStruct
=======

Implementation of straightforward extraction of structured data from web pages.

Status
------

Current status is **stable beta**. Code **test coverage according to [istanbul](https://github.com/gotwarlost/istanbul): 100%**.

[![Build Status](https://travis-ci.org/titarenko/node-xstruct.png)](https://travis-ci.org/titarenko/node-xstruct)

Usage
-----

```bash
npm install xstruct
```

```js
var Query = require("xstruct").Query;

var query = new Query({
	fetch: "http://dou.ua/forums/topic/7337/",
	extract: {
		scope: "#commentsList",
		items: ".b-comment",
		properties: {
			date: {".comment": "@date"},
			name: {".g-avatar": "@title"},
			text: {".l-text": "text"}
		}
	},
	convert: {
		date: {moment: "YYYY/MM/DD HH:mm:ss"}
	}
});

query.execute(function (error, items) {
	console.log(error || items);
});
```

Mechanics
---------

1. Page is downloaded using specified URL
2. Page is decoded using encoding provided in its header (if any)
3. Scope node (items container) is extracted
4. Item nodes are extracted
5. For each item: properties are extracted
6. For each item: values of properties are converted (if requested)
7. Items are passed to callback (as second argument)

Query Specification
-------------------

```json
{
	"fetch": "<url>",
	"extract": {
		"scope": "<scope node selector>",
		"items": "<item node selector>",
		"properties": {
			"<property name>": {"<property node selector>": "<property value selector>"}
		}
	},
	"convert": {
		"<property name>": {"<converter name>": <converter parameters>}
	}
}
```

- `<url>` -- document address
- `<scope node selector>` -- CSS selector of page block with desired items (will be used to select single node where nodes of interest are contained)
- `<item node selector>` -- CSS selector of single item node (will be used to select nodes of all items)
- `<property name>` -- desired name for certain property of extracted object
- `<property node selector>` -- CSS selector for node of current property (will be used to select property node contained in item node)
- `<property value selector>` -- defines rule how actual value (string at this stage) will be selected from property node, allowed values: `text` (node content as text), `html` (node content as HTML) and `@<attribute name>` (value of certain node's attribute)
- `<converter name>` -- name of property converter, allowed values are: `moment` (string to date parsing, format string should be passed as converter parameters: see [moment js documentation on format details](http://momentjs.com/docs/#/parsing/string-format/)) 
- `<converter parameters>` -- any entity (string, object, whatsoever) which will be used to configure converter 

License (BSD)
-------------

Copyright (c) 2013, Constantin Titarenko

All rights reserved.


Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:


Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
