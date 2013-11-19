start 
	= (Step / Command / Extractor)+

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

StringCharacter "character" 
	= !(Quote / Terminator) character:. {
		return character;
	}

StringLiteral "string" 
	= Quote literal:StringCharacter* Quote {
		return {
			constant: literal.join("")
		};
	}

Variable "variable name" 
	= name:[a-zA-Z_\.]+ {
	  return name.join("");
	}

Integer "integer"
	= digits:[0-9]+ {
		return {
			constant: parseInt(digits.join(""), 10)
		};
	}

DataType "data type"
	= "json" 
	/ "html"

Download "download data of certain type from given source" 
	= type:DataType _ "from" _ source:(Variable / StringLiteral) EOL { 
		return {
			command: "download", 
			dataType: type, 
			source: source
		}; 
	}

Process "process array using given mapper" 
	= "process" _ array:Variable _ "using" _ mapper:Variable EOL { 
		return {
			command: "process", 
			array: array, 
			mapper: mapper
		}; 
	}

Extract "extract properties from given html document" 
	= "extract" _ columns:Variables _ "from" _ source:Variable EOL { 
		return {
			command: "extract", 
			columns: columns, 
			source: source
		}; 
	}

Variables "list of variables" 
	= head:Variable tail:(_? "," _? Variable)* { 
	var result = [head];
		for (var i = 0; i < tail.length; i++) {
				result.push(tail[i][3]);
		}
		return result; 
	}

Assign "assign data from source to destination" 
	= destination:Variable _* "=" _* source:AssignmentSource  { 
		return {
			command: "assign", 
			source: source, 
			destination: destination
		}; 
	}

AssignmentSource
	= source:(StringLiteral EOL / Variable EOL / Integer EOL / Command) { 
		return source[0] || source; 
	} 

Yield "return given data as a step result" 
	= "yield" _ result:(Variable / StringLiteral / Integer) EOL { 
		return { 
			command: "yield",
			result: result
		}; 
	}

Range "generate range"
	= "range" _ "from" _ from:(Integer / Variable) _ "to" _ to:(Integer / Variable) _ "with step" _ step:(Integer / Variable) EOL {
		return {
			command: "range",
			from: from,
			to: to,
			step: step			
		};
	}

Flatten "flatten array of arrays into array"
	= "flatten" _ array:Variable EOL {
		return {
			command: "flatten",
			array: array
		};
	}

Concatenate
	= "concatenate" _ left:(Variable / StringLiteral) _ "and" _ right:(Variable / StringLiteral) EOL {
		return {
			command: "concatenate",
			left: left,
			right: right
		};
	}

StepArguments
	= _ ("with arguments" / "with argument") _ args:Variables {
		return args;
	}

Step
	= "step" _ name:Variable args:StepArguments? EOL commands:Command+ "end of step" EOL {
		return {
			command: "step",
			name: name,
			args: args || null,
			body: commands
		};
	}

Extractor
	= name:Variable _ "extractor" _* "=" _* operations:ExtractionOperations EOL {
		return {
			command: "extractor",
			name: name,
			operations: operations
		};
	}

ExtractionOperations
	= head:ExtractionOperation tail:(_? "|" _? ExtractionOperation)* { 
	var result = [head];
		for (var i = 0; i < tail.length; i++) {
				result.push(tail[i][3]);
		}
		return result; 
	}

ExtractionOperation
	= ParseDate
	/ FormatDate
	/ ParseInteger
	/ GetText
	/ GetAttribute
	/ AddPrefix
	/ Trim
	/ Replace
	/ RegexSelect
	/ Indexer
	/ CssSelect

ParseDate "parse date"
	= "parse date" _ format:StringLiteral {
		return {
			command: "parseDate",
			format: format
		};
	}

Indexer
	= "index" _ index:Integer {
		return {
			command: "indexer",
			index: index
		};
	}

FormatDate "format date"
	= "format date" _ format:StringLiteral {
		return {
			command: "formatDate",
			format: format
		};
	}

ParseInteger "parse integer"
	= "int" {
		return {
			command: "parseInteger"
		};
	}

GetText "get text"
	= "text" {
		return {
			command: "getText"
		};
	}

GetAttribute "get attribute"
	= "@" name:Variable {
		return {
			command: "getAttribute",
			name: name
		};
	}

Trim "trim"
	= "trim" {
		return {
			command: "trim"
		};
	}

AddPrefix "add prefix"
	= "prefix" _ prefix:StringLiteral {
		return {
			command: "addPrefix",
			prefix: prefix
		};
	}

Replace "replace substring with another one"
	= "replace" _ what:StringLiteral _ "with" _ replacement:StringLiteral {
		return {
			command: "replace",
			what: what,
			replacement: replacement
		};
	}

RegexSelect "regular expression select"
	= "/" regex:(!"/" .)+ "/" {
		return {
			command: "regexSelect",
			regex: regex.map(function (x) {
				return x[1];
			}).join("")
		}
	}

CssSelect "CSS select"
	= "css" _ css:[^|]+ {
		return {
			command: "cssSelect",
			css: css.join("").replace(/^\s+|\s+$/g, '')
		};
	}

Command 
	= Assign
	/ Download 
	/ Process 
	/ Extract 
	/ Yield
	/ Range
	/ Flatten
	/ Concatenate