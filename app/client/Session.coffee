class Session
	constructor: () ->
		@dom = window.hq.utils.getDom 'session',
			['all', 'desktop', 'mobile', 'tablet', 'none', 'refresh',
			'autoRefresh', 'refreshCounter', 'save', 'alertBox', 'doc']

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.refresh.click () => @refreshModules()

		@dom.doc.click (e) =>
			window.hq.notes.show 'doc / Session'
			e.stopPropagation()

		@dom.none.click () =>
			for m in window.hq.config.session.modules.all
				window.hq[m].hide()

		@dom.all.click () =>
			for m in window.hq.config.session.modules.all
				window.hq[m].show()

		@dom.desktop.click () => @showArrayOfModules 'desktop'
		@dom.mobile.click () => @showArrayOfModules 'mobile'
		@dom.tablet.click () => @showArrayOfModules 'tablet'

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
						for m in window.hq.config.session.modules.all
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
			@dom.save.prop('disabled', true).text 'Saving...'
			modules = ''
			for m in window.hq.config.session.modules.all
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
			@dom.refresh.prop('disabled', true).text 'Refreshing...'
			setTimeout (() => @dom.refresh.prop('disabled', false).text 'Refresh'), 3000
			for m in window.hq.config.session.modules.all
				if window.hq[m].isVisible() then window.hq[m].refresh()

	showArrayOfModules: (name) =>
		for m in window.hq.config.session.modules.all
			if m in window.hq.config.session.modules[name]
				window.hq[m].show()
			else
				window.hq[m].hide()

	error: (err) => @dom.alertBox.text(err).show()

$ -> window.hq.session = new Session
