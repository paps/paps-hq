request = require 'request'
parseXml = require('xml2js').parseString

# TODO enlever
util = require 'util'

module.exports = (app) ->

	addNotification = (require __dirname + '/add') app

	class GmailChecker
		constructor: () ->
			@cfg = app.config.notifications.gmail

		checkLater: () =>
			setTimeout (() => @check()), @cfg.checkInterval * 1000

		check: () =>
			request
				url: 'https://mail.google.com/mail/feed/atom/'
				auth:
					user: @cfg.email
					pass: @cfg.password
					sendImmediately: yes,
				(err, res, body) =>
					if err
						addNotification 'email', 'Could not check Gmail: ' + err, 255, 53, 94
					else
						parseXml body, (err, res) ->
							if err
								console.log err
							else
								console.log util.inspect res, null, 10
