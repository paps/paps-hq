module.exports =
	env: 'dev' # dev/prod
	port: 8090
	db:
		dev: 'sqlite3://app/db.sqlite'
		prod: 'sqlite3://app/db.sqlite'
	login: 'paps'
	password: 'bacon'
	secret: 'skdfgjsdfjg' # generate secret here
