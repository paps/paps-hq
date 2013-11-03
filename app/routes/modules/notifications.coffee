ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	Notification = (require __dirname + '/../../models/Notification') app.db
	addNotification = (require __dirname + '/../../notificators/add') app

	app.get '/modules/notifications/notifications', (ensureLoggedIn app.config.rootPath), (req, res) ->
		Notification.getLast (err, notifications) ->
			res.json
				errors: if err then [err] else []
				notifications: notifications

	app.get '/modules/notifications/get-with-password', (req, res) ->
		if (req.param 'password') isnt app.config.notifications.readPassword
			res.json errors: ['incorrect password']
		else
			Notification.getLastUnread (err, notifications) ->
				res.json
					errors: if err then [err] else []
					notifications: notifications

	app.post '/modules/notifications/mark-all-as-read', (ensureLoggedIn app.config.rootPath), (req, res) ->
		Notification.markAllAsRead (err) ->
			res.json errors: if err then [err] else []

	app.post '/modules/notifications/mark-read', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'id', 'invalid notification id').isInt()
		(req.assert 'read', 'invalid read integer (1 or 0, please)').isInt().min(0).max(1)
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			Notification.markRead (req.param 'id'), (req.param 'read'), (err) ->
				res.json errors: if err then [err] else []

	app.get '/modules/notifications/add', (req, res) ->
		if (req.param 'password') isnt app.config.notifications.writePassword
			res.json errors: ['incorrect password']
		else
			(req.assert 'type', 'invalid type').len 1, 100
			(req.assert 'text', 'invalid text').len 1, 1000
			(req.assert 'r', 'invalid r').isInt().min(0).max 255
			(req.assert 'g', 'invalid g').isInt().min(0).max 255
			(req.assert 'b', 'invalid b').isInt().min(0).max 255
			(req.assert 'devices', 'invalid device names').len 0, 200
			errors = req.validationErrors() or []
			if errors.length
				res.json errors: errors
			else
				addNotification (req.param 'type'), (req.param 'text'), (req.param 'r'), (req.param 'g'), (req.param 'b'), (req.param 'devices'),
					(err, id) ->
						res.json
							errors: if err then [err] else []
							id: id
