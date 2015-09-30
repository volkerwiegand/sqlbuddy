#!/bin/bash
set -e

# Place SQL Buddy where the user wants to see it
SqlBuddyUri=${SQLBUDDY_URI:-/}
SqlBuddyUri=${SqlBuddyUri%/}
SqlBuddyUri=${SqlBuddyUri#/}

if [[ -z "$SqlBuddyUri" ]] ; then
	DocumentRoot="/var/lib/sqlbuddy"
else
	DocumentRoot="/var/www/html"
	mkdir -p $DocumentRoot/${SqlBuddyUri%/*}
	ln -nfs /var/lib/sqlbuddy $DocumentRoot/$SqlBuddyUri
fi

# Setup the default virtual host
ServerName=${SERVER_NAME:-localhost}
ServerAdmin=${SERVER_ADMIN:-webmaster@localhost}

cat >/etc/apache2/sites-enabled/default.conf <<-EOF
	<VirtualHost *:80>
	   ServerName   $ServerName
	   ServerAdmin  $ServerAdmin
	   DocumentRoot $DocumentRoot
	   ErrorLog     \${APACHE_LOG_DIR}/error.log
	   CustomLog    \${APACHE_LOG_DIR}/access.log combined
	</VirtualHost>
EOF

# If a certificate is available, add SSL / TLS
if [[ -d /etc/apache2/tls ]] ; then
	cat >/etc/apache2/sites-enabled/ssl_tls.conf <<-EOF
		<VirtualHost *:443>
		   ServerName   $ServerName
		   ServerAdmin  $ServerAdmin
		   DocumentRoot $DocumentRoot
		   ErrorLog     \${APACHE_LOG_DIR}/error.log
		   CustomLog    \${APACHE_LOG_DIR}/access.log combined
		   SSLEngine    on
		   SSLCertificateFile	   /etc/apache2/tls/cert.crt
		   SSLCertificateKeyFile   /etc/apache2/tls/cert.key
		   SSLCertificateChainFile /etc/apache2/tls/chain.crt
		</VirtualHost>
	EOF
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

exec apache2 -DFOREGROUND

