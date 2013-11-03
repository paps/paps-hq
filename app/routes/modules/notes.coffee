ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	Note = (require __dirname + '/../../models/Note') app.db

	app.get '/modules/notes/notes', (ensureLoggedIn app.config.rootPath), (req, res) ->
		Note.get (err, notes) ->
			res.json
				errors: if err then [err] else []
				notes: notes

	app.post '/modules/notes/add-or-edit', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'name', 'invalid name').len 1, 100
		(req.assert 'text', 'text too long').len 0, 10000
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			id = parseInt (req.param 'id')
			if id
				Note.update
					id: id
					name: (req.param 'name')
					text: (req.param 'text'),
					(err) -> res.json errors: if err then [err] else []
			else
				Note.insert (req.param 'name'), (req.param 'text'),
					(err) -> res.json errors: if err then [err] else []

	app.post '/modules/notes/del', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'id', 'invalid id').isInt()
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			Note.delete (req.param 'id'), (err) -> res.json errors: if err then [err] else []
