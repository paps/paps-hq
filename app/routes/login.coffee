passport = require 'passport'

module.exports = (app) ->

	app.get '/', (req, res) ->
		if req.user
			res.redirect '/dashboard'
		else
			if req.session.returnTo
				req.flash 'error', 'you must be logged in to view this page'
			res.render 'login',
				title: 'Login'
				errors: req.flash 'error'
				infos: req.flash 'info'

	app.post '/login', passport.authenticate 'local',
		successReturnToOrRedirect: '/dashboard'
		failureRedirect: '/'
		failureFlash: true

	app.get '/logout', (req, res) ->
		req.logout()
		req.flash 'info', 'you have logged out'
		res.redirect '/'
