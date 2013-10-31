module.exports = (db) ->

	class SessionStore extends require('express').session.Store
		constructor: (options) ->

		@now: () -> Math.round(Date.now() / 1000)

		get: (sid, done) ->
			db.query 'SELECT data FROM sessions WHERE id = ?',
				[sid],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount == 1
						try
							data = JSON.parse res.rows[0].data
							done null, data
						catch e
							done()
					else
						done()

		set: (sid, data, done) ->
			try
				data = JSON.stringify data
			catch e
				data = null
			if not data
				done 'no session data or stringify problem'
			else
				db.query 'REPLACE INTO sessions(id, data, date) VALUES(?, ?, ?)',
					[sid, data, SessionStore.now()],
					(err, res) ->
						if err
							done err.toString()
						else
							done()

		destroy: (sid, done) ->
			db.query 'DELETE FROM sessions WHERE id = ?',
				[sid],
				(err) ->
					if err
						done err.toString()
					else
						done()

		clear: (done) ->
			db.query 'DELETE FROM sessions',
				[],
				(err) ->
					if err
						done err.toString()
					else
						done()
