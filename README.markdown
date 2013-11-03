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

For production, `./coffee.sh` is not really necessary. Just run it once every
time you pull to generate the minified javascript. `./supervisor.sh` can be
used, or any other system that watches node.

SQLite database handling
------------------------

`app/db.sqlite` is the database used by the app. It is ignored by git.

To export the schema:

	$ echo .schema | sqlite3 app/db.sqlite

`db.sql` contains the schema. To update it:

	$ echo .schema | sqlite3 app/db.sqlite > db.sql

To create a fresh database:

	$ sqlite3 app/fresh-db.sqlite < db.sql

nginx
-----

Example nginx configuration for SSL headquarters in a `hq` sub-directory:

	server {
		listen 80;
		server_name yolo.com;

		return 301 https://yolo.com$request_uri;
	}

	server {
		listen 443 default_server ssl;
		server_name yolo.com;

		ssl_certificate /etc/nginx/ssl/server.crt;
		ssl_certificate_key /etc/nginx/ssl/server.key;

		root /home/bob/www/yolo.com;

		access_log /home/bob/www-logs/yolo.com/access.log;
		error_log /home/bob/www-logs/yolo.com/error.log;

		location ^~ /hq/ {
				rewrite /hq(.*) $1 break;
				proxy_set_header X-Real-IP $remote_addr;
				proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
				proxy_set_header Host $http_host;
				proxy_set_header X-NginX-Proxy true;
				proxy_pass http://127.0.0.1:8090;
				proxy_redirect http://127.0.0.1:8090/ /hq/;
		}
	}

For this to work, `rootPath` must be set to `/hq/` in `app/config.coffee` and
`app/client/config.coffee`. Also, port 8090.
