module.exports = (app) ->

	if app.config.notifyOnStart
		addNotification = (require __dirname + '/notificators/add') app
		setTimeout (() -> addNotification 'headquarters', 'Headquarters (re)started', 144, 0, 163, '*'), 2000

	if app.config.notifications.reddit.enabled
		RedditChecker = (require __dirname + '/notificators/RedditChecker') app
		redditChecker = new RedditChecker
		redditChecker.checkLater()

	if app.config.notifications.gmail.enabled
		GmailChecker = (require __dirname + '/notificators/GmailChecker') app
		gmailChecker = new GmailChecker
		gmailChecker.checkLater()

	Mining = (require __dirname + '/lib/Mining') app
	app.hq.mining = new Mining
	app.hq.mining.checkLater()

	Wallets = (require __dirname + '/lib/Wallets') app
	app.hq.wallets = new Wallets
	if app.config.wallets.enabled
		app.hq.wallets.checkLater app.config.wallets.firstCheck

	Sessions = (require __dirname + '/lib/Sessions') app
	app.hq.sessions = new Sessions

	Machines = (require __dirname + '/lib/Machines') app
	app.hq.machines = new Machines
	if app.config.machines.enabled
		app.hq.machines.checkLater()

	BtcChina = (require __dirname + '/lib/BtcChina') app
	app.hq.btcChina = new BtcChina
	if app.config.btcChina.enabled
		setTimeout (() ->
			app.hq.btcChina.setSource()
			app.hq.btcChina.checkLater()
		), 11000
