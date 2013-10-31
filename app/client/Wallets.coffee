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
						header = $('<td>').attr('colspan', 4).text ' ' + currency.currency
						header.prepend $('<img>').attr('src', window.hq.config.rootPath + 'img/' + currency.icon + '.png')
						@dom.table.append $('<tr>').css('border-bottom', '1px solid #ccc').css('height', '27px').css('font-weight', 'bold').append header
						total = 0
						for wallet in currency.wallets
							line = $('<tr>')
							line.append $('<td>').text wallet.name
							amountCell = $('<td>')
							if wallet.amount
								amountCell.text (Math.round(wallet.amount * 10000) / 10000) + ' ' + currency.symbol + ' '
								total += wallet.amount
							error = wallet.error
							if not error and not wallet.amount then error = 'amount not fetched yet'
							if error
								amountCell.append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
								amountCell.attr 'title', error
							line.append amountCell
							line.append $('<td>').attr('title', wallet.address).text wallet.address.substr(0, 6) + '...' + wallet.address.substr(-6)
							line.append $('<td>').css('text-align', 'right').append $('<a>').attr('title', 'view ' + wallet.address + ' in a chain explorer').attr('href', wallet.humanUrl).attr('target', '_blank').append $('<img>').attr('src', window.hq.config.rootPath + 'img/zoom.png')
							@dom.table.append line
						totalTr = $('<tr>')
						totalTr.append $('<td>').css('text-align', 'right').css('font-weight', 'bold').text '= '
						totalTr.append $('<td>').text (Math.round(total * 10000) / 10000) + ' ' + currency.symbol
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
