#!/usr/bin/env bash

if [ -d app/public/js -a -d app/client ] # sanity check
then

	cd app/public/js
	while true
	do
		coffee -o . -c ../../client
		rm -f hq.js

		# javascript concatenation with cat
		# order is important:
		#   config must be first
		#   Utils must be second
		#   Session must be last
		cat config.js Utils.js Bank.js FutureTransactions.js Notifications.js Budget.js Notes.js Mining.js Wallets.js Machines.js BtcChina.js Session.js > hq.js

		uglifyjs hq.js -cmvo hq.js
		ls -l hq.js
		sleep 1
		inotifywait -e modify --exclude '.*.swp' ../../client
	done

else

	echo 'app/public/js and/or app/client not found'
	exit 1

fi
