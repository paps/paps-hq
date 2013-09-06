#!/usr/bin/env bash

if [ -d app/public/js -a -d app/client ] # sanity check
then

	cd app/public/js
	while true
	do
		coffee -o . -c ../../client
		rm -f hq.js

		# javascript concatenation with cat
		# order is important
		cat config.js bank.js futureTransactions.js > hq.js

		uglifyjs hq.js -cmvo hq.js
		ls -l hq.js
		sleep 1
		inotifywait -e modify --exclude '.*.swp' ../../client
	done

else

	echo 'app/public/js and/or app/client not found'
	exit 1

fi
