CREATE TABLE configurations (ip TEXT PRIMARY KEY, auto_refresh INTEGER, open_modules TEXT);
CREATE TABLE future_transactions (do_not_match INTEGER, transaction_id INTEGER, tag TEXT, id INTEGER PRIMARY KEY, amount REAL, description TEXT, date INTEGER);
CREATE TABLE notes (id INTEGER PRIMARY KEY, date INTEGER, text TEXT, name TEXT);
CREATE TABLE notifications (md5sum TEXT, id INTEGER PRIMARY KEY, count INTEGER, type TEXT, text TEXT, r INTEGER, g INTEGER, b INTEGER, date INTEGER, read INTEGER);
CREATE TABLE sessions (id TEXT PRIMARY KEY, data TEXT, date INTEGER);
CREATE TABLE transactions (nb_updates INTEGER, consider_matched INTEGER, md5sum TEXT, id INTEGER PRIMARY KEY, amount REAL, description TEXT, balance REAL, date INTEGER);
