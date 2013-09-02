class CreditCard
	constructor: () ->
		@dom =
			header: $ '#creditCardHeader'
			refresh: $ '#creditCardRefresh'
			content: $ '#creditCardContent'
			amount: $ '#creditCardAmount'
			description: $ '#creditCardDescription'
			date: $ '#creditCardDate'
			id: $ '#creditCardId'
			overlay: $ '#creditCardOverlay'
			form: $ '#creditCardForm'
			del: $ '#creditCardDel'
			tagContainer: $ '#creditCardTagContainer'
			tags: {}
			alertBox: $ '#creditCardAlertBox'
			table: $ '#creditCardTable'

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.date.datetimepicker
			controlType: 'select'

		@dom.alertBox.click () =>
			@dom.alertBox.hide()

		@dom.form.submit () =>
			@overlay yes
			tags = ''
			for tag, elem of @dom.tags
				if not elem.hasClass 'secondary'
					tags += ',' if tags.length
					tags += tag
			($.ajax '/modules/credit-card/record/add',
				type: 'POST'
				dataType: 'json'
				data:
					amount: @dom.amount.val()
					date: @dom.date.datetimepicker('getDate')?.getTime() / 1000
					description: @dom.description.val()
					tags: tags
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
						@overlay no
					else
						@refresh()
						@dom.amount.val ''
						@dom.description.val ''
						@dom.date.val ''
						@deselectTags()
				else
					@error 'malformed json reply'
					@overlay no
			).fail (xhr, status, err) =>
				@error err
				@overlay no
			no

		for tag in ['atm', 'supermarket', 'restaurant', 'fastfood', 'club', 'pharmacy']
			@dom.tags[tag] = $('<span>').addClass('secondary round label').text(tag).click(((tag) =>
				() =>
					if @dom.tags[tag].hasClass 'secondary' then @dom.tags[tag].removeClass 'secondary' else @dom.tags[tag].addClass 'secondary'
			)(tag))
			@dom.tagContainer.append @dom.tags[tag]

	refresh: () ->
		@overlay yes
		($.ajax '/modules/credit-card/records',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					for record in data.records
						line = $ '<tr>'
						label = $('<span>').addClass('label').text record.amount
						line.append $('<td>').css('text-align', 'right').append label
						date = new Date record.date * 1000
						time = (if date.getHours() < 10 then '0' else '') + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' else '') + date.getMinutes()
						date = date.toDateString()
						line.append $('<td>').append($('<span>').css('color', '#777').text date).append $('<span>').css('color', '#999').text ', ' + time
						line.append $('<td>').text record.description
						line.attr 'title', record.tags
						line.click(((record) =>
							() =>
								@dom.id.val record.id
								@dom.description.val record.description
								@deselectTags()
								tagErrors = ''
								for tag in record.tags.split ','
									if @dom.tags[tag]
										if @dom.tags[tag].hasClass 'secondary' then @dom.tags[tag].removeClass 'secondary'
									else
										tagErrors += '"' + tag + '" '
								if tagErrors.length
									@error 'This record has unknown tags: ' + tagErrors
								else
									@dom.alertBox.hide()
						)(record))
						@dom.table.append line
			else
				@error 'malformed json reply'
		).fail((xhr, status, err) =>
			@error err
		).always () => @overlay no

	show: () ->
		@dom.content.show()
		if not @refreshed
			@refreshed = yes
			@refresh()

	deselectTags: () ->
		for tag, elem of @dom.tags
			if not elem.hasClass 'secondary' then elem.addClass 'secondary'

	hide: () -> @dom.content.hide()

	isVisible: () -> @dom.content.is ':visible'

	overlay: (show) -> if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) ->
		@dom.alertBox.text(err).show()

$ ->

	window.bank = new CreditCard
