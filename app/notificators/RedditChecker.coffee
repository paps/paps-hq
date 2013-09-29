request = require 'request'

module.exports = (app) ->

	addNotification = (require __dirname + '/add') app

	class RedditChecker
		constructor: () ->
			@cfg = app.config.notifications.reddit
			@jar = request.jar()
			@hasMail = no

		checkLater: () =>
			setTimeout (() => @login), @cfg.checkInterval * 1000

		login: () =>
			console.log 'Checking reddit account ' + @cfg.user + '...'
			request
				url: 'https://ssl.reddit.com/api/login'
				method: 'POST'
				headers:
					'User-Agent': @cfg.userAgent
				form:
					api_type: 'json'
					user: @cfg.user
					passwd: @cfg.password
					rem: no
				jar: @jar,
				(err, res, body) =>
					if err
						addNotification 'reddit', 'Login request error: ' + err, 200, 80, 80, '*'
						@checkLater()
					else
						if (body.indexOf 'cookie') >= 0 # high quality parsing
							@checkMail()
						else
							addNotification 'reddit', 'Login error: ' + body, 200, 80, 80, '*'
							@checkLater()

		checkMail: () =>
			request
				url: 'https://ssl.reddit.com/api/me.json'
				method: 'GET'
				headers:
					'User-Agent': @cfg.userAgent
				jar: @jar,
				(err, res, body) =>
					if err
						addNotification 'reddit', 'Mail status request error: ' + err, 200, 80, 80, '*'
					else
						try
							body = JSON.parse body
							if body.data.has_mail and not @hasMail
								addNotification 'reddit', 'New reddit mail', 143, 210, 255, '*'
							else if not body.data.has_mail and @hasMail
								# todo remove notification by id
								;
							@hasMail = body.data.has_mail
						catch e
							addNotification 'reddit', 'Exception while parsing mail status response: ' + e, 200, 80, 80, '*'
					@checkLater()
