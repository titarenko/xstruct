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

Example of how easy it is to extract, for example, comments from [dou.ua forum](http://dou.ua/forum).

```coffee
xstruct = require "xstruct"

# ...

# setup pipeline

xstruct("http://dou.ua")

	# following two calls are optional
	.progress((info) -> ...) # info will contain marker, total, done and fraction (which is done/total) properties  
	.log((info) -> ...) # info will contain object describing log event

# setup is done -- define steps

	.html("/forums/topic/8751")
	.then((html) -> 
		html.get (el) -> 
			el.css(".b-comment").map (el) ->
				author: el.get (child) -> child.css(".avatar").text().trim()
				time: el.get (child) -> child.css(".date").text().trim()
				text: el.get (child) -> child.css(".text p").text()
	)

# pipeline is defined -- handle results

	.promise() # returns Q's promise
	.catch((error) -> ...)
	.done((data) -> ...) # in this case data will be array of objects with "author", "time" and "text" properties 
```

API
---

## High Level (Pipeline API)

### progress(delay, function)

setups progress reporting, which will be done by calling given function with frequency no more than 1 time per `delay` period

### marker(string)

sets marker as a parameter for progress reporting routine; this one will be used to distinguish different progressing processes; if not set, "default" will be used as marker

### log(function)

setups log event reporting, which will be done by calling given function


### concurrency(number)

limits number of simultaneoulsy running asynchronous operations

### json(url)

downloads JSON using given URL; if URL is omitted, result of previous step will be used as URL

### html(url)

downloads page using given URL, returns instance of HtmlProcessor (see below) to do extraction from HTML; if URL is omitted, result of previous step will be used as URL

### then(function)

executes function feeding it with result of previous call

### map(mapper)

allows to map result of previous call treating it as an array; while doing mapping progress will be reported

### each(function)

executes given function on each item of previous step execution result; reports progress just like `map` does 

### flatten

flattens result of previous call treating it as an array of arrays

### promise

returns [`Q` instance](https://github.com/kriskowal/q)

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
