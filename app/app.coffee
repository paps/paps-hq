config = require __dirname + '/config'
require 'simple-errors'
express = require 'express'
expressValidator = require 'express-validator'
flash = require 'connect-flash'
passport = require 'passport'
LocalStrategy = require('passport-local').Strategy
db = require 'any-db'

express.application.db = db.createPool config.db,
	min: 10
	max: 10
SessionStore = (require __dirname + '/lib/SessionStore') express.application.db
express.application.config = config
express.application.hq = {}

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

# static files
app.use express.static __dirname + '/public'

# session & request handling
app.use express.logger()
app.use express.json()
app.use express.urlencoded()
app.use express.methodOverride()
app.use express.cookieParser()
app.use express.session
	secret: config.secret
	store: new SessionStore
	cookie:
		path: '/'
		httpOnly: yes
		maxAge: 1000 * 60 * 60 * config.sessionDuration
		secure: config.secureCookie
app.use passport.initialize()
app.use passport.session()
app.use expressValidator()
app.use flash()

# adding useful variables for the view
app.use (req, res, next) ->
	res.locals.user = req.user
	res.locals.rootPath = config.rootPath
	if req.user and app.hq.sessions
		app.hq.sessions.activeIp req.ip
	next()

# request routing
app.use app.router

# "catch all" error handler
app.use express.errorHandler
	showStack: true
	dumpExceptions: true

# route definitions
(require __dirname + '/routes/login') app
(require __dirname + '/routes/dashboard') app
(require __dirname + '/routes/modules/bank') app
(require __dirname + '/routes/modules/futureTransactions') app
(require __dirname + '/routes/modules/notifications') app
(require __dirname + '/routes/modules/session') app
(require __dirname + '/routes/modules/budget') app
(require __dirname + '/routes/modules/notes') app
(require __dirname + '/routes/modules/mining') app
(require __dirname + '/routes/modules/wallets') app
(require __dirname + '/routes/modules/machines') app
(require __dirname + '/routes/modules/btcChina') app

# launch other stuff
(require __dirname + '/init') app

# start!
app.listen config.port, 'localhost', () -> console.log 'listening on ' + config.port
