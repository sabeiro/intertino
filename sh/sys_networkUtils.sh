#check port status
nmap localhost
curl localhost:21
#connect to port
telnet localhost 21
#find process on port
lsof -i :8080
nstat -tln | grep 8080
#firewall
sudo ufw status 
sudo ufw enable
sudo ufw disable
sudo ufw allow ssh
#mysql 3306, postgresql 5432, 
