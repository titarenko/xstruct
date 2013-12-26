module.exports = (grunt) ->

	grunt.initConfig

		release:
			options:
				push: false
				pushTags: false
				folder: 'js'
				github: 
					repo: 'titarenko/node-xstruct'
					#usernameVar: 'GITHUB_USERNAME', //ENVIRONMENT VARIABLE that contains Github username 
					#passwordVar: 'GITHUB_PASSWORD' //ENVIRONMENT VARIABLE that contains Github password

	grunt.loadNpmTasks "grunt-release"
