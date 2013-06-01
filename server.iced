express = require 'express'
Query = require './models/Query'

app = express()

app.use express.bodyParser()

app.get "/", (req, res) ->
	res.redirect "https://github.com/titarenko/node-xstruct"

app.post "/", (req, res) ->
	await (new Query req.body).execute defer error, items
	if error
		res.statusCode = 500
		res.send error.toString()
	else
		res.json items

port = process.env.PORT or 3000
app.listen port, ->
	console.log "Listening on #{port}..."
