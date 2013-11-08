ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	utils = require __dirname + '/../../lib/utils'

	app.get '/modules/btc-china/latest', (ensureLoggedIn app.config.rootPath), (req, res) ->
		res.json
			errors: []
			status: app.hq.btcChina.get()
