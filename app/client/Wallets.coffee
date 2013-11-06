class Wallets
	constructor: () ->
		@dom = window.hq.utils.getDom 'wallets',
			['header', 'refresh', 'content', 'overlay', 'alertBox', 'doc',
			'table']

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.doc.click (e) =>
			window.hq.notes.show 'doc / Wallets'
			e.stopPropagation()

	refresh: () =>
		@overlay yes
		($.ajax window.hq.config.rootPath + 'modules/wallets/latest',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					for currency in data.wallets
						link = $('<div>').css('float', 'right').append $('<img>').attr 'src', window.hq.config.rootPath + 'img/transmit.png'
						header = $('<td>').attr('colspan', 4).text ' ' + currency.currency
						header.prepend $('<img>').attr('src', window.hq.config.rootPath + 'img/' + currency.icon + '.png')
						@dom.table.append $('<tr>').css('border-bottom', '1px solid #ccc').css('height', '27px').css('font-weight', 'bold').append header
						total = 0
						timeSinceUpdate = -1
						for wallet in currency.wallets
							line = $('<tr>')
							line.append $('<td>').text wallet.name
							amountCell = $('<td>')
							if (typeof wallet.amount) is 'number'
								amountCell.text (window.hq.utils.round wallet.amount, 4) + ' ' + currency.symbol + ' '
								total += wallet.amount
							error = wallet.error
							if not error and (typeof wallet.amount) isnt 'number' then error = 'amount not fetched yet'
							if error
								amountCell.append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
								amountCell.attr 'title', error
							line.append amountCell
							line.append $('<td>').attr('title', wallet.address).text wallet.address.substr(0, 6) + '...' + wallet.address.substr(-6)
							line.append $('<td>').css('text-align', 'right').append $('<a>').attr('title', 'view ' + wallet.address + ' in a chain explorer').attr('href', wallet.humanUrl).attr('target', '_blank').append $('<img>').attr('src', window.hq.config.rootPath + 'img/zoom.png')
							@dom.table.append line
							if (typeof wallet.timeSinceUpdate) is 'number' and wallet.timeSinceUpdate > timeSinceUpdate
								timeSinceUpdate = wallet.timeSinceUpdate
						if timeSinceUpdate >= 0
							if timeSinceUpdate < 120
								link.append ' ' + timeSinceUpdate + 's'
							else if timeSinceUpdate < 60 * 60 * 2
								link.append ' ' + Math.round(timeSinceUpdate / 60) + 'm'
							else
								link.append ' ' + Math.round(timeSinceUpdate / (60 * 60)) + 'h'
						else
							link.append ' ?'
						link.attr 'title', 'elapsed time since last check'
						header.append link
						totalTr = $('<tr>')
						totalTr.append $('<td>').css('text-align', 'right').css('font-weight', 'bold').text '= '
						totalTr.append $('<td>').text (window.hq.utils.round total, 4) + ' ' + currency.symbol
						totalTr.append $('<td>')
						totalTr.append $('<td>')
						@dom.table.append totalTr
			else
				@error 'malformed json reply'
		).fail((xhr, status, err) =>
			@error status + ': ' + err
		).always () => @overlay no

	show: () =>
		@dom.content.show()
		if not @refreshed
			@refreshed = yes
			@refresh()

	hide: () => @dom.content.hide()

	isVisible: () => @dom.content.is ':visible'

	overlay: (show) => if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) => @dom.alertBox.text(err).show().effect 'highlight'

$ -> window.hq.wallets = new Wallets
