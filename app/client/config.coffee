window.hq =
	config:
		session:
			modules:
				all: ['notifications', 'bank', 'futureTransactions', 'budget',
					'notes', 'mining']
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

		mining:
			wallets: [
				{
					name: 'Main'
					url: 'https://blockchain.info/address/15cA1zaEE54K9mrXMrLWKk6KGWDTTUG6Gh'
				},
				{
					name: 'Miner1+ggo'
					url: 'https://blockchain.info/address/1NgWDQed3nJcHvZ7GH8U7GFeveJQA1PJ6x'
				},
				{
					name: 'Miner2'
					url: 'https://blockchain.info/address/17F2MdDLNiQ8mZ3Jwt5LZM3jkCrDX2n9QH'
				},
				{
					name: 'LTC'
					url: 'http://block-explorer.com/address/La5aq35eFgPDQVi8G7dZnHXy8DMt3m3LNu'
				}
			]
