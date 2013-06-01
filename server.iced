express = require 'express'
require 'express-resource'
Query = require './models/Query'

app = express()

app.use express.bodyParser()

app.resource "",
	index: (req, res) ->
		await (new Query req.body).execute defer error, items
		if error
			res.statusCode = 500
			res.send error
		else
			res.json items

port = process.env.PORT or 3000
app.listen port, ->
	console.log "Listening on #{port}..."
