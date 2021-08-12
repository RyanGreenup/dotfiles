#!/bin/bash
# Refer to
## https://hub.docker.com/r/kristophjunge/mediawiki/#with-sqlite

docker run --name=mediawiki_wiki \
-p 8080:8080 \
-e MEDIAWIKI_SERVER=http://localhost:8080 \
-e MEDIAWIKI_SECRET_KEY=bbf54691b8d6145125209aa9965e337e16a1e5490a43f2680d2dffab4bd52158 \
-e MEDIAWIKI_SITENAME=MyWiki \
-e MEDIAWIKI_LANGUAGE_CODE=en \
-e MEDIAWIKI_DB_TYPE=sqlite \
-e MEDIAWIKI_DB_NAME=wikidb \
-e MEDIAWIKI_ENABLE_UPLOADS=1 \
-v /var/mediawiki/images:/images \
-v /var/mediawiki/data:/data \
-d kristophjunge/mediawiki
