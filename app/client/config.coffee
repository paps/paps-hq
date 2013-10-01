window.hq =
	config:
		session:
			modules:
				all: ['notifications', 'bank', 'futureTransactions', 'budget']
				desktop: ['notifications', 'futureTransactions']
				mobile: []
				tablet: []
			refreshInterval: 180 # seconds

		futureTransactions:
			tags: ['atm', 'supermarket', 'restaurant', 'fastfood', 'club', 'bar', 'pharmacy', 'transport', 'doctor', 'rent', 'other']

		notifications:
			knownTypes:
				email: 'email.png'
				mining: 'coins.png'
				chat: 'comment.png'
				bank: 'money.png'
				reddit: 'reddit-alien.png'
				machine: 'computer.png'
				phone: 'telephone.png'
				headquarters: 'flag_purple.png'
			unknownType: 'bell.png'
