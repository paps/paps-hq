class BtcChina
	constructor: () ->
		@dom = window.hq.utils.getDom 'btcChina',
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
			window.hq.notes.show 'doc / BTC China'
			e.stopPropagation()

	refresh: () =>
		@overlay yes
		($.ajax window.hq.config.rootPath + 'modules/btc-china/latest',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					status = data.status
					@dom.table.empty()
					line1 = $('<tr>').css('font-weight', 'bold')
					line1.append $('<td>').text 'last RMB'
					line1.append $('<td>').text 'trailing-stop RMB'
					line1.append $('<td>').text 'last EUR'
					line1.append $('<td>').text 'last USD'
					line2 = $('<tr>')
					if status.price
						line2.append $('<td>').text window.hq.utils.round(status.price, 2)
						line2.append $('<td>').text status.trailingStop
						line2.append $('<td>').text window.hq.utils.round(status.price * window.hq.config.btcChina.yuanToEuro, 2)
						line2.append $('<td>').text window.hq.utils.round(status.price * window.hq.config.btcChina.yuanToDollar, 2)
					else
						line2.append $('<td>').text '?'
						line2.append $('<td>').text status.trailingStop
						line2.append $('<td>').text '?'
						line2.append $('<td>').text '?'
					line3 = $('<tr>').css('font-weight', 'bold')
					line3.append $('<td>').text 'highest RMB'
					line3.append $('<td>').text 'trailing-stop %'
					line3.append $('<td>').text 'last tick'
					line3.append $('<td>').text 'last update'
					line4 = $('<tr>')
					line4.append $('<td>').text window.hq.utils.round(status.highestPrice, 2)
					if status.price
						ts = (status.highestPrice - status.price) / status.trailingStop
						cell = $('<td>').text window.hq.utils.round(ts * 100, 1) + '%'
						if ts > 0.5
							cell.css('color', '#C60F13').css 'font-weight', 'bold'
							cell.append(' ').append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
						line4.append cell
					else
						line4.append $('<td>').text '?'
					cell = $('<td>').text window.hq.utils.ageToString status.timeSinceLastTick
					if status.consideredDown
						cell.css('color', '#C60F13').css 'font-weight', 'bold'
						cell.append(' ').append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
						cell.attr 'title', 'considered down'
					line4.append cell
					line4.append $('<td>').text window.hq.utils.ageToString status.timeSinceLastUpdate
					line5 = $('<tr>').css('font-weight', 'bold')
					line5.append $('<td>')
					line5.append $('<td>').text 'trailing-stop limit'
					line5.append $('<td>').attr('title', 'number of Bitcoinity sessions').text 'sessions'
					line5.append $('<td>').text 'Mt.Gox lag'
					line6 = $('<tr>')
					line6.append $('<td>')
					if status.price
						line6.append $('<td>').text window.hq.utils.round(status.highestPrice - status.trailingStop, 2)
					else
						line6.append $('<td>').text '?'
					line6.append $('<td>').attr('title', 'number of Bitcoinity sessions').text (if status.sessions then status.sessions else '?')
					line6.append $('<td>').text (if status.goxlag then (status.goxlag + 's') else '?')
					@dom.table.append line1
					@dom.table.append line2
					@dom.table.append line3
					@dom.table.append line4
					@dom.table.append line5
					@dom.table.append line6
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

$ -> window.hq.btcChina = new BtcChina
