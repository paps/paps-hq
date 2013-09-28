crypto = require 'crypto'

module.exports = (app) ->

	Notification = (require __dirname + '/../models/Notification') app.db
	pushover = (require __dirname + '/pushover') app

	(type, text, r, g, b, devices, done) ->
		if devices is '*'
			pushover type, text, r, g, b
		else if (typeof devices) is 'string'
			realDevices = []
			for category in devices.split ','
				d = app.config.notifications.pushover.devices[category]
				if d and not d in realDevices
					realDevices.push d
			if realDevices.length is Object.keys(app.config.notifications.pushover.devices).length
				pushover type, text, r, g, b
			else
				for d in realDevices
					pushover type, text, r, g, b, d
		md5sum = type + '_' + text + '_' + r + '_' + g + '_' + b
		md5sum = crypto.createHash('md5').update(md5sum).digest("hex")
		Notification.getByMd5Sum md5sum, (err, notification) ->
			if err
				if done then done err
			else
				if notification
					console.log 'Incrementing counter for notification ' + notification.md5sum + '.'
					Notification.incrementCounter notification, (if done then done else (() -> ))
				else
					console.log 'Adding new notification ' + md5sum + '.'
					Notification.insert type, text, r, g, b, md5sum, (if done then done else (() -> ))
