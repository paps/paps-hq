passport = require 'passport'
ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	app.get '/', (req, res) ->
		if req.user
			res.redirect app.config.rootPath + 'dashboard'
		else
			if req.session.returnTo
				req.flash 'error', 'you must be logged in to view this page'
			res.render 'login',
				title: 'Login'
				errors: req.flash 'error'
				infos: req.flash 'info'

	app.post '/login', passport.authenticate 'local',
		successRedirect: app.config.rootPath + 'dashboard'
		failureRedirect: app.config.rootPath
		failureFlash: true

	app.get '/logout', (ensureLoggedIn '/'), (req, res) ->
		req.logout()
		req.flash 'info', 'you have logged out'
		res.redirect app.config.rootPath

	app.get '/logout-all', (ensureLoggedIn '/'), (req, res) ->
		req.logout()
		req.flash 'info', 'you have logged out and all sessions were deleted'
		res.redirect app.config.rootPath
		setTimeout (() -> req.sessionStore.clear()), 1000
