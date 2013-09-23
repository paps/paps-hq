config = require __dirname + '/config'
require 'simple-errors'
express = require 'express'
expressValidator = require 'express-validator'
flash = require 'connect-flash'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
FileSessionStore = require 'connect-session-file'
db = require 'any-db'

express.application.db = db.createPool config.db[config.env],
	min: 1
	max: 5
express.application.config = config
express.application.sessionStore = new FileSessionStore
	path: __dirname + '/sessions'
	maxAge: 1000 * 60 * 60 * 24 * 45 # 45 days

app = express()

app.set 'views', __dirname + '/views'
app.set 'view engine', 'jade'

app.enable 'trust proxy'

# passport configuration
passport.use new LocalStrategy
	usernameField: 'login'
	passwordField: 'password',
	(login, password, done) ->
		if login is config.login and password is config.password
			done null,
				login: login
		else
			done null, false, message: 'invalid login or password'
passport.serializeUser (user, done) ->
	done null, user.login
passport.deserializeUser (login, done) ->
	done null,
		login: login

# unimportant stuff
app.use express.favicon()
app.use express.logger()

# static files
app.use express.static __dirname + '/public'

# session & request handling
app.use express.bodyParser()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
	secret: config.secret
	store: app.sessionStore
app.use passport.initialize()
app.use passport.session()
app.use expressValidator()
app.use flash()

# adding useful variables for the view
app.use (req, res, next) ->
	res.locals.user = req.user
	next()

# request routing
app.use app.router

# "catch all" error handler
if config.env is 'dev'
	app.use express.errorHandler
		showStack: true
		dumpExceptions: true
else
	app.use (err, req, res, next) ->
		console.log (Error.toJson err)
		res.status 500
		res.render 'error'

# route definitions
require(__dirname + '/routes/login') app
require(__dirname + '/routes/dashboard') app
require(__dirname + '/routes/modules/bank') app
require(__dirname + '/routes/modules/futureTransactions') app
require(__dirname + '/routes/modules/notifications') app
require(__dirname + '/routes/modules/session') app

# start!
app.listen config.port, () -> console.log 'listening on ' + config.port
