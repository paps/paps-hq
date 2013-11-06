class Session
	constructor: () ->
		@dom = window.hq.utils.getDom 'session',
			['all', 'sessions', 'none', 'refresh', 'alertBox', 'doc',
			'autoRefresh', 'refreshCounter', 'save', 'table', 'tableRow']

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.refresh.click () => @refreshModules()

		@dom.doc.click (e) =>
			window.hq.notes.show 'doc / Session'
			e.stopPropagation()

		@dom.none.click () =>
			for m in window.hq.config.session.modules
				window.hq[m].hide()

		@dom.all.click () =>
			for m in window.hq.config.session.modules
				window.hq[m].show()

		@dom.sessions.click () => @refreshAndShowSessions()

		@timeBeforeRefresh = null

		@activity = 0
		$(document).mousemove () => ++@activity
		$(document).keypress () => ++@activity

		@dom.autoRefresh.click () => @setAutoRefresh @dom.autoRefresh.is ':checked'

		setInterval (() =>
			if @timeBeforeRefresh is null then return
			if @activity
				@timeBeforeRefresh = window.hq.config.session.refreshInterval
				@dom.refreshCounter.text '(paused)'
				@activity = 0
			else
				if @timeBeforeRefresh <= 2
					@refreshModules()
					@timeBeforeRefresh = window.hq.config.session.refreshInterval
					@dom.refreshCounter.text '(just refreshed)'
				else
					@timeBeforeRefresh -= 10
					@showRefreshCounter()
			), 10000

		($.ajax window.hq.config.rootPath + 'modules/session/my-configuration',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					cfg = data.configuration
					if cfg
						@setAutoRefresh cfg.autoRefresh
						modules = cfg.openModules.split ','
						for m in window.hq.config.session.modules
							if m in modules
								window.hq[m].show()
							else
								window.hq[m].hide()
					else
						@setAutoRefresh no
			else
				@error 'malformed json reply while fetching configuration'
		).fail (xhr, status, err) =>
			@error status + ': ' + err

		@dom.save.click () =>
			@dom.save.prop('disabled', true).text '...'
			modules = ''
			for m in window.hq.config.session.modules
				if window.hq[m].isVisible()
					if modules.length then modules += ','
					modules += m
			($.ajax window.hq.config.rootPath + 'modules/session/save-configuration',
				type: 'POST'
				dataType: 'json'
				data:
					autoRefresh: (if @dom.autoRefresh.is ':checked' then 1 else 0)
					openModules: modules
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
				else
					@error 'malformed json reply while saving configuration'
			).fail((xhr, status, err) =>
				@error status + ': ' + err
			).always () =>
				setTimeout (() => @dom.save.prop('disabled', false).text 'Save'), 500

	setAutoRefresh: (autoRefresh) =>
		if autoRefresh
			@dom.autoRefresh.prop 'checked', 1
			@timeBeforeRefresh = window.hq.config.session.refreshInterval - 10
			@showRefreshCounter()
		else
			@dom.autoRefresh.prop 'checked', 0
			@timeBeforeRefresh = null
			@dom.refreshCounter.text ''

	showRefreshCounter: () => @dom.refreshCounter.text '(in ~' + @timeBeforeRefresh + 's)'

	refreshModules: () =>
		if not @dom.refresh.prop 'disabled'
			@dom.refresh.prop('disabled', true).text '...'
			setTimeout (() => @dom.refresh.prop('disabled', false).text 'Refresh'), 10000
			c = 0
			for m in window.hq.config.session.modules
				if window.hq[m].isVisible()
					setTimeout ((m) =>
						() => window.hq[m].refresh()
					)(m), window.hq.config.session.gentleRefresh * c++
			if @dom.tableRow.is ':visible'
				setTimeout (() => @refreshAndShowSessions()), window.hq.config.session.gentleRefresh * c

	refreshAndShowSessions: () =>
		@dom.tableRow.show()
		@dom.table.empty().append $('<tr>').append $('<td>').css('text-align', 'center').text '...'
		($.ajax window.hq.config.rootPath + 'modules/session/active-sessions',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					for ip, sess of data.sessions
						line = $('<tr>')
						line.append $('<td>').attr('title', 'session ip').text ip
						line.append $('<td>').css('text-align', 'center').attr('title', 'first seen').text window.hq.utils.dateToStr sess.firstSeen
						age = sess.timeSinceLastSeen
						if (typeof age) is 'number' and age >= 0
							if age < 120
								age = '' + age + 's'
							else if age < 60 * 60 * 2
								age = '' + Math.round(age / 60) + 'm'
							else if age < 3 * 24 * 60 * 60
								age = '' + Math.round(age / (60 * 60)) + 'h'
							else
								age = '' + Math.round(age / (24 * 60 * 60)) + 'd'
						else
							age = '?'
						line.append $('<td>').css('text-align', 'right').attr('title', 'time since last activity').text age
						@dom.table.append line
					refreshButton = $('<button>').addClass('tiny').css('margin-bottom', '2px').text 'Refresh'
					refreshButton.click () => @refreshAndShowSessions()
					closeButton = $('<button>').addClass('tiny').css('margin-bottom', '2px').text 'Close'
					closeButton.click () => @dom.tableRow.hide()
					@dom.table.append $('<tr>').append $('<td>').attr('colspan', 3).css('text-align', 'center').append(refreshButton).append(' ').append(closeButton)
			else
				@error 'malformed json reply'
		).fail (xhr, status, err) =>
			@error status + ': ' + err

	error: (err) => @dom.alertBox.text(err).show()

$ -> window.hq.session = new Session
