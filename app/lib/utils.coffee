module.exports =

	dateFromTimestamp: (timestamp) -> new Date timestamp * 1000

	round: (n, decimals) -> (Math.round n * Math.pow(10, decimals)) / (Math.pow 10, decimals)

	now: () -> Math.round(Date.now() / 1000)
