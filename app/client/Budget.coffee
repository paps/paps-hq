class Budget
	constructor: () ->
		@dom = window.hq.utils.getDom 'budget',
			['header', 'refresh', 'content', 'overlay', 'alertBox',
			'spendingChart', 'prev', 'period1', 'period3', 'next', 'income',
			'spending', 'profit', 'periodStart', 'periodEnd', 'info',
			'period6', 'atm', 'doc', 'balanceChart', 'privacy']

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		today = new Date
		@periodStart = new Date today.getFullYear(), today.getMonth()
		@periodMonths = 1
		@periodEnd = @addMonthsToDate @periodStart, @periodMonths
		@spendingChart = null
		@balanceChart = null
		@distributeAtm = yes
		@privacyMode = yes

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.doc.click (e) =>
			window.hq.notes.show 'doc / Budget'
			e.stopPropagation()

		@dom.period1.click () =>
			@dom.period1.addClass 'success'
			@dom.period3.removeClass 'success'
			@dom.period6.removeClass 'success'
			@periodMonths = 1
			@periodEnd = @addMonthsToDate @periodStart, @periodMonths
			@refresh()

		@dom.period3.click () =>
			@dom.period1.removeClass 'success'
			@dom.period3.addClass 'success'
			@dom.period6.removeClass 'success'
			@periodMonths = 3
			@periodEnd = @addMonthsToDate @periodStart, @periodMonths
			@refresh()

		@dom.period6.click () =>
			@dom.period1.removeClass 'success'
			@dom.period3.removeClass 'success'
			@dom.period6.addClass 'success'
			@periodMonths = 6
			@periodEnd = @addMonthsToDate @periodStart, @periodMonths
			@refresh()

		@dom.prev.click () =>
			@periodStart.setTime @periodStart.getTime() - 1000 * 60 * 60 * 24 * 7
			@periodStart = new Date @periodStart.getFullYear(), @periodStart.getMonth()
			@periodEnd = @addMonthsToDate @periodStart, @periodMonths
			@refresh()

		@dom.next.click () =>
			@periodStart.setTime @periodStart.getTime() + 1000 * 60 * 60 * 24 * 38
			@periodStart = new Date @periodStart.getFullYear(), @periodStart.getMonth()
			@periodEnd = @addMonthsToDate @periodStart, @periodMonths
			@refresh()

		@dom.atm.click (e) =>
			if @distributeAtm
				@distributeAtm = no
				@dom.atm.attr 'title', 'enable atm distribution (currently off)'
				@dom.atm.attr 'src', window.hq.config.rootPath + 'img/server_go.png'
			else
				@distributeAtm = yes
				@dom.atm.attr 'title', 'disable atm distribution (currently on)'
				@dom.atm.attr 'src', window.hq.config.rootPath + 'img/server_delete.png'
			@refresh()
			e.stopPropagation()

		@dom.privacy.click (e) =>
			@privacyMode = not @privacyMode
			@refresh()
			e.stopPropagation()

	addMonthsToDate: (from, months) =>
		date = new Date(from.getTime() + 1000 * 60 * 60 * 24 * 32 * months)
		date = new Date date.getFullYear(), date.getMonth()
		date.setTime date.getTime() - 1000 * 10
		return date

	round: (v) -> window.hq.utils.round v, 2

	computeAtm: (spending) =>
		if spending.atm
			atm = spending.atm
			delete spending.atm
			total = 0
			for tag, spent of spending
				if not (tag in window.hq.config.budget.ignoredTagsForAtmDistribution) and tag isnt 'atm'
					total += spent
			for tag, spent of spending
				if not (tag in window.hq.config.budget.ignoredTagsForAtmDistribution) and tag isnt 'atm'
					tagSize = spent / total
					spending[tag] = spent + atm * tagSize
		return spending

	buildSpendingChart: (spending) =>
		if @distributeAtm then spending = @computeAtm(spending)
		tags = []
		values = []
		for tag, value of spending
			tags.push tag
			values.push @round value
		if not tags.length then return
		@spendingChart = new Highcharts.Chart
			chart:
				renderTo: @dom.spendingChart.get(0)
				type: 'column'
				animation: no
			plotOptions:
				series:
					animation: no
				column:
					stickyTracking: no
					pointWidth: 12
			legend:
				enabled: no
			title:
				text: null
			xAxis:
				categories: tags
				lineColor: '#888'
				tickLength: 0
			yAxis:
				title: null
				gridLineWidth: 1
				gridLineColor: '#ddd'
				lineWidth: 0
				endOnTick: no
				maxPadding: 0
				tickPixelInterval: 20
				tickLength: 0
				tickWidth: 0
			credits:
				enabled: false
			tooltip:
				animation: false
				shadow: false
				borderRadius: 0
				hideDelay: 0
			colors: ['#2284A1']
			series: [
				data: values
				name: 'spent'
			]

	buildBalanceChart: (balanceOverTime) =>
		values = []
		for day, value of balanceOverTime
			values.push [(parseInt day), value]
		chartConf =
			chart:
				renderTo: @dom.balanceChart.get(0)
				animation: no
			plotOptions:
				series:
					animation: no
				line:
					marker:
						enabled: false
			legend:
				enabled: no
			title:
				text: null
			xAxis:
				lineColor: '#888'
				tickLength: 0
				type: 'datetime'
				dateTimeLabelFormats:
					hour: '%b %e'
					day: '%b %e'
					week: '%b %e'
					month: '%b %e'
			yAxis:
				title: null
				gridLineWidth: 1
				gridLineColor: '#ddd'
				lineWidth: 0
				endOnTick: no
				maxPadding: 0
				tickPixelInterval: 20
				tickLength: 0
				tickWidth: 0
			credits:
				enabled: no
			tooltip:
				animation: no
				shadow: no
				borderRadius: 0
				hideDelay: 0
			colors: ['#2284A1']
			series: [
				data: values
				name: 'balance'
			]
		if @privacyMode
			chartConf.yAxis.labels =
				enabled: no
		@balanceChart = new Highcharts.Chart chartConf

	computeTransactions: (transactions) =>
		startDay = null
		startBalance = null
		endBalance = null
		totalSpent = 0
		nbSpentMatched = 0
		nbSpentUnmatched = 0
		totalIncome = 0
		nbIncomeMatched = 0
		nbIncomeUnmatched = 0
		unknownSpending = 0
		spending = {}
		balanceOverTime = {}
		for tr in transactions
			day = window.hq.utils.dateFromTimestamp tr.date
			day = Date.UTC day.getFullYear(), day.getMonth(), day.getDate()
			if startBalance is null
				startBalance = tr.balance - tr.amount
				startDay = day
				balanceOverTime[startDay] = @round(tr.balance - tr.amount)
			if day isnt startDay then balanceOverTime[day] = tr.balance
			endBalance = tr.balance
			if tr.amount >= 0
				totalIncome += tr.amount
				if tr.futureTransaction then ++nbIncomeMatched else ++nbIncomeUnmatched
			else
				totalSpent -= tr.amount
				ftr = tr.futureTransaction
				if ftr
					++nbSpentMatched
					if spending[ftr.tag] then spending[ftr.tag] -= tr.amount else spending[ftr.tag] = tr.amount * -1
				else
					++nbSpentUnmatched
					unknownSpending -= tr.amount
		@buildSpendingChart spending, totalSpent
		@buildBalanceChart balanceOverTime
		@dom.income.text @round totalIncome
		@dom.income.attr 'title', 'income from ' + (nbIncomeMatched + nbIncomeUnmatched) + ' transaction' + (if (nbIncomeMatched + nbIncomeUnmatched) > 1 then 's' else '') + ' (' + nbIncomeMatched + ' matched, ' + nbIncomeUnmatched + ' considered matched)'
		@dom.spending.text @round totalSpent
		@dom.spending.attr 'title', 'spending from ' + (nbSpentMatched + nbSpentUnmatched) + ' transaction' + (if (nbSpentMatched + nbSpentUnmatched) > 1 then 's' else '') + ' (' + nbSpentMatched + ' matched, ' + nbSpentUnmatched + ' considered matched)'
		profit = @round(endBalance - startBalance)
		if @privacyMode
			@dom.profit.empty()
		else
			@dom.profit.text profit
		if profit > 0 then (@dom.profit.css 'color', '#5DA423') else (@dom.profit.css 'color', '#C60F13')
		@dom.profit.attr 'title', 'profit with a ' + Math.abs(@round(profit - (totalIncome - totalSpent))) + ' offset from the calculated value ' + @round(totalIncome - totalSpent)
		if @privacyMode
			infoHtml = ''
		else
			infoHtml = '<strong>' + @round(startBalance) + '</strong> &rarr; <strong>' + @round(endBalance) + '</strong>'
		infoHtml += '<br />Credits: <strong>' + (nbIncomeMatched + nbIncomeUnmatched) + '</strong>, debits: <strong>' + (nbSpentMatched + nbSpentUnmatched) + '</strong>' +
			'<br />Unk. spending: <strong>' + @round(unknownSpending) + '</strong>'
		@dom.info.html infoHtml

	notEnoughData: () =>
		@dom.income.empty()
		@dom.spending.empty()
		@dom.profit.empty()
		@dom.info.text '(no data)'

	refresh: () =>
		@overlay yes
		if @spendingChart
			@spendingChart.destroy()
			@spendingChart = null
		if @balanceChart
			@balanceChart.destroy()
			@balanceChart = null
		($.ajax window.hq.config.rootPath + 'modules/budget/period',
			type: 'GET'
			dataType: 'json'
			data:
				start: Math.round @periodStart.getTime() / 1000
				end: Math.round @periodEnd.getTime() / 1000
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					if data.transactions.length >= 2
						@computeTransactions data.transactions
					else
						@notEnoughData()
			else
				@error 'malformed json reply'
		).fail((xhr, status, err) =>
			@error status + ': ' + err
		).always () => @overlay no
		@dom.periodStart.text window.hq.utils.dateToStr @periodStart
		@dom.periodEnd.text window.hq.utils.dateToStr @periodEnd

	show: () =>
		@dom.content.show()
		if not @refreshed
			@refreshed = yes
			@refresh()

	hide: () => @dom.content.hide()

	isVisible: () => @dom.content.is ':visible'

	overlay: (show) => if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) => @dom.alertBox.text(err).show().effect 'highlight'

$ -> window.hq.budget = new Budget
