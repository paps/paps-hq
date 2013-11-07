module.exports = (app) ->

	utils = require __dirname + '/../lib/utils'
	addNotification = (require __dirname + '/../notificators/add') app

	class Machines
		constructor: () ->
			@cfg = app.config.machines
			@machines = {}

		update: (name, ip, uptime, load) =>
			if not @machines[name]
				@machines[name] =
					consideredDown: no
					load: 0
			@machines[name].update = utils.now()
			@machines[name].ip = ip
			@machines[name].uptime = uptime
			@machines[name].previousLoad = @machines[name].load
			@machines[name].load = load
			if @machines[name].consideredDown
				@machines[name].consideredDown = no
				addNotification 'machine', name + ' is back and sending updates', 85, 107, 47, '*'
			if @machines[name].previousLoad <= 1 and @machines[name].load > 1
				addNotification 'machine', name + ' has a high 15min load of ' + utils.round(@machines[name].load, 2), 227, 38, 54, '*'
			else if @machines[name].previousLoad > 1 and @machines[name].load <= 1
				addNotification 'machine', name + ' is back to a lower 15min load of ' + utils.round(@machines[name].load, 2), 85, 107, 47, '*'

		checkLater: () =>
			setTimeout (() => @check()), @cfg.checkInterval * 1000

		check: () =>
			for name, machine of @machines
				if not machine.consideredDown
					age = utils.now() - machine.update
					if age > @cfg.allowedDowntime
						machine.consideredDown = yes
						addNotification 'machine', 'No updates from ' + name + ' for more than ' + Math.round(age / 60) + 'm', 227, 38, 54, '*'
			@checkLater()
