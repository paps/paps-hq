module.exports = (db) ->

	class Notification
		constructor: (@id, @count, @type, @text, @r, @g, @b, @date, @read, @md5sum) ->

		@insert: (type, text, r, g, b, md5sum, done) ->
			db.query 'INSERT INTO notifications(count, type, text, r, g, b, md5sum, date) VALUES(1, ?, ?, ?, ?, ?, ?, strftime(\'%s\',\'now\'))',
				[type, text, r, g, b, md5sum],
				(err, res) -> if err then done err.toString() else done null, res.lastInsertId

		@getByMd5Sum: (md5sum, done) ->
			db.query 'SELECT id, count, type, text, r, g, b, date, read, md5sum FROM notifications WHERE md5sum = ? AND read IS NULL ORDER BY date DESC',
				[md5sum],
				(err, res) ->
					if err
						done err.toString()
					else if res?.rowCount >= 1
						done null, new Notification res.rows[0].id, res.rows[0].count, res.rows[0].type, res.rows[0].text, res.rows[0].r, res.rows[0].g, res.rows[0].b, res.rows[0].date, res.rows[0].read, res.rows[0].md5sum
					else
						done null

		@incrementCounter: (notification, done) ->
			id = if (typeof notification) is 'object' then notification.id else notification
			db.query 'UPDATE notifications SET count = count + 1, date = strftime(\'%s\',\'now\') WHERE id = ?',
				[id],
				(err) -> if err then done err.toString() else done null, id

		@markAllAsRead: (done) ->
			db.query 'UPDATE notifications SET read = 1 WHERE read IS NULL', [], (err) -> if err then done err.toString() else done null

		@markRead: (notification, read, done) ->
			db.query 'UPDATE notifications SET read = ? WHERE id = ?',
				[(if (parseInt read) then 1 else null), (if (typeof notification) is 'object' then notification.id else notification)],
				(err) -> if err then done err.toString() else done null

		@getLast: (done) ->
			db.query 'SELECT id, count, type, text, r, g, b, date, read, md5sum FROM notifications WHERE read IS NULL OR strftime(\'%s\', \'now\') - date <= 60 * 60 * 24 * 7 ORDER BY read, date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new Notification row.id, row.count, row.type, row.text, row.r, row.g, row.b, row.date, row.read, row.md5sum
						done null, ret

		@getLastUnread: (done) ->
			db.query 'SELECT id, count, type, text, r, g, b, date, read, md5sum FROM notifications WHERE read IS NULL ORDER BY date DESC', [],
				(err, res) ->
					if err
						done err.toString()
					else
						ret = []
						for row in res.rows
							ret.push new Notification row.id, row.count, row.type, row.text, row.r, row.g, row.b, row.date, row.read, row.md5sum
						done null, ret
