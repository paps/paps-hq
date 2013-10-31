class Notes
	constructor: () ->
		@dom = window.hq.utils.getDom 'notes',
			['header', 'refresh', 'content', 'overlay', 'alertBox', 'table',
			'tableContainer', 'form', 'id', 'cancel', 'name', 'text', 'doc',
			'warning']

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@warningTimer = null

		@dom.alertBox.click () => @dom.alertBox.hide()

		@dom.doc.click (e) =>
			@show 'doc / Notes'
			e.stopPropagation()

		@dom.cancel.click () =>
			really = yes
			if not @dom.id.val().length and (@dom.name.val().length or @dom.text.val().length)
				really = confirm 'Are you sure?'
			if really
				@resetForm()
				@showList yes

		@dom.form.submit () =>
			data =
				name: @dom.name.val()
				text: @dom.text.val()
			if @dom.id.val().length then data.id = @dom.id.val()
			($.ajax window.hq.config.rootPath + 'modules/notes/add-or-edit',
				type: 'POST'
				dataType: 'json'
				data: data
			).done((data) =>
				if data.errors
					if data.errors.length
						@error JSON.stringify data.errors
						@overlay no
					else
						@resetForm()
						@showList yes
						@refresh()
				else
					@error 'malformed json reply'
					@overlay no
			).fail (xhr, status, err) =>
				@error status + ': ' + err
				@overlay no
			no

	resetForm: () =>
		@dom.id.val ''
		@dom.name.val ''
		@dom.text.val ''

	refresh: (noteName) =>
		@overlay yes
		($.ajax window.hq.config.rootPath + 'modules/notes/notes',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					header = $('<td>').css('text-align', 'center').attr 'colspan', 3
					header.text data.notes.length  + ' notes '
					createNew = $('<button>').addClass('small').css('margin-bottom', '2px').text 'Create new'
					createNew.click () =>
						@showList no
					header.append createNew
					@dom.table.append $('<tr>').append header
					noteFound = no
					for n in data.notes
						line = $('<tr>')
						line.append $('<td>').css('color', '#777').text window.hq.utils.dateToStr n.date, yes
						line.append $('<td>').css('cursor', 'pointer').attr('title', 'edit').text(n.name).click(((n) =>
							() => @editNote n
						)(n))
						imgDel = $('<img>').attr('title', 'delete').attr('src', window.hq.config.rootPath + 'img/cross.png').css 'cursor', 'pointer'
						imgDel.click(((n) =>
							() => if confirm 'Are you sure?' then @delNote n
						)(n))
						imgEdit = $('<img>').attr('title', 'edit').attr('src', window.hq.config.rootPath + 'img/pencil.png').css 'cursor', 'pointer'
						imgEdit.click(((n) =>
							() => @editNote n
						)(n))
						line.append $('<td>').css('text-align', 'right').append(imgEdit).append(' ').append(imgDel)
						@dom.table.append line
						if noteName and n.name is noteName
							noteFound = yes
							@editNote n
					if noteName and not noteFound
						@error 'Note "' + noteName + '" not found.'
			else
				@error 'malformed json reply'
		).fail((xhr, status, err) =>
			@error status + ': ' + err
		).always () => @overlay no

	delNote: (note) =>
		@overlay yes
		($.ajax window.hq.config.rootPath + 'modules/notes/del',
			type: 'POST'
			dataType: 'json'
			data:
				id: note.id
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
					@overlay no
				else
					@refresh()
			else
				@error 'malformed json reply'
				@overlay no
		).fail (xhr, status, err) =>
			@error status + ': ' + err
			@overlay no

	editNote: (note) =>
		@dom.id.val note.id
		@dom.name.val note.name
		@dom.text.val note.text
		@showList no
		if @warningTimer
			clearInterval @warningTimer
			@warningTimer = null
		@warningTimer = setInterval (() => @dom.warning.show().effect 'highlight'), 30000

	showList: (show) =>
		if show
			@dom.form.hide()
			@dom.tableContainer.show()
			if @warningTimer
				clearInterval @warningTimer
				@warningTimer = null
		else
			@dom.tableContainer.hide()
			@dom.form.show()
			@dom.warning.hide()

	show: (noteName) =>
		@dom.content.show()
		if not @refreshed or noteName
			@refreshed = yes
			@refresh(noteName)

	hide: () => @dom.content.hide()

	isVisible: () => @dom.content.is ':visible'

	overlay: (show) => if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) => @dom.alertBox.text(err).show().effect 'highlight'

$ -> window.hq.notes = new Notes
