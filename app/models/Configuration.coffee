module.exports = (db) ->

	class Configuration
		constructor: (
			@ip,
			@autoRefresh,
			@openModules
		) ->

		@selectionFields: [
			'ip'
			'auto_refresh'
			'open_modules'
		]

		@fromRow: (row) ->
			new Configuration(
				row.ip,
				row.auto_refresh,
				row.open_modules
			)

		@replaceInto: (ip, autoRefresh, openModules, done) ->
			db.query 'REPLACE INTO configurations(ip, auto_refresh, open_modules) VALUES(?, ?, ?)',
				[ip, (if autoRefresh then 1 else null), openModules],
				(err) -> if err then done err.toString() else done null

		@getByIp: (ip, done) ->
			db.query 'SELECT ' + Configuration.selectionFields.join(',') + ' FROM configurations WHERE ip = ?',
				[ip],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount >= 1
						done null, Configuration.fromRow(res.rows[0])
					else
						done null
