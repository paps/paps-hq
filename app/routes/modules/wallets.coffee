ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.get '/modules/wallets/latest', (ensureLoggedIn '/'), (req, res) ->
		res.json
			errors: []
			wallets: app.hq.wallets.wallets
