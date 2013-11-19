start 
	= Command+

_ "whitespace"
	= [ \t]+

Terminator "line terminator"
	= [\r\n]

EOL "end of line"
	= "\n"
	/ "\r"
	/ "\r\n" 
	/ !.

Quote "double quote" 
	= "\""

StringCharacter "character" 
	= !(Quote / Terminator) character:. {
		return character;
	}

StringLiteral "string" 
	= Quote literal:StringCharacter+ Quote {
		return literal.join("");
	}

Variable "variable name" 
	= name:[a-zA-Z_\.]+ {
	  return name.join("");
	}

Integer "integer"
	= digits:[0-9]+ {
		return parseInt(digits.join(""), 10);
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
	= "extract" _ array:Variables _ "from" _ source:Variable EOL { 
		return {
			command: "extract", 
			array: array, 
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
	= destination:Variable _* "=" _* source:(StringLiteral / Command / Variable / Integer) EOL { 
		return {
			command: "assign", 
			source: source, 
			destination: destination
		}; 
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

Command 
	= Download 
	/ Process 
	/ Extract 
	/ Assign 
	/ Yield
	/ Range
	/ Flatten
