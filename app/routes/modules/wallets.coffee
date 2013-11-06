ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	utils = require __dirname + '/../../lib/utils'

	app.get '/modules/wallets/latest', (ensureLoggedIn app.config.rootPath), (req, res) ->
		for currency in app.hq.wallets.wallets
			for wallet in currency.wallets
				if wallet.update
					wallet.timeSinceUpdate = utils.now() - wallet.update
		res.json
			errors: []
			wallets: app.hq.wallets.wallets
