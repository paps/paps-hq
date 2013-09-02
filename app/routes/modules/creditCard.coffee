ensureLoggedIn = require('connect-ensure-login').ensureLoggedIn

module.exports = (app) ->

	CreditCardRecord = (require __dirname + '/../../models/CreditCardRecord') app.db

	app.get '/modules/credit-card/records', (ensureLoggedIn '/'), (req, res) ->
		CreditCardRecord.getLast (err, records) ->
			res.json
				errors: if err then [err] else []
				records: records

	app.post '/modules/credit-card/record/add', (ensureLoggedIn '/'), (req, res) ->
		(req.assert 'amount', 'invalid amount').isDecimal().min 0.01
		(req.assert 'date', 'invalid date').isInt()
		(req.assert 'description', 'invalid description').len 0, 200
		errors = req.validationErrors() or []
		if typeof (req.param 'tags') isnt 'string'
			errors.push 'no tags'
		else
			tags = (req.param 'tags').split ','
			for tag in tags
				if tag isnt tag.trim() or tag.length < 1 or tag.length > 50
					errors.push 'invalid tag "' + tag + '"'
					break
		if errors.length
			res.json errors: errors
		else
			CreditCardRecord.create (req.param 'amount'), (req.param 'description'), (req.param 'date'), no, (req.param 'tags'), (err) ->
				res.json errors: if err then [err] else []
