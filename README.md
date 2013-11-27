XStruct
=======

Implementation of straightforward extraction of structured data from web pages.

Change History
--------------

0.2.0 - Custom DSL (close to natural language) for query specification. Translator (DSL to CoffeeScript) generates code for asynchronous execution of query. **No backward compatibility with previous version!**

0.1.0 - Very first version. JSON query specification which is quite intricate in case of complex query. Limitation on query complexity (no ablility to do multi-page query).

Status
------

[![Build Status](https://travis-ci.org/titarenko/node-xstruct.png)](https://travis-ci.org/titarenko/node-xstruct)

Usage
-----

Install `xstruct` package.

```bash
npm install xstruct
```

Write your query.

```
block start
	page_url = "http://dou.ua/lenta/articles/software-architect-position"
	page_html = html from page_url
	
	comments = select "#commentsList .b-comment" from page_html
	messages = process comments using extract_message
	
	yield messages
end of block

block extract_message with argument html
	message = extract author, text from html
	yield message	
end of block

text extractor = css ".l-text.text.b-typo" | text | trim
author extractor = css "a.avatar" | text | trim
```

Instantiate `Translator` and call its method `#translate()` feeding it with your query. The outcome will be CoffeeScript code for asynchronous execution of your query.

More details regarding list of keywords and query structure will be added soon.

License
-------

MIT
