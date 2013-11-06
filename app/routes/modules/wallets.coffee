ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.get '/modules/wallets/latest', (ensureLoggedIn app.config.rootPath), (req, res) ->
		for wallet in app.hq.wallets.wallets
			if wallet.update
				wallet.timeSinceUpdate = utils.now() - wallet.update
		res.json
			errors: []
			wallets: app.hq.wallets.wallets
