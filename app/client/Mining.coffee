class Mining
	constructor: () ->
		@dom = window.hq.utils.getDom 'mining',
			['header', 'refresh', 'content', 'overlay', 'alertBox', 'doc',
			'table', 'summary']

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.doc.click (e) =>
			window.hq.notes.show 'doc / Mining'
			e.stopPropagation()

	refresh: () =>
		@overlay yes
		($.ajax window.hq.config.rootPath + 'modules/mining/latest',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					nbMiners = 0
					nbDevices = 0
					totalMh = 0
					for name, miner of data.miners
						if not miner.notificator.consideredDown
							++nbMiners
						header = $('<td>').attr('colspan', 8).append $('<strong>').text name
						if (Array.isArray miner?.status?.STATUS) and miner?.status?.STATUS.length > 0
							s = miner.status.STATUS[0]
							header.append ' - ' + s.Msg + s.Description
						link = $('<div>').css('float', 'right').append $('<img>').attr('src', window.hq.config.rootPath + 'img/transmit.png')
						age = Math.round(((new Date).getTime() / 1000) - miner.notificator.update)
						if miner.notificator.consideredDown
							if age < 120
								age = '' + (if age < 0 then 0 else age) + 's'
							else if age < 60 * 60 * 2
								age = '' + Math.round(age / 60) + 'm'
							else
								age = '' + Math.round(age / (60 * 60)) + 'h'
							link.append $('<strong>').css('color', '#C60F13').text ' down for ' + age + ' '
							link.append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
							link.attr 'title', name + ' is not sending updates'
						else
							link.append ' ' + (if age < 0 then 0 else age) + 's'
							link.attr 'title', 'seconds since update from ' + name
						header.append link
						@dom.table.append $('<tr>').css('border-bottom', '1px solid #ccc').css('height', '27px').append header
						for d in miner?.status?.DEVS
							bullet = 'red'
							if not miner.notificator.consideredDown
								++nbDevices
								totalMh += d['MHS 5s']
								if d['Status'] is 'Alive'
									if d['Hardware Errors'] > 0
										bullet = 'orange'
									else
										bullet = 'green'
							line = $('<tr>')
							line.append $('<td>').append $('<img>').attr 'src', window.hq.config.rootPath + 'img/bullet_' + bullet + '.png'
							line.append $('<td>').text '[' + d['GPU'] + ']'
							line.append $('<td>').text d['Temperature'] + '°'
							line.append $('<td>').text d['Fan Speed'] + ' (' + d['Fan Percent'] + '%)'
							line.append $('<td>').text d['MHS 5s'] + ' mh/s'
							line.append $('<td>').text 'A:' + d['Accepted']
							line.append $('<td>').text 'R:' + d['Rejected']
							line.append $('<td>').text 'HW:' + d['Hardware Errors']
							line.attr 'title', 'status: ' + d['Status'] + ', clock: ' + d['GPU Clock'] + ', mem clock: ' + d['Memory Clock'] + ', voltage: ' + d['GPU Voltage'] + ', intensity: ' + d['Intensity']
							@dom.table.append line
					@dom.summary.empty()
					if nbMiners
						@dom.summary.text (Math.round(totalMh * 100) / 100) + ' mh/s with ' + nbMiners + ' miner' + (if nbMiners > 1 then 's' else '') + ' (' + nbDevices + ' device' + (if nbDevices > 1 then 's' else '') + ').'
					else
						@dom.summary.text 'No updates received from miners yet.'
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

$ -> window.hq.mining = new Mining
