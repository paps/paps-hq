ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	Transaction = (require __dirname + '/../../models/Transaction') app.db

	app.get '/modules/budget/period', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'start', 'invalid start date').isInt().min 0
		(req.assert 'end', 'invalid end date').isInt().min 0
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			Transaction.getPeriod (req.param 'start'), (req.param 'end'), (err, transactions) ->
				res.json
					errors: if err then [err] else []
					transactions: transactions
