module.exports = (db) ->

	class FutureTransaction
		constructor: (@id, @amount, @description, @date, @tags) ->

		@insert: (amount, description, date, tags, done) ->
			db.query 'INSERT INTO future_transactions(amount, description, date, tags) VALUES(?, ?, ?, ?)',
				[amount, description, date, tags],
				(err) -> if err then done err.toString() else done null

		@update: (futureTransaction, done) ->
			db.query 'UPDATE future_transactions SET amount = ?, description = ?, date = ?, tags = ? WHERE id = ?',
				[futureTransaction.amount, futureTransaction.description, futureTransaction.date, futureTransaction.tags, futureTransaction.id],
				(err) -> if err then done err.toString() else done null

		@delete: (futureTransaction, done) ->
			db.query 'DELETE FROM future_transactions WHERE id = ?',
				[(if (typeof futureTransaction) is 'object' then futureTransaction.id else futureTransaction)],
				(err) -> if err then done err.toString() else done null

		@setTransaction: (futureTransaction, transaction, done) ->
			db.query 'UPDATE future_transactions SET transaction_id = ? WHERE id = ?',
				[(if (typeof futureTransaction) is 'object' then futureTransaction.id else futureTransaction),
				(if (typeof transaction) is 'object' then transaction.id else transaction)],
				(err) -> if err then done err.toString() else done null

		@getById: (id, done) ->
			db.query 'SELECT id, amount, description, date, tags FROM future_transactions WHERE id = ?', [id],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount is 1
						done null, new FutureTransaction res.rows[0].id, res.rows[0].amount, res.rows[0].description, res.rows[0].date, res.rows[0].tags

		@getLast: (done) ->
			db.query 'SELECT id, amount, description, date, tags FROM future_transactions ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new FutureTransaction row.id, row.amount, row.description, row.date, row.tags
						done null, ret

