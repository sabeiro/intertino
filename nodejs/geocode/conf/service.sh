sudo cp geocode.service /etc/systemd/system/
sudo systemctl start geocode
openssl req -x509 -newkey rsa:2048 -keyout keytmp.pem -out cert.pem -days 365
openssl rsa -in keytmp.pem -out key.pem

openssl genrsa -des3 -out server.key 1024
openssl req -new -key server.key -out server.csr
openssl x509 -req -days 1024 -in server.csr -signkey server.key -out server.crt
