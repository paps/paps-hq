ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.post '/modules/mining/update', (req, res) ->
		if (req.param 'password') isnt app.config.mining.password
			res.json errors: ['incorrect password']
		else
			try
				status = JSON.parse req.param 'status'
			catch e
				res.json errors: ['invalid status json']
				return
			if typeof(status) isnt 'object'
				res.json errors: ['status is not a json object']
				return
			if (not Array.isArray status.STATUS) or (not Array.isArray status.DEVS)
				res.json errors: ['could not find STATUS or DEVS arrays']
				return
			miner = req.param 'miner'
			if miner.length < 1 or miner.length > 20
				res.json errors: ['invalid miner name']
				return
			app.hq.mining.update miner, status
			res.json errors: []

	app.get '/modules/mining/latest', (ensureLoggedIn '/'), (req, res) ->
		res.json
			errors: []
			miners: app.hq.mining.miners
