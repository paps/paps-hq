crypto = require 'crypto'
request = require 'request'

module.exports = (app) ->

	Notification = (require __dirname + '/models/Notification') app.db

	class NotificationManager
		@add: (type, text, r, g, b, devices, done) ->
			if devices is '*'
				NotificationManager.pushover type, text
			else if (typeof devices) is 'string'
				for category in devices.split ','
					if app.config.notifications.pushover.devices[category]
						NotificationManager.pushover type, text, app.config.notifications.pushover.devices[category]
			md5sum = '' + type + text + r + g + b
			md5sum = crypto.createHash('md5').update(md5sum).digest("hex")
			Notification.getByMd5Sum md5sum, (err, notification) ->
				if err
					done err
				else
					if notification
						console.log 'Incrementing counter for notification ' + notification.md5sum + '.'
						Notification.incrementCounter notification, done
					else
						console.log 'Adding new notification ' + md5sum + '.'
						Notification.insert type, text, r, g, b, md5sum, done

		@pushover: (type, text, device) ->
			data =
				token: app.config.notifications.pushover.token
				user: app.config.notifications.pushover.user
				message: text
				title: '[' + type + '] Notification from HQ'
			if device then data.device = device
			request
				url: 'https://api.pushover.net/1/messages.json'
				method: 'POST'
				form: data,
				(err, res, body) ->
					console.log 'Notification sent to pushover, ' + (if err then ('http error: ' + err) else 'no http error') + ', response: ' + body
