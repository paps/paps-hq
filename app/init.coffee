module.exports = (app) ->

	if app.config.notifyOnStart
		addNotification = (require __dirname + '/notificators/add') app
		setTimeout (() -> addNotification 'headquarters', 'Headquarters started', 144, 0, 163, '*'), 2000

	if app.config.notifications.reddit.enabled
		RedditChecker = (require __dirname + '/notificators/RedditChecker') app
		redditChecker = new RedditChecker
		redditChecker.checkLater()

	Mining = (require __dirname + '/lib/Mining') app
	app.hq.mining = new Mining
	app.hq.mining.checkLater()
