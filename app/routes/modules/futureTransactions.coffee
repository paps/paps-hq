ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	FutureTransaction = (require __dirname + '/../../models/FutureTransaction') app.db

	app.get '/modules/future-transactions/transactions', (ensureLoggedIn app.config.rootPath), (req, res) ->
		FutureTransaction.getLast (err, transactions) ->
			res.json
				errors: if err then [err] else []
				transactions: transactions

	app.get '/modules/future-transactions/unmatched', (ensureLoggedIn app.config.rootPath), (req, res) ->
		FutureTransaction.getUnmatched (err, transactions) ->
			res.json
				errors: if err then [err] else []
				transactions: transactions

	app.post '/modules/future-transactions/transaction/add-or-edit', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'amount', 'invalid amount').isDecimal()
		(req.assert 'date', 'invalid date').isInt()
		(req.assert 'doNotMatch', 'invalid DNM flag').isInt()
		(req.assert 'tag', 'invalid tag').len 1, 100
		(req.assert 'description', 'invalid description').len 0, 200
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			id = parseInt (req.param 'id')
			dnm = parseInt (req.param 'doNotMatch')
			if id
				FutureTransaction.update
					id: id
					amount: (req.param 'amount')
					description: (req.param 'description')
					date: (req.param 'date')
					tag: (req.param 'tag')
					doNotMatch: dnm,
					(err) -> res.json errors: if err then [err] else []
			else
				FutureTransaction.insert (req.param 'amount'), (req.param 'description'), (req.param 'date'), (req.param 'tag'), dnm,
					(err) -> res.json errors: if err then [err] else []

	app.post '/modules/future-transactions/transaction/del', (ensureLoggedIn app.config.rootPath), (req, res) ->
		(req.assert 'id', 'invalid id').isInt()
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			FutureTransaction.delete (req.param 'id'), (err) -> res.json errors: if err then [err] else []
