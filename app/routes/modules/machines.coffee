ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	utils = require __dirname + '/../../lib/utils'

	app.post '/modules/machines/update', (req, res) ->
		if (req.param 'password') isnt app.config.machines.password
			res.json errors: ['incorrect password']
		else
			errors = []
			name = req.param 'name'
			if (typeof name isnt 'string') or name.length < 1 or name.length > 100
				errors.push 'invalid name'
			uptime = parseFloat req.param 'uptime'
			if uptime < 0
				errors.push 'invalid uptime'
			load = parseFloat req.param 'load'
			if load < 0
				errors.push 'invalid load'
			if not errors.length
				app.hq.machines.update name, req.ip, uptime, load
			res.json errors: errors

	app.get '/modules/machines/latest', (ensureLoggedIn app.config.rootPath), (req, res) ->
		for name, machine of app.hq.machines.machines
			if machine.update
				machine.timeSinceUpdate = utils.now() - machine.update
		res.json
			errors: []
			machines: app.hq.machines.machines
