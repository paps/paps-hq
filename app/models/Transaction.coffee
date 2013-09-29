module.exports = (db) ->

	class Transaction
		constructor: (@id, @amount, @description, @date, @balance, @considerMatched, @md5sum) ->

		@insert: (amount, description, date, balance, considerMatched, md5sum, done) ->
			db.query 'INSERT INTO transactions(amount, description, date, balance, consider_matched, md5sum) VALUES(?, ?, ?, ?, ?, ?)',
				[amount, description, date, balance, (if considerMatched then 1 else null), md5sum],
				(err) -> if err then done err.toString() else done null

		@considerMatched: (transaction, considerMatched, done) ->
			db.query 'UPDATE transactions SET consider_matched = ? WHERE id = ?',
				[(if considerMatched then 1 else null), (if (typeof transaction) is 'object' then transaction.id else transaction)],
				(err) -> if err then done err.toString() else done null

		@updateBalance: (transaction, balance, done) ->
			db.query 'UPDATE transactions SET balance = ? WHERE id = ?',
				[balance, (if (typeof transaction) is 'object' then transaction.id else transaction)],
				(err) -> if err then done err.toString() else done null

		@getByMd5Sum: (md5sum, done) ->
			db.query 'SELECT id, amount, description, date, balance, consider_matched, md5sum FROM transactions WHERE md5sum = ? ORDER BY date DESC, balance',
				[md5sum],
				(err, res) ->
					if err
						done err.toString()
					else if res.rowCount >= 1
						done null, new Transaction res.rows[0].id, res.rows[0].amount, res.rows[0].description, res.rows[0].date, res.rows[0].balance, res.rows[0].consider_matched, res.rows[0].md5sum
					else
						done null, null

		@getUnmatched: (done) ->
			db.query 'SELECT id, amount, description, date, balance, consider_matched, md5sum FROM transactions WHERE consider_matched IS NULL AND id NOT IN (SELECT transaction_id FROM future_transactions WHERE transaction_id >= 1) ORDER BY date DESC, balance', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new Transaction row.id, row.amount, row.description, row.date, row.balance, row.consider_matched, row.md5sum
						done null, ret

		@getLastMatched: (done) ->
			db.query 'SELECT t.id AS tId, t.amount AS tAmount, t.description AS tDescription, t.date AS tDate, t.balance AS tBalance, t.consider_matched AS tConsiderMatched, t.md5sum AS tMd5sum, ft.id AS ftId, ft.amount AS ftAmount, ft.description AS ftDescription, ft.date AS ftDate, ft.tag AS ftTag FROM transactions AS t, future_transactions AS ft WHERE (ft.transaction_id = t.id OR t.consider_matched >= 1) AND strftime(\'%s\', \'now\') - t.date <= 60 * 60 * 24 * 30 GROUP BY t.id ORDER BY t.date DESC, t.balance', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							t = new Transaction row.tId, row.tAmount, row.tDescription, row.tDate, row.tBalance, row.tConsiderMatched, row.tMd5sum
							if not t.considerMatched
								t.futureTransaction =
									id: row.ftId
									amount: row.ftAmount
									description: row.ftDescription
									date: row.ftDate
									tag: row.ftTag
							ret.push t
						done null, ret

		@getPeriod: (start, end, done) ->
			db.query 'SELECT t.id AS tId, t.amount AS tAmount, t.description AS tDescription, t.date AS tDate, t.balance AS tBalance, t.consider_matched AS tConsiderMatched, t.md5sum AS tMd5sum, ft.id AS ftId, ft.amount AS ftAmount, ft.description AS ftDescription, ft.date AS ftDate, ft.tag AS ftTag FROM transactions AS t, future_transactions AS ft WHERE (ft.transaction_id = t.id OR t.consider_matched >= 1) AND t.date >= ? and t.date < ? GROUP BY t.id ORDER BY t.date',
				[start, end],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							t = new Transaction row.tId, row.tAmount, row.tDescription, row.tDate, row.tBalance, row.tConsiderMatched, row.tMd5sum
							if not t.considerMatched
								t.futureTransaction =
									id: row.ftId
									amount: row.ftAmount
									description: row.ftDescription
									date: row.ftDate
									tag: row.ftTag
							ret.push t
						done null, ret
