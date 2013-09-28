class FutureTransactions
	constructor: () ->
		@dom = window.hq.utils.getDom 'futureTransactions',
			['header', 'refresh', 'content', 'amount', 'description', 'date',
			'time', 'id', 'overlay', 'form', 'del', 'tagContainer', 'alertBox',
			'table', 'dnm', 'clearForm']
		@dom.tags = {}

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

		@dom.clearForm.click (e) =>
			@show()
			@resetForm()
			e.stopPropagation()

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

	refresh: () =>
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
					header = $('<td>').css('text-align', 'center').attr 'colspan', 4
					@dom.table.append $('<tr>').append header
					nbMatched = 0
					nbUnmatched = 0
					nbDnm = 0
					for transaction in data.transactions
						if transaction.transactionId isnt null and not transaction.doNotMatch and (nbDnm + nbUnmatched) > 0 and nbMatched is 0
							@dom.table.append $('<tr>').append $('<td>').attr('colspan', 4).css('background-color', '#ccc').css('padding', '0px').css 'height', '7px'
						line = $ '<tr>'
						line.attr 'title', (if transaction.transactionId is null then (if transaction.doNotMatch then 'do not match flag on' else 'unmatched') else 'matched') + ' | ' + transaction.tag
						label = $('<span>').addClass('label').text transaction.amount
						if transaction.doNotMatch
							label.addClass 'success'
							++nbDnm
						else if transaction.transactionId is null
							label.addClass 'alert'
							++nbUnmatched
						else
							++nbMatched
						line.append $('<td>').css('text-align', 'right').append label
						line.append $('<td>').css('color', '#777').css('text-align', 'center').text window.hq.utils.dateToStr transaction.date, yes
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
					header.text nbUnmatched + ' unmatched, ' + nbDnm + ' DNM, also showing ' + nbMatched + ' matched'
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

	resetForm: () =>
		@dom.id.val ''
		@dom.amount.val ''
		@dom.description.val ''
		@dom.date.val ''
		@dom.time.val ''
		@dom.dnm.prop 'checked', 0
		@deselectTags()

	deselectTags: () =>
		for tag, elem of @dom.tags
			if not elem.hasClass 'secondary' then elem.addClass 'secondary'

	hide: () => @dom.content.hide()

	isVisible: () => @dom.content.is ':visible'

	overlay: (show) => if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) => @dom.alertBox.text(err).show().effect 'highlight'

$ -> window.hq.futureTransactions = new FutureTransactions
