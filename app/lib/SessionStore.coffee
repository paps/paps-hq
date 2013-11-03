module.exports = (db) ->

	utils = require __dirname + '/utils'

	class SessionStore extends require('express').session.Store
		constructor: (options) ->

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
				db.query 'REPLACE INTO sessions(id, data, date) VALUES(?, ?, ?)',
					[sid, data, utils.now()],
					(err, res) ->
						if err
							if done then done err.toString()
						else
							if done then done()
			catch e
				if done then done e.toString()

		destroy: (sid, done) ->
			db.query 'DELETE FROM sessions WHERE id = ?',
				[sid],
				(err) ->
					if err
						if done then done err.toString()
					else
						if done then done()

		clear: (done) ->
			db.query 'DELETE FROM sessions',
				[],
				(err) ->
					if err
						if done then done err.toString()
					else
						if done then done()
