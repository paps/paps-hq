class Machines
	constructor: () ->
		@dom = window.hq.utils.getDom 'machines',
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
			window.hq.notes.show 'doc / Machines'
			e.stopPropagation()

	refresh: () =>
		@overlay yes
		($.ajax window.hq.config.rootPath + 'modules/machines/latest',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					line = $('<tr>').css('border-bottom', '1px solid #ccc').css 'font-weight', 'bold'
					line.append $('<td>')
					line.append $('<td>').text 'name'
					line.append $('<td>').text 'ip'
					line.append $('<td>').text 'uptime'
					line.append $('<td>').attr('title', '15min load average').text 'load'
					line.append $('<td>').css('text-align', 'right').text 'last seen'
					@dom.table.append line
					for name, machine of data.machines
						line = $('<tr>')
						bullet = 'green'
						if machine.consideredDown
							bullet = 'red'
						else if machine.load > 1
							bullet = 'orange'
						line.append $('<td>').append $('<img>').attr 'src', window.hq.config.rootPath + 'img/bullet_' + bullet + '.png'
						line.append $('<td>').text name
						line.append $('<td>').text machine.ip
						line.append $('<td>').text window.hq.utils.ageToString machine.uptime
						load = $('<td>').attr('title', '15min load average').text machine.load
						if machine.load > 1
							load.css('color', '#C60F13').css 'font-weight', 'bold'
							load.attr 'title', 'high 15min load average'
							load.append ' '
							load.append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
						line.append load
						age = $('<td>').css('text-align', 'right').text window.hq.utils.ageToString machine.timeSinceUpdate
						if machine.consideredDown
							age.css('color', '#C60F13').css 'font-weight', 'bold'
							age.attr 'title', 'considered down'
							age.append ' '
							age.append $('<img>').attr('src', window.hq.config.rootPath + 'img/exclamation.png')
						line.append age
						@dom.table.append line
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

$ -> window.hq.machines = new Machines
