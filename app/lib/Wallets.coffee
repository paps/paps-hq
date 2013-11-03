async = require 'async'
request = require 'request'

module.exports = (app) ->

	utils = require __dirname + '/utils'
	addNotification = (require __dirname + '/../notificators/add') app

	class Wallets
		constructor: () ->
			@cfg = app.config.wallets
			@wallets = @cfg.list

		checkLater: (timeout) =>
			setTimeout (() => @check()), (if timeout then timeout * 1000 else @cfg.checkInterval * 1000)

		check: () =>
			currencyIterator = (currency, done) ->
				walletIterator = (wallet, done) ->
					console.log 'Checking ' + currency.currency + ' wallet ' + wallet.name + ' (' + wallet.address + ')...'
					request wallet.machineUrl, (err, res, body) ->
						if err
							wallet.error = err.toString()
						else
							amount = parseFloat body
							if amount >= 0
								amount *= wallet.multiplier
								amount += wallet.offset
								if wallet.amount
									diff = Math.abs(amount - wallet.amount)
									if diff isnt 0
										msg = currency.currency + ' wallet "' + wallet.name + '" has ' + (if diff < 0 then 'sent' else 'received') + ' '
										msg += utils.round diff, 4
										msg += ' ' + currency.symbol + ', '
										msg += 'balance is now ' + (utils.round amount, 4) + ' ' + currency.symbol
										addNotification 'wallet', msg, 113, 188, 120, '*'
								wallet.amount = amount
								wallet.error = null
							else
								wallet.error = 'request returned an invalid float'
						done()
				async.eachSeries currency.wallets, walletIterator, () ->
					done()
			async.each @wallets, currencyIterator, () => @checkLater()
