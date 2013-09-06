module.exports = (db) ->

	class Transaction
		constructor: (@id, @amount, @description, @date, @balance, @md5sum) ->

		@insert: (amount, description, date, balance, md5sum, done) ->
			db.query 'INSERT INTO transactions(amount, description, date, balance, md5sum) VALUES(?, ?, ?, ?, ?)',
				[amount, description, date, balance, md5sum],
				(err) -> if err then done err.toString() else done null

		@transactionExists: (md5sum, done) ->
			db.query 'SELECT 1 FROM transactions WHERE md5sum = ?',
				[md5sum],
				(err, res) ->
					if err
						done err.toString()
					else
						done null, res.rowCount >= 1

		@getUnmatched: (done) ->
			db.query 'SELECT id, amount, description, date, balance, md5sum FROM transactions WHERE id NOT IN (SELECT transaction_id FROM future_transactions WHERE transaction_id >= 1)', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new Transaction row.id, row.amount, row.description, row.date, row.balance, row.md5sum
						done null, ret

		@getLastMatched: (done) ->
			db.query 'SELECT t.id, t.amount, t.description, t.date, t.balance, t.md5sum, ft.id, ft.amount, ft.description, ft.date, ft.tags FROM transactions AS t INNER JOIN future_transactions AS ft ON ft.transaction_id = t.id ORDER BY t.date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							t = new Transaction row['t.id'], row['t.amount'], row['t.description'], row['t.date'], row['t.balance'], row['t.md5sum']
							t.futureTransaction =
								id: row['ft.id']
								amount: row['ft.amount']
								description: row['ft.description']
								date: row['ft.date']
								tags: row['ft.tags']
							ret.push t
						done null, ret
