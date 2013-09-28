module.exports = (app) ->

	addNotification = (require __dirname + '/notificators/add') app

	if app.config.notifyOnStart
		setTimeout (() -> addNotification 'headquarters', 'Headquarters started', 144, 0, 163, '*'), 2000

	if app.config.notifications.reddit.enabled
		RedditChecker = (require __dirname + '/notificators/RedditChecker') app
		redditChecker = new RedditChecker
		setTimeout (() -> redditChecker.login()), app.config.notifications.reddit.startAfter * 1000
