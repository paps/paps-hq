ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn
crypto = require 'crypto'
async = require 'async'

module.exports = (app) ->

	Transaction = (require __dirname + '/../../models/Transaction') app.db
	FutureTransaction = (require __dirname + '/../../models/FutureTransaction') app.db

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

	app.post '/modules/bank/unmatch', (ensureLoggedIn '/'), (req, res) ->
		(req.assert 'id', 'invalid transaction id').isInt()
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			FutureTransaction.unmatch (req.param 'id'), (err) ->
				res.json errors: if err then [err] else []

	app.post '/modules/bank/match', (ensureLoggedIn '/'), (req, res) ->
		(req.assert 'id', 'invalid transaction id').isInt()
		(req.assert 'futureTransactionId', 'invalid future transaction id').isInt()
		errors = req.validationErrors() or []
		if errors.length
			res.json errors: errors
		else
			id = parseInt req.param 'id'
			futureId = parseInt req.param 'futureTransactionId'
			if futureId is -1
				Transaction.considerMatched id, yes, (err) ->
					res.json errors: if err then [err] else []
			else if futureId is 0
				Transaction.considerMatched id, no, (err) ->
					if err
						res.json errors: [err]
					else
						FutureTransaction.unmatch id, (err) ->
							res.json errors: if err then [err] else []
			else
				Transaction.considerMatched id, no, (err) ->
					if err
						res.json errors: [err]
					else
						FutureTransaction.setTransaction id, futureId, (err) ->
							res.json errors: if err then [err] else []

	matchAll = (done) ->
		Transaction.getUnmatched (err, transactions) ->
			if err
				done err
			else
				FutureTransaction.getUnmatched (err, futureTransactions) ->
					if err
						done err
					else
						nbMatched = 0
						iterator = (tr, done) ->
							minOffset = 2114380800
							match = null
							for ftr in futureTransactions
								if tr.amount is ftr.amount and not ftr.doNotMatch and not ftr.alreadyMatched
									offset = Math.abs tr.date - ftr.date
									if offset < minOffset
										minOffset = offset
										match = ftr
							if match
								match.alreadyMatched = yes
								FutureTransaction.setTransaction tr, match, (err) ->
									if err
										done err
									else
										++nbMatched
										done null
							else
								done null
						async.eachSeries transactions, iterator, (err) ->
							if err
								done err
							else
								done null, nbMatched, transactions.length - nbMatched

	app.get '/modules/bank/match-all', (ensureLoggedIn '/'), (req, res) ->
		matchAll (err, matched, unmatched) ->
			if err
				res.json errors: if err then [err] else []
			else
				res.json
					errors: []
					matched: matched
					unmatched: unmatched

	NotificationManager = (require __dirname + '/../../NotificationManager') app

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
			nbAdded = 0
			iterator = (t, done) ->
				md5sum = '' + t.amount + t.description + t.date + t.balance
				md5sum = crypto.createHash('md5').update(md5sum).digest("hex")
				Transaction.transactionExists md5sum, (err, exists) ->
					if err
						done err
					else if exists
						done null
						console.log 'Transaction ' + md5sum + ' already in database.'
					else
						console.log 'Transaction ' + md5sum + ' not in database, inserting.'
						Transaction.insert t.amount, t.description, t.date, t.balance, no, md5sum, (err) ->
							if err
								done err
							else
								++nbAdded
								done null
			async.eachSeries transactions, iterator, (err) ->
				if err
					NotificationManager.add 'bank', 'When adding transactions: ' + err, 255, 100, 12, '*', (err) ->
				else
					matchAll (err, nbMatched, nbUnmatched) ->
						if err
							NotificationManager.add 'bank', 'When matching transactions: ' + err, 255, 100, 12, '*', (err) ->
						else if nbMatched > 0 or nbAdded > 0
							NotificationManager.add 'bank', nbAdded + ' transaction' + (if nbAdded > 1 then 's' else '') + ' added, ' + nbMatched + ' matched, ' + nbUnmatched + ' left unmatched', 50, 230, 12, '*', (err) ->
				res.json errors: if err then [err] else []
