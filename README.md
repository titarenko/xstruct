XStruct
=======

Implementation of REST API for extracting structured data from web pages.

Usage
-----

There is only one endpoint -- root, which is used for querying. 

Following is the example of query (can be found in `example.json` as well):
```json
{
	"fetch": "http://dou.ua/forums/topic/7337/",
	"extract": {
		"scope": "#commentsList",
		"items": ".b-comment",
		"properties": {
			"date": {".comment": "@date"},
			"name": {".g-avatar": "@title"},
			"text": {".l-text": "text"}
		}
	},
	"convert": {
		"date": {"moment": "YYYY/MM/DD HH:mm:ss"}
	}
}
```

To query data, simply POST your query formed using format like above as body to root, as result you'll get either `500` with error description or `200` with array of objects of desired structure. 

Live Demo
---------

Application is deployed to Heroku and available via `http://xstruct.herokuapp.com/`.

Try posting `example.json` using `curl`: `curl -H "Content-Type: application/json" -d @example.json http://xstruct.herokuapp.com/`.

Mechanics
---------

1. Page is downloaded using specified URL
2. Page is decoded using encoding provided in its header (if any)
3. Scope (items container node) is extracted
4. Items are extracted
5. For each item: properties are extracted
6. For each item: values of properties are converted (if requested)
7. Array of items is serialized to JSON and sent back to client

Query Format Description
------------------------

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
