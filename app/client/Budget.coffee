class Budget
	constructor: () ->
		@dom = window.hq.utils.getDom 'budget',
			['header', 'refresh', 'content', 'overlay', 'alertBox',
			'spendingChart', 'prev', 'period1', 'period3', 'next', 'income',
			'spending', 'profit', 'periodStart', 'periodEnd', 'info',
			'period6', 'atm']

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
		@distributeAtm = yes

		@dom.alertBox.click () => @dom.alertBox.hide()

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
				@dom.atm.attr 'title', 'distribute atm transactions (currently off)'
				@dom.atm.attr 'src', '/img/server_go.png'
			else
				@distributeAtm = yes
				@dom.atm.attr 'title', 'distribute atm transactions (currently on)'
				@dom.atm.attr 'src', '/img/server_delete.png'
			@refresh()
			e.stopPropagation()

	addMonthsToDate: (from, months) =>
		date = new Date
		date.setTime from.getTime() + 1000 * 60 * 60 * 24 * 32 * months
		date = new Date date.getFullYear(), date.getMonth()
		date.setTime date.getTime() - 1000 * 10
		return date

	buildSpendingChart: (spending) =>
		tags = []
		values = []
		for tag, value of spending
			tags.push tag
			values.push Math.round(value * 100) / 100
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
				gridLineWidth: 0
				lineWidth: 1
				lineColor: '#888'
				endOnTick: no
				maxPadding: 0
				tickPixelInterval: 20
				tickLength: 4
				tickWidth: 1
				tickColor: '#888'
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

	computeTransactions: (transactions) =>
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
		for tr in transactions
			if startBalance is null then startBalance = tr.balance
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
		@buildSpendingChart spending
		@dom.income.text Math.round(totalIncome * 100) / 100
		@dom.income.attr 'title', 'income from ' + (nbIncomeMatched + nbIncomeUnmatched) + ' transactions (' + nbIncomeMatched + ' matched, ' + nbIncomeUnmatched + ' considered matched)'
		@dom.spending.text Math.round(totalSpent * 100) / 100
		@dom.spending.attr 'title', 'spending from ' + (nbSpentMatched + nbSpentUnmatched) + ' transactions (' + nbSpentMatched + ' matched, ' + nbSpentUnmatched + ' considered matched)'
		profit = Math.round((endBalance - startBalance) * 100) / 100
		@dom.profit.text profit
		if profit > 0 then (@dom.profit.css 'color', '#5DA423') else (@dom.profit.css 'color', '#C60F13')
		@dom.profit.attr 'title', 'profit with a ' + Math.abs(Math.round((profit - (totalIncome - totalSpent)) * 100) / 100) + ' offset from the calculated value ' + (Math.round((totalIncome - totalSpent) * 100) / 100)
		@dom.info.html '<strong>' + startBalance + '</strong> &rarr; <strong>' + endBalance + '</strong>' +
			'<br /><strong>' + (nbIncomeMatched + nbIncomeUnmatched) + '</strong> credits, <strong>' + (nbSpentMatched + nbSpentUnmatched) + '</strong> debits' +
			'<br /><strong>' + (Math.round(unknownSpending * 100) / 100) + '</strong> unk. spending'

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
		($.ajax '/modules/budget/period',
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
