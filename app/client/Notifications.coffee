class Notifications
	constructor: () ->
		@dom = window.hq.utils.getDom 'notifications',
			['header', 'refresh', 'content', 'overlay', 'alertBox', 'table']

		@refreshed = no
		@dom.header.click () =>
			if @isVisible() then @hide() else @show()
		@dom.refresh.click (e) =>
			@refreshed = no
			@show()
			e.stopPropagation()

		@dom.alertBox.click () => @dom.alertBox.hide()

	refresh: () =>
		@overlay yes
		($.ajax '/modules/notifications/notifications',
			type: 'GET'
			dataType: 'json'
		).done((data) =>
			if data.errors
				if data.errors.length
					@error JSON.stringify data.errors
				else
					@dom.table.empty()
					header = $('<td>').css('text-align', 'center').attr 'colspan', 5
					@dom.table.append $('<tr>').append header
					gotReadNotif = no
					nbUnread = 0
					for n in data.notifications
						if not n.read then ++nbUnread
						if n.read and not gotReadNotif and nbUnread > 0
							gotReadNotif = yes
							@dom.table.append $('<tr>').append $('<td>').attr('colspan', 5).css('background-color', '#ccc').css('padding', '0px').css 'height', '7px'
						if window.hq.config.notifications.knownTypes[n.type]
							title = n.type
							icon = '/img/' + window.hq.config.notifications.knownTypes[n.type]
						else
							title = n.type + ' (unknown type)'
							icon = '/img/' + window.hq.config.notifications.unknownType
						line = $('<tr>').attr 'title', title + (if n.read then ' (read)' else ' (unread)')
						if n.read then line.css 'text-decoration', 'line-through'
						label = $('<span>').addClass('label round').css('background-color', 'rgb(' + n.r + ',' + n.g + ',' + n.b + ')').html '&times;' + n.count
						line.append $('<td>').append label
						line.append $('<td>').css('color', '#777').css('text-align', 'center').text window.hq.utils.dateToStr n.date, yes
						line.append $('<td>').css('text-align', 'right').append $('<img>').attr('alt', '').attr 'src', icon
						line.append $('<td>').text n.text
						imgChangeRead = $('<img>').attr('alt', '').attr('title', 'mark as ' + (if n.read then 'un' else '') + 'read').attr('src', '/img/' + (if n.read then 'arrow_undo' else 'tick') + '.png').css 'cursor', 'pointer'
						imgChangeRead.click(((n) =>
							() =>
								@overlay yes
								($.ajax '/modules/notifications/mark-read',
									type: 'POST'
									dataType: 'json'
									data:
										id: n.id
										read: (if n.read then 0 else 1)
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
						)(n))
						line.append $('<td>').css('text-align', 'right').append imgChangeRead
						@dom.table.append line
					if nbUnread is 0
						header.text 'No unread notifications'
					else
						header.text nbUnread + ' unread notification' + (if nbUnread > 1 then 's' else '') + ' '
						markAllAsRead = $('<button>').addClass('small').css('margin-bottom', '2px').text 'Mark all as read'
						markAllAsRead.click () =>
							@overlay yes
							($.ajax '/modules/notifications/mark-all-as-read',
								type: 'POST'
								dataType: 'json'
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
						header.append markAllAsRead
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

	hide: () => @dom.content.hide()

	isVisible: () => @dom.content.is ':visible'

	overlay: (show) => if show then @dom.overlay.show() else @dom.overlay.hide()

	error: (err) => @dom.alertBox.text(err).show().effect 'highlight'

$ -> window.hq.notifications = new Notifications
