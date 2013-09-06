class FutureTransactions
	constructor: () ->
		@dom =
			header: $ '#futureTransactionsHeader'
			refresh: $ '#futureTransactionsRefresh'
			content: $ '#futureTransactionsContent'
			amount: $ '#futureTransactionsAmount'
			description: $ '#futureTransactionsDescription'
			date: $ '#futureTransactionsDate'
			id: $ '#futureTransactionsId'
			overlay: $ '#futureTransactionsOverlay'
			form: $ '#futureTransactionsForm'
			del: $ '#futureTransactionsDel'
			tagContainer: $ '#futureTransactionsTagContainer'
			tags: {}
			alertBox: $ '#futureTransactionsAlertBox'
			table: $ '#futureTransactionsTable'

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.date.datetimepicker
			controlType: 'select'
			dateFormat: 'dd/mm/yy'

		@dom.alertBox.click () =>
			@dom.alertBox.hide()

		@dom.form.submit () =>
			@overlay yes
			tags = ''
			for tag, elem of @dom.tags
				if not elem.hasClass 'secondary'
					tags += ',' if tags.length
					tags += tag
			data =
				amount: @dom.amount.val()
				date: @dom.date.datetimepicker('getDate')?.getTime() / 1000
				description: @dom.description.val()
				tags: tags
			if @dom.id.val().length then data.id = @dom.id.val()
			($.ajax '/modules/future-transactions/transaction/add-or-edit',
				type: 'POST'
				dataType: 'json'
				data: data
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
						@overlay no
					else
						@refresh()
						@resetForm()
				else
					@error 'malformed json reply'
					@overlay no
			).fail (xhr, status, err) =>
				@error err
				@overlay no
			no

		@dom.del.click () =>
			@overlay yes
			($.ajax '/modules/future-transactions/transaction/del',
				type: 'POST'
				dataType: 'json'
				data:
					id: @dom.id.val()
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
						@overlay no
					else
						@refresh()
						@resetForm()
				else
					@error 'malformed json reply'
					@overlay no
			).fail (xhr, status, err) =>
				@error err
				@overlay no

		for tag in window.hq.config.futureTransactions.tags
			@dom.tags[tag] = $('<span>').addClass('secondary round label').text(tag).click(((tag) =>
				() =>
					if @dom.tags[tag].hasClass 'secondary' then @dom.tags[tag].removeClass 'secondary' else @dom.tags[tag].addClass 'secondary'
			)(tag))
			@dom.tagContainer.append @dom.tags[tag]

	refresh: () ->
		@overlay yes
		($.ajax '/modules/future-transactions/transactions',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					for transaction in data.transactions
						line = $ '<tr>'
						label = $('<span>').addClass('label').text transaction.amount
						line.append $('<td>').css('text-align', 'right').append label
						date = new Date transaction.date * 1000
						time = (if date.getHours() < 10 then '0' else '') + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' else '') + date.getMinutes()
						date = date.toDateString()
						line.append $('<td>').append($('<span>').css('color', '#777').text date).append $('<span>').css('color', '#999').text ', ' + time
						line.append $('<td>').text transaction.description
						line.attr 'title', transaction.tags
						line.click(((transaction) =>
							() =>
								@dom.id.val transaction.id
								@dom.description.val transaction.description
								@dom.amount.val transaction.amount
								d = new Date transaction.date * 1000
								@dom.date.val (if d.getDate() < 10 then '0' else '') + d.getDate() + '/' + (if d.getMonth() + 1 < 10 then '0' else '') + (d.getMonth() + 1) + '/' + d.getFullYear() +
									' ' + (if d.getHours() < 10 then '0' else '') + d.getHours() + ':' + (if d.getMinutes() < 10 then '0' else '') + d.getMinutes()
								@deselectTags()
								tagErrors = ''
								for tag in transaction.tags.split ','
									if @dom.tags[tag]
										if @dom.tags[tag].hasClass 'secondary' then @dom.tags[tag].removeClass 'secondary'
									else
										tagErrors += '"' + tag + '" '
								if tagErrors.length
									@error 'This transaction has unknown tags: ' + tagErrors
								else
									@dom.alertBox.hide()
						)(transaction))
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

	resetForm: () ->
		@dom.id.val ''
		@dom.amount.val ''
		@dom.description.val ''
		@dom.date.val ''
		@deselectTags()

	deselectTags: () ->
		for tag, elem of @dom.tags
			if not elem.hasClass 'secondary' then elem.addClass 'secondary'

	hide: () -> @dom.content.hide()

	isVisible: () -> @dom.content.is ':visible'

	overlay: (show) -> if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) ->
		@dom.alertBox.text(err).show()

$ ->

	window.hq.futureTransactions = new FutureTransactions
