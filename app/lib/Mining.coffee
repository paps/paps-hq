module.exports = (app) ->

	utils = require __dirname + '/../lib/utils'
	addNotification = (require __dirname + '/../notificators/add') app

	class Mining
		constructor: () ->
			@cfg = app.config.mining
			@miners = {}

		update: (name, status) =>
			newMiner = no
			if not @miners[name]
				newMiner = yes
				@miners[name] =
					notificator:
						consideredDown: no
			@miners[name].status = status
			if @miners[name].notificator.consideredDown
				addNotification 'mining', name + ' is back and sending updates', 141, 182, 0, '*'
			@miners[name].notificator.update = utils.now()
			@miners[name].notificator.consideredDown = no
			aliveDevices = 0
			hardwareErrors = 0
			for d in status?.DEVS
				if d['Status'] is 'Alive'
					++aliveDevices
				hardwareErrors += d['Hardware Errors']
			if not newMiner
				if aliveDevices < @miners[name].notificator.aliveDevices
					addNotification 'mining', name + ' has lost one or more device', 165, 42, 42, '*'
				else if aliveDevices > @miners[name].notificator.aliveDevices
					addNotification 'mining', name + ' has restored one or more device', 141, 182, 0, '*'
				if hardwareErrors > @miners[name].notificator.hardwareErrors
					addNotification 'mining', name + ' has hardware errors', 165, 42, 42, '*'
			@miners[name].notificator.aliveDevices = aliveDevices
			@miners[name].notificator.hardwareErrors = hardwareErrors

		checkLater: () =>
			setTimeout (() => @check()), @cfg.checkInterval * 1000

		check: () =>
			for name, miner of @miners
				n = miner.notificator
				if not n.consideredDown
					age = utils.now() - n.update
					if age > @cfg.allowedDowntime
						n.consideredDown = yes
						addNotification 'mining', 'No updates from ' + name + ' for more than ' + Math.round(age / 60) + 'm', 165, 42, 42, '*'
			@checkLater()
