class FutureTransactions
	constructor: () ->
		@dom =
			header: $ '#futureTransactionsHeader'
			refresh: $ '#futureTransactionsRefresh'
			content: $ '#futureTransactionsContent'
			amount: $ '#futureTransactionsAmount'
			description: $ '#futureTransactionsDescription'
			date: $ '#futureTransactionsDate'
			time: $ '#futureTransactionsTime'
			id: $ '#futureTransactionsId'
			overlay: $ '#futureTransactionsOverlay'
			form: $ '#futureTransactionsForm'
			del: $ '#futureTransactionsDel'
			tagContainer: $ '#futureTransactionsTagContainer'
			tags: {}
			alertBox: $ '#futureTransactionsAlertBox'
			table: $ '#futureTransactionsTable'
			dnm: $ '#futureTransactionsDnm'

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.date.datepicker dateFormat: 'dd/mm/yy'

		@dom.alertBox.click () =>
			@dom.alertBox.hide()

		@dom.form.submit () =>
			time = @dom.time.val()
			if not @dom.date.datepicker('getDate') or time.length < 4
				@error 'Invalid date.'
				return no
			try
				time = (parseInt time.substr 0, 2) * 60 * 60 + (parseInt time.substr -2) * 60
				date = @dom.date.datepicker('getDate').getTime() / 1000 + time
			catch e
				@error 'Exception while parsing date: ' + e.toString()
				return no
			@overlay yes
			tag = ''
			for t, elem of @dom.tags
				if not elem.hasClass 'secondary'
					tag = t
			data =
				amount: @dom.amount.val()
				date: date
				description: @dom.description.val()
				tag: tag
				doNotMatch: if @dom.dnm.is ':checked' then 1 else 0
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
				@error status + ': ' + err
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
				@error status + ': ' + err
				@overlay no

		for tag in window.hq.config.futureTransactions.tags
			@dom.tags[tag] = $('<span>').addClass('secondary round label').css('cursor', 'pointer').text(tag).click(((tag) =>
				() =>
					wasNotSelected = @dom.tags[tag].hasClass 'secondary'
					@deselectTags()
					if wasNotSelected then @dom.tags[tag].removeClass 'secondary'
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
						line.attr 'title', (if transaction.transactionId is null then (if transaction.doNotMatch then 'do not match flag on' else 'unmatched') else 'matched') + ' | ' + transaction.tag
						label = $('<span>').addClass('label').text transaction.amount
						if transaction.doNotMatch
							label.addClass 'success'
						else if transaction.transactionId is null
							label.addClass 'alert'
						line.append $('<td>').css('text-align', 'right').append label
						date = new Date transaction.date * 1000
						time = (if date.getHours() < 10 then '0' else '') + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' else '') + date.getMinutes()
						date = date.toDateString()
						line.append $('<td>').css('color', '#777').css('text-align', 'center').text date + ', ' + time
						line.append $('<td>').text transaction.description
						pencil = $('<img>').css('cursor', 'pointer').attr('src', '/img/pencil.png').attr('title', 'edit').attr 'alt', ''
						line.append $('<td>').append pencil
						pencil.click(((transaction) =>
							() =>
								@dom.id.val transaction.id
								@dom.description.val transaction.description
								@dom.amount.val transaction.amount
								@dom.dnm.prop 'checked', transaction.doNotMatch
								d = new Date transaction.date * 1000
								@dom.date.val (if d.getDate() < 10 then '0' else '') + d.getDate() + '/' + (if d.getMonth() + 1 < 10 then '0' else '') + (d.getMonth() + 1) + '/' + d.getFullYear()
								@dom.time.val (if d.getHours() < 10 then '0' else '') + d.getHours() + (if d.getMinutes() < 10 then '0' else '') + d.getMinutes()
								@deselectTags()
								tag = transaction.tag
								if @dom.tags[tag]
									if @dom.tags[tag].hasClass 'secondary' then @dom.tags[tag].removeClass 'secondary'
									@dom.alertBox.hide()
								else
									@error 'This transaction has an unknown tag: ' + tag
						)(transaction))
						@dom.table.append line
			else
				@error 'malformed json reply'
		).fail((xhr, status, err) =>
			@error status + ': ' + err
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
		@dom.time.val ''
		@dom.dnm.prop 'checked', 0
		@deselectTags()

	deselectTags: () ->
		for tag, elem of @dom.tags
			if not elem.hasClass 'secondary' then elem.addClass 'secondary'

	hide: () -> @dom.content.hide()

	isVisible: () -> @dom.content.is ':visible'

	overlay: (show) -> if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) -> @dom.alertBox.text(err).show()

$ -> window.hq.futureTransactions = new FutureTransactions
