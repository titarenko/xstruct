start 
	= command+

datatype "data type"
	= "json" 
	/ "html"

_ "whitespace"
	= [ \t]+

eol "end of line"
	= "\n"
	/ "\r"
	/ "\r\n" 
	/ !.

name "name"
	= v:[a-z_:/.=#{}&?]+ {
		return v.join("");
	}

digits "digits"
	= v:[0-9]+ {
		return parseInt(v.join(""), 10);
	}

download "download data of certain type from given source" 
	= t:datatype _ "from" _ s:name eol { 
		return {
			command: "download", 
			datatype: t, 
			source: s
		}; 
	}

process "process array using given mapper" 
	= "process" _ a:name _ "using" _ f:name eol { 
		return {
			command: "process", 
			array: a, 
			mapper: f
		}; 
	}

extract "extract properties from given html document" 
	= "extract" _ a:namelist _ "from" _ s:name eol { 
		return {
			command: "extract", 
			array: a, 
			source: s
		}; 
	}

namelist "list of names" 
	= head:name tail:(_? "," _? name)* { 
	var result = [head];
		for (var i = 0; i < tail.length; i++) {
				result.push(tail[i][3]);
		}
		return result; 
	}

assign "assign data from source to destination" 
	= d:name _? "=" _? s:(command / name / digits) eol { 
		return {
			command: "assign", 
			source: s, 
			destination: d
		}; 
	}

yield "return given data as a step result" 
	= "yield" _ n:name eol { 
		return { 
			command: "yield",
			result: n
		}; 
	}

range "generate range"
	= "range" _ "from" _ b:(digits / name) _ "to" _ e:(digits / name) _ "with step" _ s:(digits / name) eol {
		return {
			command: "range",
			from: b,
			to: e,
			step: s			
		};
	}

flatten "flatten array of arrays into array"
	= "flatten" _ n:name eol {
		return {
			command: "flatten",
			array: n
		};
	}

command 
	= download 
	/ process 
	/ extract 
	/ assign 
	/ yield
	/ range
	/ flatten
