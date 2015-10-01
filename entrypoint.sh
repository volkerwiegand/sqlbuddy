#!/bin/bash
# vim: set ts=8 tw=0 noet :

set -e -o pipefail

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
	   ErrorLog     /proc/self/fd/2
	   CustomLog    /proc/self/fd/1 combined
	   HostnameLookups Off
	</VirtualHost>
EOF

# If a certificate is available, add SSL / TLS
if [[ -d /etc/apache2/tls ]] ; then
	CertName=${CERT_NAME:-localhost}
	cat >/etc/apache2/sites-enabled/ssl_tls.conf <<-EOF
		<VirtualHost *:443>
		   ServerName   $ServerName
		   ServerAdmin  $ServerAdmin
		   DocumentRoot $DocumentRoot
		   ErrorLog     /proc/self/fd/2
		   CustomLog    /proc/self/fd/1 combined
		   HostnameLookups Off

		   SSLEngine               on
		   SSLCertificateFile	   /etc/apache2/tls/certs/${CertName}.pem
		   SSLCertificateKeyFile   /etc/apache2/tls/private/${CertName}.key
		   SSLCertificateChainFile /etc/apache2/tls/certs/${CertName}.pem
		   <FilesMatch "\\.(cgi|shtml|phtml|php)\$">
		      SSLOptions +StdEnvVars
		   </FilesMatch>
		   BrowserMatch "MSIE [2-6]" \\
		      nokeepalive ssl-unclean-shutdown \\
		      downgrade-1.0 force-response-1.0
		   BrowserMatch "MSIE [17-9]" ssl-unclean-shutdown
		</VirtualHost>
	EOF
else
	rm -f /etc/apache2/sites-enabled/ssl_tls.conf
fi

# Apache gets grumpy about PID files pre-existing
rm -f /var/run/apache2/apache2.pid

# Setup environment to avoid warnings in the log
[[ -r /etc/apache2/envvars ]] && . /etc/apache2/envvars

# Hand over to apache as PID 1
exec apache2 -DFOREGROUND

