start 
	= (Block 
	/ Assignment 
	/ Yield 
	/ Extractor)+

/* Characters */

_ "whitespace"
	= [ \t]+

EOL "end of line"
	= "\n"
	/ "\r"
	/ "\r\n" 
	/ !.

Terminator "line terminator"
	= ([\r\n] / !.)

Quote "double quote" 
	= "\""

StringCharacter "string character" 
	= !(Quote / Terminator) character:. {
		return character;
	}

/* Built-in Enumerations */

DataType "data type"
	= value:("json" 
	/ "html") {
		return '"' + value + '"';
	}

/* Language Objects */

StringLiteral "string" 
	= Quote literal:StringCharacter* Quote {
		return '"' + literal.join("") + '"';
	}

Integer "integer"
	= digits:[0-9]+ {
		return parseInt(digits.join(""), 10);
	}

Variable "variable name" 
	= name:[a-zA-Z_\.]+ {
	  return name.join("");
	}

Variables "list of variables" 
	= head:Variable tail:(_? "," _? Variable)* { 
		var result = [head];
		for (var i = 0; i < tail.length; i++) {
				result.push(tail[i][3]);
		}
		return result; 
	}

Constant "constant"
	= value:(StringLiteral / Integer) EOL {
		return value;
	}

Call "function call"
	= func:(Download 
	/ Process 
	/ Extract 
	/ Range
	/ Flatten
	/ Concatenate) {
		return {
			type: "call",
			func: func.func,
			args: func.args
		};
	}

Assignment
	= ConstantAssignment 
	/ CallResultAssignment

ConstantAssignment "constant assignment"
	= result:Variable _* "=" _* constant:Constant {
		return {
			type: "constant",
			name: result,
			value: constant
		};
	}

CallResultAssignment "call result assignment"
	= result:Variable _* "=" _* call:Call {
		return {
			type: call.type,
			func: call.func,
			args: call.args,
			result: result
		};
	}

Yield "yield result" 
	= "yield" _ result:(Variable / Constant) EOL? { 
		return {
			type: "return",
			result: result
		}; 
	}

Block
	= "block" _ name:Variable args:BlockArguments? EOL commands:(Assignment / Yield)+ "end of block" EOL {
		return {
			type: "block",
			name: name,
			args: args || [],
			body: commands
		};
	}

BlockArguments
	= _ ("with arguments" / "with argument") _ args:Variables {
		return args;
	}

/* Built-in Functions */

Download "download data of certain type from given source" 
	= type:DataType _ "from" _ source:(Variable / StringLiteral) EOL { 
		return {
			func: "download",
			args: [type, source]
		}; 
	}

Process "process array using given mapper" 
	= "process" _ array:Variable _ "using" _ mapper:Variable EOL { 
		return {
			func: "process",
			args: [array, mapper]
		}; 
	}

Extract "extract properties from given html document" 
	= "extract" _ columns:Variables _ "from" _ source:Variable EOL { 
		var mappedColumns = '[' + columns
			.map(function (c) { return '"' + c + '"'; })
			.join(", ") + ']';
		return {
			func: "extract", 
			args: [mappedColumns, source]
		}; 
	}

Range "generate range"
	= "range" _ "from" _ from:(Integer / Variable) _ "to" _ to:(Integer / Variable) _ "with step" _ step:(Integer / Variable) EOL {
		return {
			func: "range",
			args: [from, to, step]
		};
	}

Flatten "flatten array of arrays into array"
	= "flatten" _ array:Variable EOL {
		return {
			func: "flatten",
			args: [array]
		};
	}

Concatenate
	= "concatenate" _ left:(Variable / StringLiteral) _ "and" _ right:(Variable / StringLiteral) EOL {
		return {
			func: "concatenate",
			args: [left, right]
		};
	}

/*
	Extraction
*/

Extractor "extractor"
	= name:Variable _ "extractor" _* "=" _* operations:ExtractionOperations EOL {
		return {
			type: "extractor",
			name: name,
			operations: operations
		};
	}

ExtractionOperations "extraction operations sequence"
	= head:ExtractionOperation tail:(_? "|" _? ExtractionOperation)* { 
	var result = [head];
		for (var i = 0; i < tail.length; i++) {
				result.push(tail[i][3]);
		}
		return result; 
	}

ExtractionOperation "extraction operation"
	= operation:(ParseDate
	/ FormatDate
	/ ParseInteger
	/ GetText
	/ GetAttribute
	/ AddPrefix
	/ Trim
	/ Replace
	/ RegexSelect
	/ Indexer
	/ CssSelect) {
		return {
			type: "extractionOperation",
			func: operation.func,
			args: operation.args || []
		};
	}

ParseDate "parse date"
	= "parse date" _ format:StringLiteral {
		return {
			func: "parseDate",
			args: [format]
		};
	}

Indexer
	= "index" _ index:Integer {
		return {
			func: "indexer",
			args: [index]
		};
	}

FormatDate "format date"
	= "format date" _ format:StringLiteral {
		return {
			func: "formatDate",
			args: [format]
		};
	}

ParseInteger "parse integer"
	= "int" {
		return {
			func: "parseInteger"
		};
	}

GetText "get text"
	= "text" {
		return {
			func: "getText"
		};
	}

GetAttribute "get attribute"
	= "@" name:Variable {
		return {
			func: "getAttribute",
			args: [name]
		};
	}

Trim "trim"
	= "trim" {
		return {
			func: "trim"
		};
	}

AddPrefix "add prefix"
	= "prefix" _ prefix:StringLiteral {
		return {
			func: "addPrefix",
			args: [prefix]
		};
	}

Replace "replace substring with another one"
	= "replace" _ what:StringLiteral _ "with" _ replacement:StringLiteral {
		return {
			func: "replace",
			args: [what, replacement]
		};
	}

RegexSelect "regular expression select"
	= "/" regex:(!"/" .)+ "/" {
		return {
			func: "regexSelect",
			args: [regex.map(function (x) {
				return x[1];
			}).join("")]
		}
	}

CssSelect "CSS select"
	= "css" _ css:[^|]+ {
		return {
			func: "cssSelect",
			args: [css.join("").replace(/^\s+|\s+$/g, '')]
		};
	}
