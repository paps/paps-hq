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

	dateFromTimestamp: (timestamp) -> new Date timestamp * 1000

	round: (n, decimals) -> (Math.round n * Math.pow(10, decimals)) / (Math.pow 10, decimals)

	now: () -> Math.round(Date.now() / 1000)

	ageToString: (age) ->
		if (typeof age) isnt 'number'
			'?'
		if age < 0
			'?'
		else if age < 120
			'' + age + 's'
		else if age < 60 * 60 * 2
			'' + Math.round(age / 60) + 'm'
		else if age < 60 * 60 * 72
			'' + Math.round(age / (60 * 60)) + 'h'
		else
			'' + Math.round(age / (60 * 60 * 24)) + 'd'

$ -> window.hq.utils = new Utils
