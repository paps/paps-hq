module.exports = (db) ->

	class Configuration
		constructor: (@ip, @autoRefresh, @openModules) ->

		@replaceInto: (ip, autoRefresh, openModules, done) ->
			db.query 'REPLACE INTO configurations(ip, auto_refresh, open_modules) VALUES(?, ?, ?)',
				[ip, (if autoRefresh then 1 else null), openModules],
				(err) -> if err then done err.toString() else done null

		@getByIp: (ip, done) ->
			db.query 'SELECT ip, auto_refresh, open_modules FROM configurations WHERE ip = ?',
				[ip],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount >= 1
						done null, new Configuration res.rows[0].ip, res.rows[0].auto_refresh, res.rows[0].open_modules
					else
						done null
