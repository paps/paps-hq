class Session
	constructor: () ->
		@dom =
			all: $ '#sessionAll'
			desktop: $ '#sessionDesktop'
			mobile: $ '#sessionMobile'
			tablet: $ '#sessionTablet'
			none: $ '#sessionNone'
			refresh: $ '#sessionRefresh'
			autoRefresh: $ '#sessionAutoRefresh'
			refreshCounter: $ '#sessionRefreshCounter'
			save: $ '#sessionSave'
			alertBox: $ '#sessionAlertBox'

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.refresh.click () => @refreshModules()

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

		@dom.autoRefresh.click () => @setAutoRefresh @dom.autoRefresh.is ':checked'

		setInterval (() =>
			if @timeBeforeRefresh is null then return
			if @timeBeforeRefresh <= 2
				@refreshModules()
				@timeBeforeRefresh = window.hq.config.session.refreshInterval
				@dom.refreshCounter.text '(just refreshed)'
			else
				@timeBeforeRefresh -= 10
				@showRefreshCounter()
			), 10000

		($.ajax '/modules/session/my-configuration',
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
						@dom.autoRefresh.prop 'checked', 0
			else
				@error 'malformed json reply while fetching configuration'
		).fail (xhr, status, err) =>
			@error status + ': ' + err

		@dom.save.click () =>
			@dom.save.hide()
			modules = ''
			for m in window.hq.config.session.modules.all
				if window.hq[m].isVisible()
					if modules.length then modules += ','
					modules += m
			($.ajax '/modules/session/save-configuration',
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
			).always () => @dom.save.show 'slow'

	setAutoRefresh: (autoRefresh) =>
		if autoRefresh
			@timeBeforeRefresh = window.hq.config.session.refreshInterval - 10
			@showRefreshCounter()
		else
			@timeBeforeRefresh = null
			@dom.refreshCounter.text ''

	showRefreshCounter: () => @dom.refreshCounter.text '(refreshing in ' + @timeBeforeRefresh + 's)'

	refreshModules: () =>
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
