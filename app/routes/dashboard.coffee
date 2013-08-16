ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.get '/dashboard', (ensureLoggedIn '/'), (req, res) ->
		res.render 'dashboard',
			title: 'Dashboard'
