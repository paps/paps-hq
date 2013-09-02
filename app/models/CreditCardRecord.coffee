module.exports = (db) ->

	class CreditCardRecord
		constructor: (@id, @amount, @description, @date, @tags) ->

		@create: (amount, description, date, tags, done) ->
			db.query 'INSERT INTO credit_card_records(amount, description, date, tags) VALUES(?, ?, ?, ?, ?)',
				[amount, description, date, tags],
				(err) -> if err then done err.toString() else done null

		@update: (creditCardRecord, done) ->
			db.query 'UPDATE credit_card_records SET amount = ?, description = ?, date = ?, tags = ? WHERE id = ?',
				[creditCardRecord.amount, creditCardRecord.description, creditCardRecord.date, creditCardRecord.tags, creditCardRecord.id],
				(err) -> if err then done err.toString() else done null

		@getById: (id, done) ->
			db.query 'SELECT id, amount, description, date, tags FROM credit_card_records WHERE id = ?', [id],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount is 1
						done null, new CreditCardRecord res.rows[0].id, res.rows[0].amount, res.rows[0].description, res.rows[0].date, res.rows[0].tags

		@getLast: (done) ->
			db.query 'SELECT id, amount, description, date, tags FROM credit_card_records ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new CreditCardRecord row.id, row.amount, row.description, row.date, row.tags
						done null, ret

