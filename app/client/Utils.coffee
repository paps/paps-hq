class Utils
	constructor: () ->
		$.ajaxSetup cache: false
		@days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
		@months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec']

	getDom: (prefix, arrayOfIds) ->
		dom = {}
		for id in arrayOfIds
			dom[id] = $ '#' + prefix + id.charAt(0).toUpperCase() + id.slice(1)
		return dom

	dateToStr: (date, withMinutes) ->
		if (typeof date) isnt 'object' then date = new Date date * 1000
		ret = @days[date.getDay()] + ' ' + @months[date.getMonth()] + ' ' + date.getDate()
		if withMinutes
			ret += ', ' + (if date.getHours() < 10 then '0' else '') + date.getHours() + ':' + (if date.getMinutes() < 10 then '0' else '') + date.getMinutes()
		return ret

$ -> window.hq.utils = new Utils
