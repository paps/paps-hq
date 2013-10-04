module.exports = (db) ->

	class Note
		constructor: (@id, @date, @name, @text) ->

		@insert: (name, text, done) ->
			db.query 'INSERT INTO notes(name, text, date) VALUES(?, ?, strftime(\'%s\',\'now\'))',
				[name, text],
				(err) -> if err then done err.toString() else done null

		@update: (note, done) ->
			db.query 'UPDATE notes SET name = ?, text = ?, date = strftime(\'%s\',\'now\') WHERE id = ?',
				[note.name, note.text, note.id],
				(err) -> if err then done err.toString() else done null

		@delete: (note, done) ->
			db.query 'DELETE FROM notes WHERE id = ?',
				[(if (typeof note) is 'object' then note.id else note)],
				(err) -> if err then done err.toString() else done null

		@get: (done) ->
			db.query 'SELECT id, date, name, text FROM notes ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new Note row.id, row.date, row.name, row.text
						done null, ret
