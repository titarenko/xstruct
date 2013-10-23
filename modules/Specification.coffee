$ = require 'string'

split = (line, separator) ->
        line
                .split(separator)
                .map((x) -> $(x).trim().s)
                .filter((x) -> x.length)

getLevel = (line) ->
        tabs = line.match /^(\t+)/
        spaces = line.match /^( +)/
        if tabs and spaces
                throw new Error "Wrong indentation: tabs and spaces are mixed."
        indentation = tabs?[0] or spaces?[0] or ""
        return indentation.length

getTask = (line) ->
        tokens = split line, " "
        if tokens.length < 1
                throw new Error "Task definition should contain at least operation name."
        op: tokens[0]
        args: tokens.slice(1)
        children: []

getTaskChain = (line) ->
        split(line, "|").map(getTask)

chainToHierarchy = (chain) ->
        parent = chain[0]
        for task in chain.slice(1)
                parent.children.push task
                parent = task
        return chain[0]

getTasksByLevel = (text) ->
        for line in $(text).lines() when line.length
                level: getLevel line
                task: chainToHierarchy getTaskChain line

getFirstTask = (tasks, startFrom, level) ->
        while startFrom >= 0
                instance = tasks[startFrom--]
                if instance.level == level
                        return instance.task
        throw new Error "Task level consistency is corrupted. There is non-root task without a parent."

parseSpecification = (text) ->
        tasks = getTasksByLevel text
        root = tasks[0].task
        for tuple, index in tasks.slice(1)
                parent = getFirstTask tasks, index, tuple.level - 1
                parent.children.push tuple.task
        return root

module.exports = class Specification

        @parse: parseSpecification
