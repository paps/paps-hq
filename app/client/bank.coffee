class Bank
	constructor: () ->
		@dom =
			header: $ '#bankHeader'
			refresh: $ '#bankRefresh'
			content: $ '#bankContent'
		@refreshed = false
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = false
			@show()
			e.stopPropagation()

	refresh: () -> alert 'toto'

	show: () ->
		if not @isVisible() then @dom.content.show()
		if not @refreshed
			@refreshed = true
			@refresh()

	hide: () -> if @isVisible() then @dom.content.hide()

	isVisible: () -> @dom.content.is ':visible'

$ ->

	window.bank = new Bank
