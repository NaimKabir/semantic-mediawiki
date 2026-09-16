#!/bin/sh
set -eu
cd /var/www/html
php maintenance/run.php install --dbtype sqlite --dbpath /var/www/data \
    --dbname smw --server http://localhost:8080 --scriptpath '' \
    --pass smw-demo-password 'Semantic MediaWiki Demo' Admin
printf '\nwfLoadExtension("SemanticMediaWiki");\n' >> LocalSettings.php
php maintenance/run.php update --quick
chown -R www-data:www-data /var/www/data cache images
