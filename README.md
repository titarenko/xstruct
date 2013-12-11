XStruct
=======

Implementation of straightforward extraction of structured data from web pages.

[![Build Status](https://secure.travis-ci.org/titarenko/node-xstruct.png?branch=master)](https://travis-ci.org/titarenko/node-xstruct) [![Coverage Status](https://coveralls.io/repos/titarenko/node-xstruct/badge.png)](https://coveralls.io/r/titarenko/node-xstruct)

[![NPM](https://nodei.co/npm/xstruct.png?downloads=true&stars=true)](https://nodei.co/npm/xstruct/)

Usage
-----

```bash
npm install xstruct
```

Example of how easy it is to extract comments from [dou.ua forum](http://dou.ua/forum).

```coffee
xstruct = require "xstruct"

# ...

xstruct("http://dou.ua")

	.html("/forums/topic/8751")

	.then((html) -> 
		html.get (el) -> 
			el.css(".b-comment").map (el) ->
				author: el.get (child) -> child.css(".avatar").text().trim()
				time: el.get (child) -> child.css(".date").text().trim()
				text: el.get (child) -> child.css(".text p").text()
	)
	
	.on("progress", (percentage) -> 
		progressBar.update percentage # this one will change from 0 to 100
	)
	
	.on("error", (error) ->
		log.error error
	)
	
	.on("log", (message, meta) ->
		log.debug message, meta # message is textual info describing log event, meta is object with context data
	)

	.on("finished", (data) ->
		db.store data # in this example data is array of objects with properties: author, time, text
	)

	.done()
```

API
---

## High Level (XStruct API)

### json(url)

downloads JSON using given URL

### html(url)

downloads HTML using given URL, returns wrapper object to do low-level operations

### then(function)

executes function feeding it with result of previous call

### map(mapper)

allows to map result of previous call treating it as an array

### flatten

flattens result of previous call treating it as an array of arrays

### start

starts progress reporting, should be called before `map` and furtherly accompanied by `advance` calls from `mapper`

### advance

advances progress by one unit (which means next element of array was processed)

### done

should always close the chain of API calls unless you use promises

### promise

an alternative to node-style of doing async things, returns [`Q` promise](https://github.com/kriskowal/q)

## Low Level (HTML wrapper API)

### get(function)

starts extraction by calling specified function feeding it with query root which should be treated as jQuery instance ($)

### attr(name)

extracts attribute by its name

### trim

trims result of previous call

### text

gets text of HTML node

### regex(regex)

returns first match using given regex

### replace(...)

acts like `String::replace` on result of previous call

### float

parses float (converts result of previous call to float)

### parse(format)

parses string to date using given format ([moment.js style](http://momentjs.com/docs/#/parsing/string-format/))

### format(format)

formats date to string using given format ([moment.js style](http://momentjs.com/docs/#/parsing/string-format/))

### at(index)

selects element from an array using given index

### map(mapper)

acts like `Array::map` on result of previous call

### coalesce(value)

coalesces result of previous call with given value

License (BSD)
-------------

Copyright (c) 2013, Constantin Titarenko

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
