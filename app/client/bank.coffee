class Bank
	constructor: () ->
		@dom =
			header: $ '#bankHeader'
			refresh: $ '#bankRefresh'
			content: $ '#bankContent'
			alertBox: $ '#bankAlertBox'
			overlay: $ '#bankOverlay'
			table: $ '#bankTable'
			balance: $ '#bankBalance'
			balanceProjection: $ '#bankBalanceProjection'
			balanceCurrent: $ '#bankBalanceCurrent'
			id: $ '#bankId'
			amount: $ '#bankAmount'
			select: $ '#bankSelect'
			cancel: $ '#bankCancel'
			form: $ '#bankForm'
			matchAll: $ '#bankMatchAll'
			info: $ '#bankInfo'
			infoTr: $ '#bankInfoTr'
			infoAmount: $ '#bankInfoAmount'
			infoDate: $ '#bankInfoDate'
			infoDescription: $ '#bankInfoDescription'
			infoCancel: $ '#bankInfoCancel'
			infoUnmatch: $ '#bankInfoUnmatch'

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.alertBox.click () =>
			@dom.alertBox.hide()

		@dom.cancel.click () =>
			@dom.form.hide()

		@dom.infoCancel.click () =>
			@dom.info.hide()

		@dom.balance.click () =>
			if @dom.balance.css('color').indexOf('255') >= 0
				@dom.balance.css('color', 'rgb(0, 0, 0)')
			else
				@dom.balance.css('color', 'rgb(255, 255, 255)')

		@dom.matchAll.click () =>
			@overlay yes
			($.ajax '/modules/bank/match-all',
				type: 'GET'
				dataType: 'json'
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
						@overlay no
					else
						@refresh()
						alert 'Matched ' + data.matched + ' transaction' + (if data.matched > 1 then 's' else '') + ', ' + data.unmatched + ' left unmatched.'
				else
					@error 'malformed json reply'
					@overlay no
			).fail (xhr, status, err) =>
				@error status + ': ' + err
				@overlay no

		@projectionAdd = 0
		@projectionAddNb = 0
		@projectionSub = 0
		@projectionSubNb = 0

	refresh: (idToEdit) ->
		@dom.form.hide()
		@dom.info.hide()
		@getFutureTransactions () =>
			($.ajax '/modules/bank/unmatched-transactions',
				type: 'GET'
				dataType: 'json'
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
						@overlay no
					else
						unmatched = data.transactions
						($.ajax '/modules/bank/matched-transactions',
							type: 'GET'
							dataType: 'json'
						).done((data) =>
							if data.errors
								if data.errors.length
									@error JSON.stringify data.errors
								else
									maxDate = 0
									balance = 0
									matched = data.transactions
									@dom.table.empty()
									header = $('<td>').css('text-align', 'center').attr 'colspan', 4
									@dom.table.append $('<tr>').append header
									for tr in unmatched
										if tr.id is idToEdit then @editTransaction tr
										line = $('<tr>').attr 'title', 'not matched (balance: ' + tr.balance + ')'
										label = $('<span>').addClass('label alert').text tr.amount
										line.append $('<td>').css('text-align', 'right').append label
										date = (new Date tr.date * 1000).toDateString()
										line.append $('<td>').css('color', '#777').css('text-align', 'center').text(date)
										line.append $('<td>').text tr.description
										pencil = $('<img>').css('cursor', 'pointer').attr('src', '/img/pencil.png').attr('title', 'edit').attr 'alt', ''
										pencil.click(((tr) =>
											() => @editTransaction tr
										)(tr))
										line.append $('<td>').append pencil
										@dom.table.append line
										if maxDate < tr.date
											maxDate = tr.date
											balance = tr.balance
									nbConsideredMatched = 0
									for tr in matched
										if tr.id is idToEdit then @editTransaction tr
										hoursOffset = 0
										if tr.futureTransaction
											hoursOffset = Math.round (Math.abs (tr.futureTransaction.date - tr.date) / 3600)
										else
											++nbConsideredMatched
										title = (if tr.futureTransaction then (@getFutureTransactionText tr.futureTransaction) else 'considered matched') + ' (balance: ' + tr.balance + ')' + (if hoursOffset >= 70 then ' (' + hoursOffset + ' hours matching offset)' else '')
										line = $('<tr>').attr 'title', title
										label = $('<span>').addClass('label' + (if tr.futureTransaction then (if hoursOffset >= 70 then ' secondary' else '') else ' success')).text tr.amount
										line.append $('<td>').css('text-align', 'right').append label
										date = (new Date tr.date * 1000).toDateString()
										line.append $('<td>').css('color', '#777').css('text-align', 'center').text(date)
										line.append $('<td>').text tr.description
										pencil = $('<img>').css('cursor', 'pointer').attr('src', '/img/pencil.png').attr('title', 'edit').attr 'alt', ''
										pencil.click(((tr) =>
											() => @editTransaction tr
										)(tr))
										line.append $('<td>').append pencil
										@dom.table.append line
										if maxDate < tr.date
											maxDate = tr.date
											balance = tr.balance
									@dom.balanceCurrent.text Math.round(balance * 100) / 100
									projectionTitle = 'Adding ' + @projectionAdd + ' from ' + @projectionAddNb + ' transaction' + (if @projectionAddNb > 1 then 's' else '') +
										', and subtracting ' + (@projectionSub * -1) + ' from ' + @projectionSubNb + ' transaction' + (if @projectionSubNb > 1 then 's' else '')
									@dom.balance.attr 'title', projectionTitle
									@dom.balanceProjection.text Math.round((balance + @projectionAdd + @projectionSub) * 100) / 100
									header.text unmatched.length + ' unmatched, also showing ' + matched.length + ' matched (including ' + nbConsideredMatched + ' considered matched)'
							else
								@error 'malformed json reply while fetching matched transactions'
						).fail((xhr, status, err) =>
							@error status + ': ' + err
						).always () => @overlay no
				else
					@error 'malformed json reply while fetching unmatched transactions'
					@overlay no
			).fail (xhr, status, err) =>
				@error status + ': ' + err
				@overlay no

	editTransaction: (tr) ->
		if tr.futureTransaction
			@dom.form.hide()
			@dom.infoAmount.text tr.futureTransaction.amount
			date = new Date tr.futureTransaction.date * 1000
			time = (if date.getHours() < 10 then '0' else '') + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' else '') + date.getMinutes()
			date = date.toDateString()
			@dom.infoTr.attr 'title', tr.futureTransaction.tag
			@dom.infoDate.text date + ', ' + time
			@dom.infoDescription.text (if tr.futureTransaction.description then tr.futureTransaction.description else '(no description)')
			@dom.infoUnmatch.off('click').click () =>
				@overlay yes
				($.ajax '/modules/bank/unmatch',
					type: 'POST'
					dataType: 'json'
					data:
						id: tr.id
				).done((data) =>
					if data.errors
						if data.errors.length
							@error JSON.stringify data.errors
							@overlay no
						else
							@refresh tr.id
					else
						@error 'malformed json reply'
						@overlay no
				).fail (xhr, status, err) =>
					@error status + ': ' + err
					@overlay no
			@dom.info.show()
			@dom.info.effect 'highlight'
		else
			@dom.info.hide()
			@dom.id.text tr.id
			@dom.amount.text tr.amount
			if tr.considerMatched
				@dom.select.val(-1)
			else
				@dom.select.val(0)
			@dom.form.off('submit').submit () =>
				@overlay yes
				($.ajax '/modules/bank/match',
					type: 'POST'
					dataType: 'json'
					data:
						id: tr.id
						futureTransactionId: @dom.select.val()
				).done((data) =>
					if data.errors
						if data.errors.length
							@error JSON.stringify data.errors
							@overlay no
						else
							@refresh tr.id
					else
						@error 'malformed json reply'
						@overlay no
				).fail (xhr, status, err) =>
					@error status + ': ' + err
					@overlay no
				no
			@dom.form.show()
			@dom.form.effect 'highlight'

	getFutureTransactions: (done) ->
		@overlay yes
		($.ajax '/modules/future-transactions/unmatched',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
					@overlay no
				else
					@dom.select.empty()
					@dom.select.append $('<option>').val(0).text '(unmatched)'
					@dom.select.append $('<option>').val(-1).text '(considered matched)'
					@projectionAdd = 0
					@projectionAddNb = 0
					@projectionSub = 0
					@projectionSubNb = 0
					for tr in data.transactions
						if tr.amount >= 0
							@projectionAdd += tr.amount
							++@projectionAddNb
						else
							@projectionSub += tr.amount
							++@projectionSubNb
						if not tr.doNotMatch
							@dom.select.append $('<option>').val(tr.id).text (@getFutureTransactionText tr)
					@projectionAdd = Math.round(@projectionAdd * 100) / 100
					@projectionSub = Math.round(@projectionSub * 100) / 100
					if done then done() else @overlay no
			else
				@error 'malformed json reply while fetching unmatched future transactions'
				@overlay no
		).fail (xhr, status, err) =>
			@error status + ': ' + err
			@overlay no

	getFutureTransactionText: (ftr) ->
		if ftr.description then d = ftr.description else d = '(no description)'
		date = new Date ftr.date * 1000
		return ftr.amount + ' | ' + date.toDateString() + ' | ' + ftr.tag + ' | ' + d

	show: () ->
		@dom.content.show()
		if not @refreshed
			@refreshed = yes
			@refresh()

	hide: () -> @dom.content.hide()

	isVisible: () -> @dom.content.is ':visible'

	overlay: (show) -> if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) -> @dom.alertBox.text(err).show()

$ -> window.bank = new Bank
