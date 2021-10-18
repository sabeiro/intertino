sudo apt-get install -y node-htmlparser2 node-jquery node-jsonparse node-dompurify node-get node-highlight.js 
sudo npm install -g htmlparser2
sudo npm install -g cheerio
sudo npm install -g util
sudo npm install -g fs
sudo npm install -g request
sudo npm install -g domhandler
sudo npm install -g casperjs
sudo npm install -g phantomjs
sudo npm install -g selenium-webdriver
sudo npm install -g tough-cookie-filestore



 
wget https://github.com/mozilla/geckodriver/releases/download/v0.20.1/geckodriver-v0.20.1-linux64.tar.gz
sudo sh -c 'tar -x geckodriver -zf geckodriver-v0.16.1-linux64.tar.gz -O > /usr/bin/geckodriver'
sudo chmod +x /usr/bin/geckodriver
rm geckodriver-v0.16.1-linux64.tar.gz
