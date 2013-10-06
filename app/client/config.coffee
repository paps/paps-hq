window.hq =
	config:
		session:
			modules:
				all: ['notifications', 'bank', 'futureTransactions', 'budget',
					'notes']
				desktop: ['notifications', 'futureTransactions']
				mobile: []
				tablet: []
			refreshInterval: 180 # seconds

		futureTransactions:
			tags: ['atm', 'supermarket', 'restaurant', 'fastfood', 'club',
				'bar', 'pharmacy', 'transport', 'doctor', 'rent', 'utilities',
				'other']

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
				pushover: 'bell_go.png'
			unknownType: 'bell.png'
