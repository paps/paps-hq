crypto = require 'crypto'
async = require 'async'

module.exports = (app) ->

	Notification = (require __dirname + '/../models/Notification') app.db
	pushover = (require __dirname + '/pushover') app

	add = (type, text, r, g, b, devices, done) ->
		if devices is '*'
			pushover add, type, text, r, g, b
		else if devices is '!'
			pushover add, type, text, r, g, b, null, yes
		else if (typeof devices) is 'string'
			realDevices = []
			for category in devices.split ','
				d = app.config.notifications.pushover.devices[category]
				if d and not (d in realDevices)
					realDevices.push d
			if realDevices.length is Object.keys(app.config.notifications.pushover.devices).length
				pushover add, type, text, r, g, b
			else
				for d in realDevices
					pushover add, type, text, r, g, b, d
		md5sum = type + '_' + text + '_' + r + '_' + g + '_' + b
		md5sum = crypto.createHash('md5').update(md5sum).digest("hex")
		dbError = null
		notificationId = null
		tries = 0
		addToDb = (done) ->
			++tries
			Notification.getByMd5Sum md5sum, (err, notification) ->
				if err
					dbError = err
					done()
				else
					if notification
						console.log 'Incrementing counter for notification "' + notification.text + '" (try ' + tries + ').'
						Notification.incrementCounter notification, (err, id) ->
							if err
								dbError = err
							else
								dbError = null
								notificationId = id
							done()
					else
						console.log 'Adding new notification "' + text + '" (try ' + tries + ').'
						Notification.insert type, text, r, g, b, md5sum, (err, id) ->
							if err
								dbError = err
							else
								dbError = null
								notificationId = id
							done()
		async.doWhilst addToDb, (() -> dbError isnt null and tries < app.config.notifications.tries), () ->
			if done
				done dbError, notificationId
