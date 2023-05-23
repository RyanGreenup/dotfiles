#!/bin/bash
# see  the working directory ~/Studies/programming/mediawiki/fzfTitle/sk_mediawiki.bash

SERVER_DIR="/home/ryan/Applications/Docker/"
DB="${SERVER_DIR}mediawiki/sqlite_db/my_wiki.sqlite"
IP="vale"
PORT="8076"

# Query the user for a page name from wiki (and show preview with bat)
page_name="$(
		sqlite3 "${DB}" 'SELECT page_title FROM page;' |\
			sk --ansi --preview "
						sqlite3 "${DB}" '
								SELECT old_text FROM text WHERE old_id is (
									 SELECT content_id FROM content where content_sha1 is (
										 SELECT rev_sha1 FROM revision WHERE rev_id is (
											 SELECT page_latest FROM page WHERE page_title is \"{}\"
											 )
										 )
									);
								' | bat  --color=always -l org
					    "
           )"


firefox "http://${IP}:${PORT}/index.php/${page_name}" & disown

