module.exports = (db) ->

	class Note
		constructor: (
			@id,
			@date,
			@name,
			@text
		) ->

		@selectionFields: [
			'id'
			'date'
			'name'
			'text'
		]

		@fromRow: (row) ->
			new Note(
				row.id,
				row.date,
				row.name,
				row.text
			)

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

		@getById: (id, done) ->
			db.query 'SELECT id, date, name, text FROM notes WHERE id = ?',
				[id],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount >= 1
						done null, new Note res.rows[0].id, res.rows[0].date, res.rows[0].name, res.rows[0].text
					else
						done null

		@getList: (done) ->
			db.query 'SELECT id, date, name FROM notes ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new Note row.id, row.date, row.name, null
						done null, ret

		@get: (done) ->
			db.query 'SELECT ' + Note.selectionFields.join(',') + ' FROM notes ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push Note.fromRow(row)
						done null, ret
