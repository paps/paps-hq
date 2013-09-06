ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
crypto = require 'crypto'
async = require 'async'

module.exports = (app) ->

	Transaction = (require __dirname + '/../../models/Transaction') app.db

	app.get '/modules/bank/matched-transactions', (ensureLoggedIn '/'), (req, res) ->
		Transaction.getLastMatched (err, transactions) ->
			res.json
				errors: if err then [err] else []
				transactions: transactions

	app.get '/modules/bank/unmatched-transactions', (ensureLoggedIn '/'), (req, res) ->
		Transaction.getUnmatched (err, transactions) ->
			res.json
				errors: if err then [err] else []
				transactions: transactions

	app.post '/modules/bank/add-transactions', (req, res) ->
		if (req.param 'password') isnt app.config.bank.password
			res.json errors: ['incorrect password']
		else
			try
				transactions = JSON.parse req.param 'transactions'
			catch e
				res.json errors: ['invalid transactions json']
				return
			if not Array.isArray transactions
				res.json errors: ['transactions is not an array']
				return
			iterator = (t, done) ->
				md5sum = '' + t.amount + t.description + t.date + t.balance
				md5sum = crypto.createHash('md5').update(md5sum).digest("hex")
				Transaction.transactionExists md5sum, (err, exists) ->
					if err
						done err
					else if exists
						done null
					else
						Transaction.insert t.amount, t.description, t.date, t.balance, md5sum, (err) ->
							done err
			async.eachSeries transactions, iterator, (err) ->
				res.json errors: if err then [err] else []
