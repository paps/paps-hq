ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	Configuration = (require __dirname + '/../../models/Configuration') app.db

	app.get '/modules/session/my-configuration', (ensureLoggedIn app.config.rootPath), (req, res) ->
		Configuration.getByIp req.ip, (err, configuration) ->
			res.json
				errors: if err then [err] else []
				configuration: configuration

	app.get '/modules/session/active-sessions', (ensureLoggedIn app.config.rootPath), (req, res) ->
		res.json
			errors: []
			sessions: app.hq.sessions.get()

	app.post '/modules/session/save-configuration', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'autoRefresh', 'invalid auto refresh flag').isInt().min(0).max 1
		(req.assert 'openModules', 'invalid open modules string').len 0, 200
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			Configuration.replaceInto req.ip, (parseInt req.param 'autoRefresh'), (req.param 'openModules'), (err) ->
				res.json errors: if err then [err] else []
