# Headquarters ![project-status](http://stillmaintained.com/paps/paps-hq.png)#

Prerequisites
-------------

(Ubuntu 12.04 LTS 'precise')

	# add-apt-repository ppa:chris-lea/node.js
	# apt-get update
	# apt-get install npm nodejs sqlite inotify-tools
	# npm install -g coffee-script
	# npm install -g supervisor
	# npm install -g uglify-js
	$ cd app
	$ npm install
	$ cd ..

Then, for development, use `./supervisor.sh` and `./coffee.sh`.

SQLite database handling
-----------------------------

`app/db.sqlite` is the database used by the app. It is ignored by git.

To export the schema:

	$ echo .schema | sqlite3 app/db.sqlite
