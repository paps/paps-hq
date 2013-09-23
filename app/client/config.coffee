window.hq =
	config:
		session:
			modules:
				all: ['notifications', 'bank', 'futureTransactions']
				desktop: ['notifications', 'futureTransactions']
				mobile: []
				tablet: []
			refreshInterval: 180

		futureTransactions:
			tags: ['atm', 'supermarket', 'restaurant', 'fastfood', 'club', 'bar', 'pharmacy', 'transport', 'doctor', 'other']

		notifications:
			knownTypes:
				email: 'email.png'
				mining: 'coins.png'
				chat: 'comment.png'
				bank: 'money.png'
			unknownType: 'bell.png'
