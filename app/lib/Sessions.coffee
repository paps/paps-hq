module.exports = (app) ->

	utils = require __dirname + '/utils'
	addNotification = (require __dirname + '/../notificators/add') app

	class Sessions
		constructor: () ->
			@notify = app.config.notifications.sessions.enabled
			@sessions = {}

		purgeOld: () =>
			toKeep = {}
			for ip, sess of @sessions
				if utils.now() - sess.lastSeen < 2 * 24 * 60 * 60 # 2 days
					toKeep[ip] = sess
			@sessions = toKeep

		activeIp: (ip) =>
			@purgeOld()
			if not @sessions[ip]
				@sessions[ip] =
					firstSeen: utils.now()
				if @notify
					addNotification 'headquarters', 'New session from ' + ip, 120, 134, 107, '*'
			@sessions[ip].lastSeen = utils.now()

		get: () =>
			for ip, sess of @sessions
				sess.timeSinceLastSeen = utils.now() - sess.lastSeen
			@sessions
