ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	FutureTransaction = (require __dirname + '/../../models/FutureTransaction') app.db

	app.get '/modules/future-transactions/transactions', (ensureLoggedIn '/'), (req, res) ->
		FutureTransaction.getLast (err, transactions) ->
			res.json
				errors: if err then [err] else []
				transactions: transactions

	app.post '/modules/future-transactions/transaction/add-or-edit', (ensureLoggedIn '/'), (req, res) ->
		(req.assert 'amount', 'invalid amount').isDecimal()
		(req.assert 'date', 'invalid date').isInt()
		(req.assert 'description', 'invalid description').len 0, 200
		errors = req.validationErrors() or []
		if typeof (req.param 'tags') isnt 'string'
			errors.push 'no tags'
		else
			tags = (req.param 'tags').split ','
			for tag in tags
				if tag isnt tag.trim() or tag.length < 1 or tag.length > 50
					errors.push 'invalid tag "' + tag + '"'
					break
		if errors.length
			res.json errors: errors
		else
			id = parseInt (req.param 'id')
			if id
				FutureTransaction.update
					id: id
					amount: (req.param 'amount')
					description: (req.param 'description')
					date: (req.param 'date')
					tags: (req.param 'tags'),
					(err) -> res.json errors: if err then [err] else []
			else
				FutureTransaction.insert (req.param 'amount'), (req.param 'description'), (req.param 'date'), (req.param 'tags'),
					(err) -> res.json errors: if err then [err] else []

	app.post '/modules/future-transactions/transaction/del', (ensureLoggedIn '/'), (req, res) ->
		(req.assert 'id', 'invalid id').isInt()
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			FutureTransaction.delete (req.param 'id'), (err) -> res.json errors: if err then [err] else []
