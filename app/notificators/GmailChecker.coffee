request = require 'request'
parseXml = (require 'xml2js').parseString
async = require 'async'
_ = require 'underscore'

util = require 'util'

module.exports = (app) ->

	addNotification = (require __dirname + '/add') app
	Notification = (require __dirname + '/../models/Notification') app.db

	class GmailChecker
		constructor: () ->
			@cfg = app.config.notifications.gmail
			@oldMail = []

		checkLater: () =>
			setTimeout (() => @check()), @cfg.checkInterval * 1000

		check: () =>
			request
				url: 'https://mail.google.com/mail/feed/atom/'
				auth:
					user: @cfg.email
					pass: @cfg.password
					sendImmediately: yes, # no HTTP 401 needed here
				(err, res, body) =>
					if err
						addNotification 'email', 'Could not check Gmail: ' + err, 255, 53, 94
						@checkLater()
					else
						parseXml body, (err, res) =>
							if err
								addNotification 'email', 'Could not parse Gmail atom feed: ' + err, 255, 53, 94
								@checkLater()
							else
								console.log 'oldMail WAS: ' + (util.inspect @oldMail)
								newMail = []
								oldMailIterator = (mail, done) =>
									if (_.find res.feed.entry, (entry) => (typeof entry.title[0]) is 'string' and entry.title[0] is mail.title[0])
										newMail.push mail
										done()
									else if mail.notificationId
										Notification.markRead mail.notificationId, 1, (() => done())
									else
										done()
								async.eachSeries @oldMail, oldMailIterator, () =>
									@oldMail = newMail
									feedIterator = (entry, done) =>
										if (_.find @oldMail, (mail) => (typeof entry.title[0]) is 'string' and mail.title[0] is entry.title[0])
											done()
										else
											addNotification 'email', entry.author[0]?.name[0] + ': ' + entry.title[0], 0, 128, 128, null, (err, id) =>
												if not err
													entry.notificationId = id
													@oldMail.push entry
												done()
									async.eachSeries res.feed.entry, feedIterator, () =>
										@checkLater()
										console.log 'oldMail IS NOW: ' + (util.inspect @oldMail)
