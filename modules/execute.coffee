async = require "async"

execute = (input, task, done) ->
	op = @resolve task.op
	op.call input: input, task.params, (error, result) =>
		done error if error		
		async.map task.children, execute.bind(@, result), (error, results) ->
			done error, 
				op: task.op
				result: result
				children: results

### 

Executes `tree` of tasks:

	op: "opname"
	children: [
		op: "opname1", children: ...
		op: "opname2", children: ...
		...
	]

Context (if not null) should have property `resolve` of type `function` 
which accepts op name and returns op instance.

Returns tree of results:

	op: "opname"
	result: ...
	children: [
		op: "opname1", result: ...
		op: "opname2", result: ...
		...
	]

###
module.exports = (tree, context, done) ->
	if not done
		done = context
		context = resolve: require
	execute.call context, {}, tree, done
