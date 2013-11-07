module.exports = (app) ->

	utils = require __dirname + '/utils'
	addNotification = (require __dirname + '/../notificators/add') app

	class Sessions
		constructor: () ->
			@notify = app.config.notifications.sessions.enabled
			@knownIps = app.config.notifications.sessions.knownIps
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
				if @knownIps[ip]
					@sessions[ip].name = @knownIps[ip]
				if @notify
					msg = 'New session from ' + ip + ' ('
					if @knownIps[ip]
						msg += @knownIps[ip]
					else
						msg += 'unknown'
					msg += ')'
					addNotification 'headquarters', msg, 120, 134, 107, '*'
			@sessions[ip].lastSeen = utils.now()

		get: () =>
			for ip, sess of @sessions
				sess.timeSinceLastSeen = utils.now() - sess.lastSeen
			@sessions
