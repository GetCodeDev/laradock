#!/bin/sh

USER="root"
PASSWORD="root"
OUTPUTDIR=$(dirname $0)"/databases_dumps"
MYSQLDUMP="mysqldump"
MYSQL="mysql"



if [ -z "$1" ]; then
	databases=`$MYSQL --host=localhost --user=$USER --password=$PASSWORD --batch --skip-column-names -e "SHOW DATABASES;" | grep -v 'mysql\|information_schema'`
	for database in $databases; do
		$MYSQLDUMP \
		--user=$USER --password=$PASSWORD \
		--force \
		--quote-names --dump-date \
		--opt --single-transaction \
		--events --routines --triggers \
		--databases $database \
		| gzip > "$OUTPUTDIR/$database.sql.gz"
	done
else
	for database in ${@}; do
		$MYSQLDUMP \
		--user=$USER --password=$PASSWORD \
		--force \
		--quote-names --dump-date \
		--opt --single-transaction \
		--events --routines --triggers \
		--databases $database \
		| gzip > "$OUTPUTDIR/$database.sql.gz"
	done
fi
