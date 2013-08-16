ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.get '/modules/bank', (ensureLoggedIn '/'), (req, res) ->
