#!/bin/sh

IP="vidar"
PORT="8076"
BROWSER="firefox"
DB="/home/ryan/Notes/mediawiki/sqlite_db/my_wiki.sqlite"

sqlite_content_from_title() {
        printf "
    -- Commented Columns are helpful for debugging
    SELECT
    --  p.page_title AS title
        t.old_text AS text
    --	p.page_namespace AS namespace
    --  p.page_id AS id,
    --  p.page_latest AS latest,
    --  r.rev_sha1 AS revision_sha1,
    --  c.content_id AS content_id,
    FROM page AS p
    INNER JOIN revision AS r ON p.page_latest = r.rev_id
    INNER JOIN content AS c ON c.content_sha1 = r.rev_sha1
    INNER JOIN text AS t ON t.old_id = c.content_id
    WHERE p.page_namespace = 0
    AND p.page_title = '%s'\n" "${1}"
}

get_page() {
 sqlite3 "${DB}" 'SELECT page_title FROM page;' |\
     sk --ansi --preview "sqlite3 ${DB} \"$(sqlite_content_from_title \"{}\")\" | bat --color=always -l org"
}


get_url() {
    printf "http://${IP}:${PORT}/index.php/$(get_page)"
}

"${BROWSER}" "$(get_url)"
