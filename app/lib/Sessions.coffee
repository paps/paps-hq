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
				if utils.now() - sess.lastSeen < 7 * 24 * 60 * 60
					toKeep[ip] = sess
			@sessions = toKeep

		activeIp: (ip) =>
			@purgeOld()
			if not @sessions[ip]
				@sessions[ip] =
					firstSeen: utils.now()
				if @notify
					; # TODO
			@sessions[ip].lastSeen = utils.now()

		get: () =>
			for ip, sess of @sessions
				sess.timeSinceLastSeen = utils.now() - sess.lastSeen
			@sessions
