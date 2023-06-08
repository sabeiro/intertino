
FROM debian:11


# Install software

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt clean

RUN apt install -y supervisor rsyslog \
	postfix dovecot-core dovecot-imapd dovecot-lmtpd dovecot-managesieved opendkim \
	roundcube roundcube-sqlite3 roundcube-plugins \
	certbot openssh-server rsync \
	&& apt clean \
	\
	&& sed -i s/bullseye/bookworm/ /etc/apt/sources.list \
	&& apt update \
	&& apt install -y postfix


# Server hostname & all managed domains

ARG SERVER_HOSTNAME="lightmetermail.io"
ENV SERVER_HOSTNAME $SERVER_HOSTNAME

ENV VMAILBOX_DOMAINS="lightmetermail.io outreach.lightmeter.io heylightmeter.com agencycybersecurity.com atlas-mail.io heytheneo.io campfireone.com campfireremote.com getstackshine.com getagencycyber.com joinavocademy.com"


# Supervisord

COPY origconf/etc/supervisor/10-mail.conf /etc/supervisor/conf.d/10-mail.conf
RUN chmod 644 /etc/supervisor/conf.d/10-mail.conf
COPY scripts/startup-script.sh /startup-script.sh
RUN chmod 755 /startup-script.sh


# Postfix

COPY origconf/etc/postfix/vmailbox       /etc/postfix/vmailbox
RUN chmod 644 /etc/postfix/vmailbox
COPY origconf/etc/postfix/vmail_aliases  /etc/postfix/vmail_aliases
RUN chmod 644 /etc/postfix/vmail_aliases
COPY origconf/etc/postfix/sender_bcc     /etc/postfix/sender_bcc
RUN chmod 644 /etc/postfix/sender_bcc
COPY origconf/etc/postfix/sasl_passwd    /etc/postfix/sasl_passwd
RUN chmod 644 /etc/postfix/sasl_passwd

COPY origconf/etc/postfix/recipient_transport_map_base  /etc/postfix/recipient_transport_map_base
RUN chmod 644 /etc/postfix/recipient_transport_map_base
COPY origconf/etc/postfix/sender_transport_map_base     /etc/postfix/sender_transport_map_base
RUN chmod 644 /etc/postfix/sender_transport_map_base
COPY origconf/etc/postfix/network_table                 /etc/postfix/network_table
RUN chmod 644 /etc/postfix/network_table

COPY scripts/postconf.sh /postconf.sh
RUN chmod 755 /postconf.sh
RUN /postconf.sh


# Dovecot

COPY origconf/etc/dovecot/conf.d/99-lightmeter.conf /etc/dovecot/conf.d/99-lightmeter.conf
RUN chmod 644 /etc/dovecot/conf.d/99-lightmeter.conf

COPY origconf/etc/dovecot/imap.passwd /etc/dovecot/imap.passwd
RUN chmod 644 /etc/dovecot/imap.passwd

## do not use system user's for authenticating
RUN sed 's|^!include auth-system.conf\.ext|#\0|g' -i /etc/dovecot/conf.d/10-auth.conf

## create temporary empty cert files, waiting for them to be synced from router
RUN mkdir -p /etc/letsencrypt/live/lightmeter
RUN touch /etc/letsencrypt/live/lightmeter/fullchain.pem
RUN touch /etc/letsencrypt/live/lightmeter/privkey.pem


# OpenDkim

COPY origconf/etc/opendkim/ /etc/opendkim
RUN chmod 755 /etc/opendkim
RUN chmod 644 /etc/opendkim/KeyTable /etc/opendkim/SigningTable /etc/opendkim/TrustedHosts
RUN chown opendkim:opendkim -R /etc/opendkim
RUN chmod -R 700 /etc/opendkim/keys
RUN chown opendkim:opendkim /etc/opendkim/keys/*/default.private

RUN sed 's/^SOCKET=/#SOCKET=/g'    -i /etc/default/opendkim
RUN sed 's/^Socket\s/#Socket /g'   -i /etc/opendkim.conf
RUN echo "SOCKET=inet:12345@localhost" >> /etc/default/opendkim
RUN echo "Socket inet:12345@localhost" >> /etc/opendkim.conf

RUN cat /etc/opendkim/opendkim.conf.add >> /etc/opendkim.conf

# Routeee

COPY origconf/etc/supervisor/20-ssh.conf /etc/supervisor/conf.d/20-ssh.conf
RUN chmod 644 /etc/supervisor/conf.d/20-ssh.conf
COPY origconf/home/admin/.ssh/authorized_keys /root/.ssh/authorized_keys
RUN chmod 0600 /root/.ssh/authorized_keys

# Router

COPY origconf/home/admin/.ssh/id_rsa_lightmeter_mailservers /id_rsa
RUN chmod 0600 /id_rsa

COPY scripts/sync-cert-files.sh /sync-cert-files.sh
RUN chmod 755 /sync-cert-files.sh
COPY scripts/gen_dkim_key.sh /gen_dkim_key.sh
RUN chmod 755 /gen_dkim_key.sh
COPY scripts/add_mailbox.sh /add_mailbox.sh
RUN chmod 755 /add_mailbox.sh

# Roundcube

## activate /roundcube alias to actually have access

RUN sed -i 's/#\s*Alias \/roundcube/Alias \/roundcube/'   /etc/apache2/conf-enabled/roundcube.conf

## database config

COPY origconf/etc/roundcube/debian-db.php /etc/roundcube/debian-db.php
RUN chmod 644 /etc/roundcube/debian-db.php

COPY origconf/etc/roundcube/config.lightmeter.inc.php /etc/roundcube/config.lightmeter.inc.php
RUN chmod 644 /etc/roundcube/config.lightmeter.inc.php
RUN echo "require '/etc/roundcube/config.lightmeter.inc.php';" >> /etc/roundcube/config.inc.php

## Fix database file path error
RUN mkdir -p /var/lib/roundcube/SQL/
RUN cp /usr/share/roundcube/SQL/sqlite.initial.sql /var/lib/roundcube/SQL/sqlite.initial.sql

## Apache
COPY origconf/etc/apache2/sites-available/all-ssl.conf         /etc/apache2/sites-available/all-ssl.conf
RUN chmod 644 /etc/apache2/sites-available/all-ssl.conf
COPY origconf/etc/apache2/sites-available/99-redirect-all.conf /etc/apache2/sites-available/99-redirect-all.conf
RUN chmod 644 /etc/apache2/sites-available/99-redirect-all.conf

RUN a2enmod ssl
RUN a2enmod rewrite
RUN a2dissite 000-default.conf
RUN a2ensite all-ssl
RUN a2ensite 99-redirect-all


## Logrotate
COPY origconf/etc/logrotate.d/mail /etc/logrotate.d/mail
RUN chmod 644 /etc/logrotate.d/mail 
COPY origconf/etc/logrotate.d/rsyslog /etc/logrotate.d/rsyslog
RUN chmod 644 /etc/logrotate.d/rsyslog

# Sieve

RUN mkdir -p /usr/local/etc/dovecot/sieve/global


# Start everything

ENTRYPOINT ["/startup-script.sh"]
