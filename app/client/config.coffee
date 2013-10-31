window.hq =
	config:
		rootPath: '/'

		session:
			modules:
				all: ['notifications', 'bank', 'futureTransactions', 'budget',
					'notes', 'mining', 'wallets']
				desktop: ['notifications', 'futureTransactions']
				mobile: []
				tablet: []
			refreshInterval: 180 # seconds

		futureTransactions:
			tags: ['atm', 'supermarket', 'restaurant', 'fastfood', 'club',
				'bar', 'pharmacy', 'transport', 'doctor', 'rent', 'utilities',
				'domain', 'tech', 'bitcoin', 'other']

		notifications:
			knownTypes:
				email: 'email.png'
				mining: 'coins.png'
				wallet: 'lock.png'
				chat: 'comment.png'
				bank: 'money.png'
				reddit: 'reddit-alien.png'
				machine: 'computer.png'
				phone: 'telephone.png'
				headquarters: 'flag_purple.png'
				pushover: 'bell_go.png'
			unknownType: 'bell.png'

		budget:
			ignoredTagsForAtmDistribution: ['rent', 'domain', 'utilities']

		notes:
			saveInterval: 30 # seconds
