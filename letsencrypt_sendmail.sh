cat /usr/local/etc/letsencrypt/live/imbrius.ddns.net/privkey.pem \
    /usr/local/etc/letsencrypt/live/imbrius.ddns.net/cert.pem > \
    /etc/mail/certs/sendmail.pem
chmod 0600 /etc/mail/certs/sendmail.pem
cat /usr/local/etc/letsencrypt/live/imbrius.ddns.net/chain.pem > \
    /etc/mail/certs/chain.pem

