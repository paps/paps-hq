module.exports = (db) ->

	class FutureTransaction
		constructor: (
			@id,
			@amount,
			@description,
			@date,
			@tag,
			@transactionId,
			@doNotMatch
		) ->

		@selectionFields: [
			'id'
			'amount'
			'description'
			'date'
			'tag'
			'transaction_id'
			'do_not_match'
		]

		@fromRow: (row) ->
			new FutureTransaction(
				row.id,
				row.amount,
				row.description,
				row.date,
				row.tag,
				row.transaction_id,
				row.do_not_match
			)

		@insert: (amount, description, date, tag, doNotMatch, done) ->
			db.query 'INSERT INTO future_transactions(amount, description, date, tag, do_not_match) VALUES(?, ?, ?, ?, ?)',
				[amount, description, date, tag, (if doNotMatch then 1 else null)],
				(err) -> if err then done err.toString() else done null

		@update: (futureTransaction, done) ->
			db.query 'UPDATE future_transactions SET amount = ?, description = ?, date = ?, tag = ?, do_not_match = ? WHERE id = ?',
				[futureTransaction.amount, futureTransaction.description, futureTransaction.date, futureTransaction.tag, (if futureTransaction.doNotMatch then 1 else null), futureTransaction.id],
				(err) -> if err then done err.toString() else done null

		@delete: (futureTransaction, done) ->
			db.query 'DELETE FROM future_transactions WHERE id = ?',
				[(if (typeof futureTransaction) is 'object' then futureTransaction.id else futureTransaction)],
				(err) -> if err then done err.toString() else done null

		@setTransaction: (transaction, futureTransaction, done) ->
			db.query 'UPDATE future_transactions SET transaction_id = ? WHERE id = ? AND do_not_match IS NULL',
				[(if (typeof transaction) is 'object' then transaction.id else transaction),
				(if (typeof futureTransaction) is 'object' then futureTransaction.id else futureTransaction)],
				(err) -> if err then done err.toString() else done null

		@unmatch: (transaction, done) ->
			db.query 'UPDATE future_transactions SET transaction_id = NULL WHERE transaction_id = ?',
				[(if (typeof transaction) is 'object' then transaction.id else transaction)],
				(err) -> if err then done err.toString() else done null

		@getUnmatched: (done) ->
			db.query 'SELECT ' + FutureTransaction.selectionFields.join(',') + ' FROM future_transactions WHERE transaction_id IS NULL ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push FutureTransaction.fromRow(row)
						done null, ret

		@getLast: (done) ->
			db.query 'SELECT ' + FutureTransaction.selectionFields.join(',') + ' FROM future_transactions WHERE transaction_id IS NULL OR strftime(\'%s\', \'now\') - date <= 60 * 60 * 24 * 30 ORDER BY transaction_id IS NOT NULL, do_not_match IS NOT NULL DESC, date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push FutureTransaction.fromRow(row)
						done null, ret

