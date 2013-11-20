EventSource = require 'eventsource'

module.exports = (app) ->

	utils = require __dirname + '/../lib/utils'
	addNotification = (require __dirname + '/../notificators/add') app

	class BtcChina
		constructor: () ->
			@cfg = app.config.btcChina
			@lastUpdate = utils.now()
			@lastTick = utils.now()
			@sourceResetTime = utils.now()
			@status =
				sessions: null
				goxlag: null
				price: null
				highestPrice: 0
				trailingStop: @cfg.trailingStop
				consideredDown: no

		setSource: () =>
			if @source
				@source.close()
			@sourceResetTime = utils.now()
			@lastUpdate = utils.now()
			url = 'http://bitcoinity.org/ev/markets/markets_btcchina_CNY'
			console.log 'New BTC China event source ' + url
			@source = new EventSource url
			@source.onmessage = (msg) =>
				try
					@receiveMessage JSON.parse msg.data
				catch e
					;
			@source.onerror = () =>
				devices = null
				if @cfg.alerts then devices = '*'
				addNotification 'btcchina', 'Bitcoinity event source failure', 227, 38, 54, devices
				setTimeout (() => @setSource()), (@cfg.allowedDowntime / 3) * 1000

		receiveMessage: (data) =>
			@lastUpdate = utils.now()
			if (typeof data.id) is 'number' and (typeof data.channel) is 'string' and (typeof data.text) is 'object'
				if data.channel is 'markets' and (typeof data.text.connected_count) is 'number'
					@status.sessions = data.text.connected_count
				else if data.channel is 'markets' and (typeof data.text.mtgox_lag) is 'string'
					@status.goxlag = data.text.mtgox_lag
				else if data.channel is 'markets_btcchina_CNY' and (typeof data.text.ticker) is 'object' and (typeof data.text.ticker.last) is 'number' and data.text.exchange_name is 'btcchina' and data.text.currency is 'CNY'
					@tick data.text.ticker.last

		tick: (price) =>
			if price > @status.highestPrice
				@status.highestPrice = price
			if @cfg.alerts or @cfg.emergencyAlerts
				prevPrice = @status.price
				newPrice = price
				stop = @status.highestPrice - @cfg.trailingStop
				stop75 = @status.highestPrice - @cfg.trailingStop * 0.75
				stop50 = @status.highestPrice - @cfg.trailingStop * 0.5
				stop25 = @status.highestPrice - @cfg.trailingStop * 0.25
				alert = null
				alertType = '*'
				if prevPrice > stop and newPrice <= stop
					alert = 'Trailing stop hit at 100%'
					if @cfg.emergencyAlerts then alertType = '!'
				else if prevPrice > stop75 and newPrice <= stop75
					alert = 'Trailing stop hit at 75%'
				else if prevPrice > stop50 and newPrice <= stop50
					alert = 'Trailing stop hit at 50%'
					alert = null # disabled
				else if prevPrice > stop25 and newPrice <= stop25
					alert = 'Trailing stop hit at 25%'
					alert = null # disabled
				if alert
					alert += ' (from ' + utils.round(prevPrice, 2) + ' to ' + utils.round(newPrice, 2) + ' RMB)'
					addNotification 'btcchina', alert, 227, 38, 54, alertType
			@status.price = price
			@status.consideredDown = no
			@lastTick = utils.now()

		checkLater: () =>
			setTimeout (() => @check()), @cfg.checkInterval * 1000

		check: () =>
			elapsed = utils.now() - @lastTick
			if elapsed > @cfg.allowedDowntime * 2 and not @status.consideredDown
				@status.consideredDown = yes
				devices = null
				if @cfg.emergencyAlerts
					devices = '!'
				else if @cfg.alerts
					devices = '*'
				addNotification 'btcchina', 'No tick from Bitcoinity for more than ' + Math.round(elapsed / 60) + 'm', 227, 38, 54, devices
				@setSource()
			else if elapsed > @cfg.allowedDowntime and (utils.now() - @sourceResetTime) > (@cfg.allowedDowntime / 2)
				@setSource()
			@checkLater()

		get: () =>
			@status.timeSinceLastUpdate = utils.now() - @lastUpdate
			@status.timeSinceLastTick = utils.now() - @lastTick
			@status
