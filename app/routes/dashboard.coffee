ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.get '/dashboard', (ensureLoggedIn app.config.rootPath), (req, res) ->
		res.render 'dashboard',
			title: 'Dashboard',
			loadJs: true
